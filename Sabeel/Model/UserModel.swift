//
//  UserModel.swift
//  Sabeel
//
//  Created by Khawlah on 10/02/2023.
//


import CloudKit

class UserModel {
    var id: String
    var associatedRecord: CKRecord
    
    init(recordName: String) {
        self.id = UUID().uuidString
        self.associatedRecord = CKRecord(recordType: recordName)
    }
    
    init?(record: CKRecord) {
        guard let id = record.value(forKey: "id") as? String else { return nil }
        
        self.id = id
        self.associatedRecord = record
    }
    
    
    func toDictonary() -> [String: Any] {
        return ["id": id]
    }
}

class ChildModel: UserModel {
    
    init() {
        super.init(recordName: "Child")
    }
    
    override init?(record: CKRecord) {
        super.init(record: record)
    }
    
}

class ParentModel: UserModel {
    
    init() {
        super.init(recordName: "Parent")
    }
    
    override init?(record: CKRecord) {
        super.init(record: record)
    }
    
}

