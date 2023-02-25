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
    
    @Published var scrollToTopPecs = false
    @Published var scrollToTopNotification = false
    @Published var showNoLinkView = false
    
    // For PECS - without childParent
    @Published var pecs = [MainPecs]()
    @Published var isLoading = false
    
    @Published var isLoadingHome = false
    
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
        record.setValuesForKeys(user.toDictionary())
        
        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save new \(recordName): \(error.localizedDescription)")
            } else if let record {
                debugPrint("Added \(recordName) successfully: \(record.description)")
                self.fetchChildParent()
                DispatchQueue.main.async {
                    self.currentUser = user
                    print("currentUser: \(self.currentUser?.id ?? "NA")")
                    print("fetch pecs without home content")
                    self.fetchSharedPecs { pecs in
                        DispatchQueue.main.async {
                            self.pecs = pecs
                        }
                    }
                }
            }
        }
    }
    
    // delete user from his record (for switch between parent and child)
    func deleteUser() {
        if childParentModel == nil {
            guard let currentUser else { return }
            container.publicCloudDatabase.delete(withRecordID: currentUser.associatedRecord.recordID) { returnedRecord, returnedError in
                if returnedRecord != nil {
                    DispatchQueue.main.async {
                        print("User deleted successfully")
                        self.currentUser = nil
                    }
                } else if let error = returnedError {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // fetch current user info
    private func fetchUser() {
        Task {
            await getCurrentUser(isChild: true)
        }
        Task {
            await getCurrentUser(isChild: false)
        }
    }
    
    private func getCurrentUser(isChild: Bool) async {
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
        record.setValuesForKeys(childParentModel.toDictionary(childRef: childRef, parentRef: parentRef))

        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save child to parent: \(error.localizedDescription)")
            } else if let record {
                debugPrint("Child has been successfully saved to Parent: \(record.description)")
                DispatchQueue.main.async {
                    self.childParentModel = ChildParentModel(record: record)
                    self.fetchHomeContent()
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
                // if No user
                if result.matchResults.count == 0 {
                    print("fetch pecs without home content")
                    self.fetchSharedPecs { pecs in
                        DispatchQueue.main.async {
                            self.pecs = pecs
                        }
                    }
                }
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
    
    // delete relationship between child and parent
    func deleteChildParent() {
        guard let childParentModel = childParentModel else { return }
        container.publicCloudDatabase.delete(withRecordID: childParentModel.associatedRecord.recordID) { returnedRecord, returnedError in
            if returnedRecord != nil {
                DispatchQueue.main.async {
                    print("Relationship deleted successfully")
                    self.childParentModel = nil
                    print("fetch pecs without home content")
                    self.fetchSharedPecs { pecs in
                        DispatchQueue.main.async {
                            self.pecs = pecs
                        }
                    }
                }
            } else if let error = returnedError {
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: PECS
    
    // should be available for admin ONLY
    private func addMainPecs(pecs: MainPecs) {
        let record = CKRecord(recordType: "Pecs")
        record.setValuesForKeys(pecs.toDictionary())

        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save PECS: \(error.localizedDescription)")
            } else if let record {
                debugPrint("PECS has been successfully saveded: \(record.description)")
            }
        }
    }
    
    func addPecs(pecs: PecsModel, startTime: Date? = nil, endTime: Date? = nil) {
        let record = CKRecord(recordType: "CustomPecs")
        record.setValuesForKeys(pecs.toDictionary())

        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save PECS: \(error.localizedDescription)")
            } else if let record {
                debugPrint("PECS has been successfully saveded: \(record.description)")
                guard let pec = PecsModel(record: record) else { return }
                //Check the category does not have time
                
                self.addHomeContent(pec: pec, isCustom: true, startTime: startTime, endTime: endTime) { homeContent in
                     DispatchQueue.main.async {
                         if homeContent.isItTime {
                             self.homeContents.insert(homeContent, at: 0)
                         }
                     }
                }
            }
        }
    }
    
    func fetchSharedPecs(completionHandler: @escaping ([MainPecs]) -> Void) {
        print("fetchPecs")
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        var allPecs: [MainPecs] = []
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "Pecs", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: MainPecs.keys.category, ascending: true)]
        container.publicCloudDatabase.fetch(withQuery: query) { result in
            
            switch(result) {
            case .success((let result)):
                result.matchResults.compactMap { $0.1 }
                    .forEach {
                        switch $0 {
                        case .success(let record):
                            guard let pecs = MainPecs(record: record) else { return }
                            allPecs.append(pecs)
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                completionHandler(allPecs)
                
            case .failure(let error):
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchOnePecs(pecsRecordName: String, isCustom: Bool) async -> PecsModel {
        return await withCheckedContinuation { continuation in
            container.publicCloudDatabase.fetch(withRecordID: CKRecord.ID(recordName: pecsRecordName)) { record, error in
                if let record {
                    
                    guard let pecs = isCustom ? PecsModel(record: record) : MainPecs(record: record) else { return }
                    print("fetch \(isCustom ? "custom" : "main") Pecs \(pecs.name)")
                    continuation.resume(returning: pecs)
                } else if let error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    

    //MARK: home content
    // For example, all pec is in table -> add its id (call juse ONE TIME for user)
    private func takePecsAndAppendInHomeContent() {
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
    
    private func addHomeContent(pec: PecsModel, isCustom: Bool, startTime: Date? = nil, endTime: Date? = nil, completionHandler: @escaping (HomeContent) -> Void) {
        guard let childParentModel = self.childParentModel else { return }
        let childParentRef = CKRecord.Reference(recordID: childParentModel.associatedRecord.recordID, action: .deleteSelf)
        
        let pecsRef = CKRecord.Reference(recordID: pec.associatedRecord.recordID, action: .deleteSelf)
        let customPecsRef = CKRecord.Reference(recordID: pec.associatedRecord.recordID, action: .deleteSelf)
        
        let homeContent = HomeContent(childParentRef: childParentRef, customPecsRef: nil, pecsRef: pecsRef, pecs: pec)
        let homeContentWithCustom = HomeContent(childParentRef: childParentRef, customPecsRef: customPecsRef, pecsRef: nil, pecs: pec, startTime: startTime, endTime: endTime)
        
        if isCustom {
            self.saveHomeContent(homeContent: homeContentWithCustom, completionHandler: completionHandler)
        } else {
            self.saveHomeContent(homeContent: homeContent, completionHandler: completionHandler)
        }
    }
    
    private func saveHomeContent(homeContent: HomeContent, completionHandler: @escaping (HomeContent) -> Void) {
        
        let record = CKRecord(recordType: HomeContent.recordTypeKey)
        record.setValuesForKeys(homeContent.toDictionary())

        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save Home Content: \(error.localizedDescription)")
            } else if record != nil {
                debugPrint("Home Content has been successfully saveded.")
                completionHandler(homeContent)
            }
        }
    }
    
    internal func queryRecords(query: CKQuery, completionHandler: @escaping (_ results: [HomeContent]) -> Bool, errorHandler:((_ error: NSError) -> Void)? = nil) {
                let operation = CKQueryOperation(query: query)

                var results = [HomeContent]()
                operation.recordFetchedBlock = { record in
                    guard let homeContent = HomeContent(record: record) else { return }
                    print("- Append")
                    results.append(homeContent)
                }

                operation.queryCompletionBlock = { cursor, error in
                        if completionHandler(results) {
                            if cursor != nil {
                                print("- cursor")
                                self.queryRecords(cursor: cursor!, continueWithResults: results, completionHandler: completionHandler, errorHandler: errorHandler)
                            }
                        }
                }
                operation.resultsLimit = 10
                addOperation(operation: operation)
            }

        private func queryRecords(cursor: CKQueryOperation.Cursor, continueWithResults:[HomeContent], completionHandler: @escaping (_ results: [HomeContent]) -> Bool, errorHandler:((_ error: NSError) -> Void)? = nil) {
                var results = continueWithResults
                let operation = CKQueryOperation(cursor: cursor)
                operation.recordFetchedBlock = { record in
                    guard let homeContent = HomeContent(record: record) else { return }
                    print("Append")
                    results.append(homeContent)
                }

                operation.queryCompletionBlock = { cursor, error in
                        if completionHandler(results) {
                            if cursor != nil {
                                print("Cursor")
                                self.queryRecords(cursor: cursor!, continueWithResults: results, completionHandler: completionHandler, errorHandler: errorHandler)
                            } else {
                                print("No Cursor: \(results.count)")
                                DispatchQueue.main.async {
                                    self.getPecsForHomeContent()
                                }
                            }
                        }
                }
                operation.resultsLimit = 10
                addOperation(operation: operation)
            }
    
    func addOperation(operation: CKDatabaseOperation) {
        container.publicCloudDatabase.add(operation)
    }

    // fetch all home content with pecs and child requests
    func fetchHomeContent() {
        isLoadingHome = true
        DispatchQueue.main.async {
            self.homeContents.removeAll()
            self.childRequests.removeAll()
        }
        
        guard let childParentModel else { return }
        let childParentRef = CKRecord.Reference(recordID: childParentModel.associatedRecord.recordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "\(HomeContent.keys.childParentRef) == %@", childParentRef)
        
        
        let query = CKQuery(recordType: HomeContent.recordTypeKey, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: HomeContent.keys.category, ascending: true)]
        
        queryRecords(query: query) { results in
                    print("Result: \(results.count)")
                    if results.count == 0 {
                        print("No Home content..")
                        DispatchQueue.main.async {
                            self.isLoadingHome = false
                        }
                        if !self.isChild {
                            self.takePecsAndAppendInHomeContent()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.homeContents = results
                        }
                    }
                    return true
                }
//        operation.qualityOfService = .userInteractive
    }
    
    private func getPecsForHomeContent() {
        for i in homeContents.indices {
            
            getPecsHomeFromHome(homeContent: homeContents[i]) { home, load in
                DispatchQueue.main.async {
                    if self.homeContents.indices.contains(i) {
                        self.homeContents[i] = home
                    }
                    let count = self.homeContents.filter({ !$0.pecs.name.isEmpty}).count
                    print("Count: \(count) \(self.homeContents.count)")
                    if count == self.homeContents.count {
                        DispatchQueue.main.async {
                            self.isLoadingHome = false
                        }
                    }
                }
            }
            
        }
    }
    
    func getPecsHomeFromHome(homeContent: HomeContent, completionHandler: @escaping (HomeContent, Bool) -> Void) {

        let customPecsRef = homeContent.associatedRecord.value(forKey: HomeContent.keys.customPecsRef) as? CKRecord.Reference
        let pecsRef = homeContent.associatedRecord.value(forKey: HomeContent.keys.pecsRef) as? CKRecord.Reference
        var pecsRecordID: CKRecord.ID = CKRecord.ID(recordName: "na")
        var isCustom = false
        if let customPecsRef {
            pecsRecordID = customPecsRef.recordID
            isCustom = true
        } else if let pecsRef {
            pecsRecordID = pecsRef.recordID
            isCustom = false
        }
        
        let operation = CKFetchRecordsOperation(recordIDs: [pecsRecordID])
        operation.qualityOfService = .userInteractive

        operation.fetchRecordsCompletionBlock = { (records, error) in
            records?.forEach({ id, record in
                guard let pecs = isCustom ? PecsModel(record: record) : MainPecs(record: record) else { return }
                print("fetch \(isCustom ? "custom" : "main") Pecs \(pecs.name)")

                let home = HomeContent(record: homeContent.associatedRecord, pecs: pecs) ?? homeContent
                self.fetchChildRequests(homeContent: home)
                completionHandler(home, true)

            })
        }
        
        let database = self.container.publicCloudDatabase
        database.add(operation)
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
    
    // Update Hide
    func updateHidePECS(homeContent: HomeContent, completionHandler: @escaping (Bool) -> Void){
        let record = homeContent.associatedRecord
        record["isShown"] = !homeContent.isShown
        
        //saveRecord
        container.publicCloudDatabase.save(record) { returnedRecord, returnedError in
            if let returnedError {
                debugPrint("ERROR: Failed to update home content: \(returnedError.localizedDescription)")
            } else {
                debugPrint("\(homeContent.pecs.name) has been successfully updated.")
                completionHandler(true)
            }
        }
       
    }
    
    // Update schedule
        func updateSchedulePECS(category: String, startTime: Date, endTime: Date, completionHandler: @escaping (Bool) -> Void ){

           //fetch all the records from homeContent based on the category the user picked
            var filteredHomeContent = homeContents.filter({ $0.category.contains(category) })

            var updateRecords:[CKRecord] = []

            for homeContent in filteredHomeContent {
                let record = homeContent.associatedRecord

                record[HomeContent.keys.startTime] = startTime
                record[HomeContent.keys.endTime] = endTime

                updateRecords.append(record)

            }

            let operation = CKModifyRecordsOperation.init(recordsToSave: updateRecords, recordIDsToDelete: nil)

            operation.modifyRecordsCompletionBlock = { _, _, error in
                if let error = error{
                    print(error.localizedDescription)
                }
                else {
                    completionHandler(true)
                }
            }
            container.publicCloudDatabase.add(operation)

        }

    
    //MARK: Child Request
    func addChildRequest(homeContent: HomeContent) {
        
        let homeContentRef = CKRecord.Reference(recordID: homeContent.associatedRecord.recordID, action: .deleteSelf)
    
        let childRequest = ChildRequestModel(homeContentRef: homeContentRef, pec: homeContent.pecs)

        let record = CKRecord(recordType: ChildRequestModel.recordTypeKey)
//        record.setValuesForKeys(childRequest.toDictionary())
        
        guard let childParentModel else { return }
        var dic = childRequest.toDictionary(childParentID: childParentModel.id)
        dic["title"] = homeContent.pecs.category
        dic["content"] = "Your special child wants \(Helper.shared.getPicName(pecs: homeContent.pecs))"
        record.setValuesForKeys(dic)

        container.publicCloudDatabase.save(record) { record, error in
            if let error {
                debugPrint("ERROR: Failed to save child request: \(error.localizedDescription)")
            } else if let record {
                debugPrint("Child request has been successfully saveded: \(record.description)")
                guard let childRequest = ChildRequestModel(record: record, pec: homeContent.pecs) else { return }
                DispatchQueue.main.async {
                    self.childRequests.append(childRequest)
                }
            }
        }
    }
    
    func parentReadRequest(childRequest: ChildRequestModel) {
        let record = childRequest.associatedRecord
        // make it 1 -> True
        record[ChildRequestModel.keys.isRead] = 1
        saveRecord(record: record)
    }
    
    //Mark: Save Record
    private func saveRecord(record: CKRecord){
    let container = container
    container.publicCloudDatabase.save(record) {[weak self] returnedRecord, returnedError in

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
