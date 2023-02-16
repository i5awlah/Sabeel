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
        fetchUser()
    }
    
    func getiCloudStatus() {
        container.accountStatus { status, error in
            if status == .available {
                DispatchQueue.main.async {
                    self.iCloudAvailable = true
                }
            } else {
                DispatchQueue.main.async {
                    self.iCloudAvailable = false
                }
            }
        }
    }
    
    func fetchiCloudUserRecordId() async -> String {
        return await withCheckedContinuation { continuation in
            container.fetchUserRecordID { recordID, error in
                if let recordID = recordID {
                    continuation.resume(returning: recordID.recordName)
                }
            }
        }
    }
    
    func addUser(user: UserModel) {
        let recordName = user is ChildModel ? ChildModel.recordTypeKey : ParentModel.recordTypeKey
        print("Add new \(recordName)")
        
        let record = CKRecord(recordType: recordName)
        record.setValuesForKeys(user.toDictonary())
        
        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save new \(recordName): \(error.localizedDescription)")
            } else if let record {
                debugPrint("Successfully to save new \(recordName): \(record.description)")
                DispatchQueue.main.async {
                    self.currentUser = user
                    print("currentUser: \(self.currentUser?.id ?? "NA")")
                }
            }
        }
    }
    
    func fetchUser() {
        Task {
            await performFetchUserQuery(isChild: true)
        }
        Task {
            await performFetchUserQuery(isChild: false)
        }
    }
    
    func performFetchUserQuery(isChild: Bool) async {
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
    
    func fetchUser(id: String, isChild: Bool, completionHandler: @escaping (UserModel) -> Void) {
        print("id: \(id)")
        print("Name: \(isChild ? ChildModel.recordTypeKey : ParentModel.recordTypeKey)")
        let predicate = NSPredicate(format: "\(UserModel.idKey) == %@", id)
        let query = CKQuery(recordType: isChild ? ChildModel.recordTypeKey : ParentModel.recordTypeKey, predicate: predicate)
        container.publicCloudDatabase.fetch(withQuery: query) { result in
            print("result: \(result)")
            switch(result) {
            case .success((let result)):
                result.matchResults.compactMap { $0.1 }
                    .forEach {
                        switch $0 {
                        case .success(let record):
                            let user = isChild ? ChildModel(record: record) : ParentModel(record: record)
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
                                print("SUCCESS: fetchChildParent")
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
    
    //MARK: 4,5 pecs and custom pecs
    
    // (call just ONE TIME AT APP)
    // if linked fetch from HomeContent
    // else only PECS
    func addPecs(pecs: PecsModel) {
        let record = CKRecord(recordType: PecsModel.recordTypeKey)
        record.setValuesForKeys(pecs.toDictonary())

        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save PECS: \(error.localizedDescription)")
            } else if let record {
                debugPrint("PECS has been successfully saveded: \(record.description)")
            }
        }
    }
    
    func fetchPecs(completionHandler: @escaping ([PecsModel]) -> Void) {
        print("fetchPecs")
        
        var allPecs: [PecsModel] = []
        
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: PecsModel.recordTypeKey, predicate: predicate)
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
    
    func addCustomPecs(pecs: CustomPecsModel) {
        guard let childParentModel else { return }
        let childParentRef = CKRecord.Reference(recordID: childParentModel.associatedRecord.recordID, action: .deleteSelf)
        
        let record = CKRecord(recordType: CustomPecsModel.recordType)
        record.setValuesForKeys(pecs.toDictonary(childParentRef: childParentRef))

        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save PECS: \(error.localizedDescription)")
            } else if let record {
                debugPrint("PECS has been successfully saveded: \(record.description)")
            }
        }
    }
    
    func fetchCustomPecs(completionHandler: @escaping ([CustomPecsModel]) -> Void) {
        print("fetchCustomPecs")
        
        var allPecs: [CustomPecsModel] = []
        
        guard let childParentModel else { return }
        let childParentRef = CKRecord.Reference(recordID: childParentModel.associatedRecord.recordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "\(HomeContent.keys.childParentRef) == %@", childParentRef)
        
        let query = CKQuery(recordType: CustomPecsModel.recordType, predicate: predicate)
        container.publicCloudDatabase.fetch(withQuery: query) { result in
            
            switch(result) {
            case .success((let result)):
                result.matchResults.compactMap { $0.1 }
                    .forEach {
                        switch $0 {
                        case .success(let record):
                            guard let customPecs = CustomPecsModel(record: record) else { return }
                            allPecs.append(customPecs)
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
    
    // All pecs alerady join i want to add its id (call juse ONE TIME for user)
    func takePecsAndAppendInHomeContent() {
        fetchPecs { pecs in
            
            guard let childParentModel = self.childParentModel else { return }
            let childParentRef = CKRecord.Reference(recordID: childParentModel.associatedRecord.recordID, action: .deleteSelf)
            
            pecs.forEach { pec in
                let pecsRef = CKRecord.Reference(recordID: pec.associatedRecord.recordID, action: .deleteSelf)
                
                let homeContent = HomeContent(childParentRef: childParentRef, customPecsRef: nil, pecsRef: pecsRef)
                self.addHomeContent(homeContent: homeContent, pecsID: pec.id)
            }
        }
    }
    
    //MARK: 6- home content
    
    func addHomeContent(homeContent: HomeContent, pecsID: String) {
        
        let record = CKRecord(recordType: HomeContent.recordTypeKey)
        record.setValuesForKeys(homeContent.toDictonary())

        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save Home Content: \(error.localizedDescription)")
            } else if let record {
                debugPrint("Home Content has been successfully saveded: \(record.description)")
            }
        }
    }
    
    func fetchHomeContent() {
        print("fetchHomeContent")
        
        guard let childParentModel else { return }
        let childParentRef = CKRecord.Reference(recordID: childParentModel.associatedRecord.recordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "\(HomeContent.keys.childParentRef) == %@", childParentRef)
        
        let query = CKQuery(recordType: HomeContent.recordTypeKey, predicate: predicate)
        container.publicCloudDatabase.fetch(withQuery: query) { result in
            
            switch(result) {
            case .success((let result)):
                
                result.matchResults.compactMap { $0.1 }
                    .forEach {
                        switch $0 {
                        case .success(let record):
                            let customPecsRef = record.value(forKey: HomeContent.keys.customPecsRef) as? CKRecord.Reference
                            let pecsRef = record.value(forKey: HomeContent.keys.pecsRef) as? CKRecord.Reference
                            
                            if let customPecsRef {
                                self.fetchOnePecs(customPecsRef: customPecsRef, pecsRef: nil) { pec in
                                    guard let homeContent = HomeContent(record: record, pecs: pec) else { return }
                                    DispatchQueue.main.async {
                                        self.homeContents.append(homeContent)
                                        self.fetchChildRequests(homeContent: homeContent)
                                    }
                                }
                            } else if let pecsRef {
                                self.fetchOnePecs(customPecsRef: nil, pecsRef: pecsRef) { pec in
                                    guard let homeContent = HomeContent(record: record, pecs: pec) else { return }
                                    DispatchQueue.main.async {
                                        self.homeContents.append(homeContent)
                                        self.fetchChildRequests(homeContent: homeContent)
                                    }
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
    
    func fetchOnePecs(customPecsRef: CKRecord.Reference?, pecsRef: CKRecord.Reference?, completionHandler: @escaping (PecsModel) -> Void) {
        print("fetchPecs")
        
        var id = ""
        
        if let customPecsRef {
            id = customPecsRef.recordID.recordName
        } else if let pecsRef {
            id = pecsRef.recordID.recordName
        }
        
        container.publicCloudDatabase.fetch(withRecordID: CKRecord.ID(recordName: id)) { record, error in
            if let record {
                guard let pecs = PecsModel(record: record) else { return }
                completionHandler(pecs)
            } else if let error {
                print("Error: \(error.localizedDescription)")
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
        dic["title"] = homeContent.pecs.name
        dic["content"] = homeContent.pecs.name
        record.setValuesForKeys(dic)

        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save child request: \(error.localizedDescription)")
            } else if let record {
                debugPrint("Child request has been successfully saveded: \(record.description)")
            }
        }
    }
    
    func fetchChildRequests(homeContent: HomeContent) {

        print("fetchChildRequests")
        
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
