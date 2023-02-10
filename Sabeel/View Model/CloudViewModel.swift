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
    
    func addUser(user: UserModel) {
        let recordName = user is ChildModel ? "Child" : "Parent"
        print("Add new \(recordName)")
        
        let record = CKRecord(recordType: recordName)
        record.setValuesForKeys(user.toDictonary())
        
        container.privateCloudDatabase.save(record) { record, error in
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
        performFetchUserQuery(isChild: true)
        performFetchUserQuery(isChild: false)
    }
    
    func performFetchUserQuery(isChild: Bool) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: isChild ? "Child" : "Parent", predicate: predicate)
        container.privateCloudDatabase.fetch(withQuery: query) { result in
            switch(result) {
            case .success((let result)):
                result.matchResults.compactMap { $0.1 }
                    .forEach {
                        switch $0 {
                        case .success(let record):
                            print(record)
                            let user = isChild ? ChildModel(record: record) : ParentModel(record: record)
                            DispatchQueue.main.async {
                                self.currentUser = user
                                print("currentUser: \(self.currentUser?.id ?? "NA")")
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
