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
    
    static let idKey = "id"
    
    init(recordName: String, id: String) {
        self.id = id
        self.associatedRecord = CKRecord(recordType: recordName)
    }
    
    init?(record: CKRecord) {
        guard let id = record.value(forKey: UserModel.idKey) as? String else { return nil }
        
        self.id = id
        self.associatedRecord = record
    }
    
    
    func toDictionary() -> [String: Any] {
        return [UserModel.idKey: id]
    }
}

class ChildModel: UserModel {
    
    static let recordTypeKey = "Child"
    
    init(id: String) {
        super.init(recordName: ChildModel.recordTypeKey, id: id)
    }
    
    override init?(record: CKRecord) {
        super.init(record: record)
    }
    
}

class ParentModel: UserModel {
    
    static let recordTypeKey = "Parent"
    
    init(id: String) {
        super.init(recordName: ParentModel.recordTypeKey, id: id)
    }
    
    override init?(record: CKRecord) {
        super.init(record: record)
    }
    
}
