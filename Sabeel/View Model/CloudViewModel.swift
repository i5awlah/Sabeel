//
//  CloudViewModel.swift
//  Sabeel
//
//  Created by Khawlah on 09/02/2023.
//

import Foundation
import CloudKit

class CloudViewModel: ObservableObject {
    
    private var container: CKContainer
    @Published var iCloudAvailable: Bool = false
    @Published var currentUser: UserModel?
    @Published var childParentModel: ChildParentModel?
    
    @Published var homeContents: [HomeContent] = []
    @Published var childRequests: [ChildRequestModel] = []
    
    var isChild: Bool {
        return currentUser is ChildModel
    }
    
    init() {
        self.container = CKContainer.default()
        getiCloudStatus()
    }
    
    func getiCloudStatus() {
        container.accountStatus { status, error in
            if status == .available {
                DispatchQueue.main.async {
                    self.iCloudAvailable = true
                    self.fetchUser()
                }
            } else {
                DispatchQueue.main.async {
                    self.iCloudAvailable = false
                }
            }
        }
    }
    
    // get ID of user
    func fetchiCloudUserRecordId() async -> String {
        return await withCheckedContinuation { continuation in
            container.fetchUserRecordID { recordID, error in
                if let recordID = recordID {
                    continuation.resume(returning: recordID.recordName)
                }
            }
        }
    }
    
    // add new user to record
    func addUser(user: UserModel) {
        // get the record type name based on the type of user
        let recordName = user is ChildModel ? ChildModel.recordTypeKey : ParentModel.recordTypeKey
        print("Add new \(recordName)")
        
        let record = CKRecord(recordType: recordName)
        record.setValuesForKeys(user.toDictonary())
        
        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save new \(recordName): \(error.localizedDescription)")
            } else if let record {
                debugPrint("Added \(recordName) successfully: \(record.description)")
                DispatchQueue.main.async {
                    self.currentUser = user
                    print("currentUser: \(self.currentUser?.id ?? "NA")")
                }
            }
        }
    }
    
    // fetch current user info
    func fetchUser() {
        Task {
            await getCurrentUser(isChild: true)
        }
        Task {
            await getCurrentUser(isChild: false)
        }
    }
    
    func getCurrentUser(isChild: Bool) async {
        let currentUserID = await fetchiCloudUserRecordId()
        let predicate = NSPredicate(format: "\(UserModel.idKey) == %@", currentUserID)
        let query = CKQuery(recordType: isChild ? ChildModel.recordTypeKey : ParentModel.recordTypeKey, predicate: predicate)
        container.publicCloudDatabase.fetch(withQuery: query) { result in
            switch(result) {
            case .success((let result)):
                result.matchResults.compactMap { $0.1 }
                    .forEach {
                        switch $0 {
                        case .success(let record):
                            let user = isChild ? ChildModel(record: record) : ParentModel(record: record)
                            DispatchQueue.main.async {
                                self.currentUser = user
                                print("currentUser: \(self.currentUser?.id ?? "NA")")
                                self.fetchChildParent()
                                
                            }
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchChild(childID: String, completionHandler: @escaping (ChildModel) -> Void) {
        let predicate = NSPredicate(format: "\(UserModel.idKey) == %@", childID)
        let query = CKQuery(recordType: ChildModel.recordTypeKey, predicate: predicate)
        container.publicCloudDatabase.fetch(withQuery: query) { result in
            print("result: \(result)")
            switch(result) {
            case .success((let result)):
                result.matchResults.compactMap { $0.1 }
                    .forEach {
                        switch $0 {
                        case .success(let record):
                            let user = ChildModel(record: record)
                            DispatchQueue.main.async {
                                if let user {
                                    completionHandler(user)
                                }
                            }
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: Link Child to Parent
    func addChildToParent(child: UserModel, parent: UserModel) {
        
        let childRef = CKRecord.Reference(recordID: child.associatedRecord.recordID, action: .deleteSelf)
        let parentRef = CKRecord.Reference(recordID: parent.associatedRecord.recordID, action: .deleteSelf)
                
        let childParentModel = ChildParentModel()

        let record = CKRecord(recordType: ChildParentModel.recordTypeKey)
        record.setValuesForKeys(childParentModel.toDictonary(childRef: childRef, parentRef: parentRef))

        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save child to parent: \(error.localizedDescription)")
            } else if let record {
                debugPrint("Child has been successfully saved to Parent: \(record.description)")
                DispatchQueue.main.async {
                    self.childParentModel = ChildParentModel(record: record)
                    NotificationManager.shared.requestPermission()
                    
                    let predicate = NSPredicate(format: "childParentID == %@", childParentModel.id)
                    NotificationManager.shared.subscribeToNotifications(predicate: predicate)
                }
            }
        }
    }

    func fetchChildParent() {
        
        guard let currentUser = currentUser else { return }
        
        let isChild = currentUser is ChildModel ? true : false
        let fieldName = isChild ? ChildParentModel.keys.childRef : ChildParentModel.keys.parentRef
        
        let reference = CKRecord.Reference(recordID: currentUser.associatedRecord.recordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "\(fieldName) == %@", reference)
        
        let query = CKQuery(recordType: ChildParentModel.recordTypeKey, predicate: predicate)
        container.publicCloudDatabase.fetch(withQuery: query) { result in
            switch(result) {
            case .success((let result)):
                result.matchResults.compactMap { $0.1 }
                    .forEach {
                        switch $0 {
                        case .success(let record):
                            let childParentModel = ChildParentModel(record: record)
                            DispatchQueue.main.async {
                                print("fetchChildParent successfully")
                                self.childParentModel = childParentModel
                                self.fetchHomeContent()
                                if !self.isChild {
                                    NotificationManager.shared.requestPermission()
                                    
                                    guard let childParentModel = childParentModel else { return }
                                    let predicate = NSPredicate(format: "childParentID == %@", childParentModel.id)
                                    NotificationManager.shared.subscribeToNotifications(predicate: predicate)
                                }
                            }
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: PECS
    
    // (call just ONE TIME AT APP)
    // if linked fetch from HomeContent
    // else only PECS
    func addPecs(pecs: PecsModel) {
        let record = CKRecord(recordType: "CustomPecs")
        record.setValuesForKeys(pecs.toDictonary())

        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save PECS: \(error.localizedDescription)")
            } else if let record {
                debugPrint("PECS has been successfully saveded: \(record.description)")
                guard let pec = PecsModel(record: record) else { return }
                self.addHomeContent(pec: pec, isCustom: true) { homeContent in
                     DispatchQueue.main.async {
                         self.homeContents.append(homeContent)
                     }
                }
            }
        }
    }
    
    func fetchSharedPecs(completionHandler: @escaping ([PecsModel]) -> Void) {
        print("fetchPecs")
        
        var allPecs: [PecsModel] = []
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "Pecs", predicate: predicate)
        container.publicCloudDatabase.fetch(withQuery: query) { result in
            
            switch(result) {
            case .success((let result)):
                result.matchResults.compactMap { $0.1 }
                    .forEach {
                        switch $0 {
                        case .success(let record):
                            guard let pecs = PecsModel(record: record) else { return }
                            allPecs.append(pecs)
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                completionHandler(allPecs)
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchOnePecs(pecsRecordName: String, completionHandler: @escaping (PecsModel) -> Void) {
        container.publicCloudDatabase.fetch(withRecordID: CKRecord.ID(recordName: pecsRecordName)) { record, error in
            if let record {
                guard let pecs = PecsModel(record: record) else { return }
                print("fetch One Pecs")
                completionHandler(pecs)
            } else if let error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    //MARK: home content
    // For example, all pec is in table -> add its id (call juse ONE TIME for user)
    func takePecsAndAppendInHomeContent() {
        fetchSharedPecs { pecs in
            pecs.forEach { pec in
                self.addHomeContent(pec: pec, isCustom: false) { homeContent in
                    DispatchQueue.main.async {
                        self.homeContents.append(homeContent)
                    }
               }
            }
        }
    }
    
    private func addHomeContent(pec: PecsModel, isCustom: Bool, completionHandler: @escaping (HomeContent) -> Void) {
        guard let childParentModel = self.childParentModel else { return }
        let childParentRef = CKRecord.Reference(recordID: childParentModel.associatedRecord.recordID, action: .deleteSelf)
        
        let pecsRef = CKRecord.Reference(recordID: pec.associatedRecord.recordID, action: .deleteSelf)
        let customPecsRef = CKRecord.Reference(recordID: pec.associatedRecord.recordID, action: .deleteSelf)
        
        let homeContent = HomeContent(childParentRef: childParentRef, customPecsRef: nil, pecsRef: pecsRef, pecs: pec)
        let homeContentWithCustom = HomeContent(childParentRef: childParentRef, customPecsRef: customPecsRef, pecsRef: nil, pecs: pec)
        
        if isCustom {
            self.saveHomeContent(homeContent: homeContentWithCustom, completionHandler: completionHandler)
        } else {
            self.saveHomeContent(homeContent: homeContent, completionHandler: completionHandler)
        }
    }
    
    func saveHomeContent(homeContent: HomeContent, completionHandler: @escaping (HomeContent) -> Void) {
        
        let record = CKRecord(recordType: HomeContent.recordTypeKey)
        record.setValuesForKeys(homeContent.toDictonary())

        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save Home Content: \(error.localizedDescription)")
            } else if record != nil {
                debugPrint("Home Content has been successfully saveded.")
                completionHandler(homeContent)
            }
        }
    }
    
    // fetch all home content with pecs
    func fetchHomeContent() {
        
        self.homeContents = []
        
        guard let childParentModel else { return }
        let childParentRef = CKRecord.Reference(recordID: childParentModel.associatedRecord.recordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "\(HomeContent.keys.childParentRef) == %@", childParentRef)
        
        let query = CKQuery(recordType: HomeContent.recordTypeKey, predicate: predicate)
        container.publicCloudDatabase.fetch(withQuery: query) { result in
            
            switch(result) {
            case .success((let result)):
                
                if result.matchResults.count == 0 {
                    self.takePecsAndAppendInHomeContent()
                }
                
                result.matchResults.compactMap { $0.1 }
                    .forEach {
                        switch $0 {
                        case .success(let record):
                            let customPecsRef = record.value(forKey: HomeContent.keys.customPecsRef) as? CKRecord.Reference
                            let pecsRef = record.value(forKey: HomeContent.keys.pecsRef) as? CKRecord.Reference
                            
                            
                             var pecsRecordName = ""
                             
                             if let customPecsRef {
                                 pecsRecordName = customPecsRef.recordID.recordName
                             } else if let pecsRef {
                                 pecsRecordName = pecsRef.recordID.recordName
                             }
                             
                            self.fetchOnePecs(pecsRecordName: pecsRecordName) { pec in
                                guard let homeContent = HomeContent(record: record, pecs: pec) else { return }
                                DispatchQueue.main.async {
                                    print("fetchHomeContent")
                                    self.homeContents.append(homeContent)
                                    self.fetchChildRequests(homeContent: homeContent)
                                }

                            }
                            
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteHomeContent(homeContent: HomeContent) {
        let recordID = (homeContent.customPecsRef != nil) ? homeContent.pecs.associatedRecord.recordID : homeContent.associatedRecord.recordID
        container.publicCloudDatabase.delete(withRecordID: recordID) { recordID, error in
            if let error {
                debugPrint("ERROR: Failed to delete home content: \(error.localizedDescription)")
            } else if recordID != nil {
                debugPrint("\(homeContent.pecs.name) has been successfully deleted.")
                DispatchQueue.main.async {
                    self.homeContents = self.homeContents.filter { $0.id != homeContent.id }
                }
            }
        }
    }
    
    //Mark: Update Hide
    func updateHidePECS(homeContent: HomeContent, isHidden: Bool, indexSet: IndexSet){
        
        let record = homeContent.associatedRecord
                if isHidden {
                    record["isShown"] = 1
                } else {
                    record["isShown"] = 0
                }
        
        saveRecord(record: record)
        //change the record it self to the new value
    
    }
    
    //Mark: Save Record
    private func saveRecord(record: CKRecord){
        let container = container
        container.publicCloudDatabase.save(record) {[weak self] returnedRecord, returnedError in
            print("Record: \(returnedRecord)")
            print("Error: \(returnedError)")
            
            //if we need to update anything in the UI
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//
//            }

        }
    }
    //MArk: Update schedule
    func updateSchedulePECS(homeContent: HomeContent, Category: String, startTime: Date, endTime: Date ){
        let record = homeContent.associatedRecord
        
        //fetch all the records in the category to change it to the new time
    }
    //MARK: 7- Child Request
    
    func addChildRequest(homeContent: HomeContent) {
        
        let homeContentRef = CKRecord.Reference(recordID: homeContent.associatedRecord.recordID, action: .deleteSelf)
    
        let childRequest = ChildRequestModel(homeContentRef: homeContentRef, pec: homeContent.pecs)

        let record = CKRecord(recordType: ChildRequestModel.recordTypeKey)
//        record.setValuesForKeys(childRequest.toDictonary())
        
        guard let childParentModel else { return }
        var dic = childRequest.toDictonary(childParentID: childParentModel.id)
        dic["title"] = homeContent.pecs.category
        dic["content"] = "Your child wants \(homeContent.pecs.name)"
        record.setValuesForKeys(dic)

        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save child request: \(error.localizedDescription)")
            } else if let record {
                debugPrint("Child request has been successfully saveded: \(record.description)")
                guard let childRequest = ChildRequestModel(record: record, pec: homeContent.pecs) else { return }
                self.childRequests.append(childRequest)
            }
        }
    }
    
    func fetchChildRequests(homeContent: HomeContent) {

        let reference = CKRecord.Reference(recordID: homeContent.associatedRecord.recordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "\(ChildRequestModel.keys.homeContentRef) == %@", reference)
        
        let query = CKQuery(recordType: ChildRequestModel.recordTypeKey, predicate: predicate)
        container.publicCloudDatabase.fetch(withQuery: query) { result in
            
            switch(result) {
            case .success((let result)):
                result.matchResults.compactMap { $0.1 }
                    .forEach {
                        switch $0 {
                        case .success(let record):
                            guard let childRequest = ChildRequestModel(record: record, pec: homeContent.pecs) else { return }
                            
                            DispatchQueue.main.async {
                                print("fetchChildRequests")
                                self.childRequests.append(childRequest)
                            }
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
}
