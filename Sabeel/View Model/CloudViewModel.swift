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
                }
            }
        }
    }
    
    func fetchChildParent() {
        print("fetchChildParent")
        
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
                                self.childParentModel = childParentModel
                                //print("childRef: \(self.childParentModel?.childRef)")
                                //print("parentRef: \(self.childParentModel?.parentRef)")
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
