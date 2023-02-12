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
    
    
    func toDictonary() -> [String: Any] {
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

class ChildParentModel {
    var id: String
    var associatedRecord: CKRecord
    var childRef: CKRecord.Reference?
    var parentRef: CKRecord.Reference?
    
    static let recordTypeKey = "childParent"
    
    // For easy access to name fields
    static let keys = (
        id: "id",
        childRef: "childRef",
        parentRef: "parentRef"
    )
    
    
    init() {
        self.id = UUID().uuidString
        self.associatedRecord = CKRecord(recordType: ChildParentModel.recordTypeKey)
    }
    
    init?(record: CKRecord) {
        guard let id = record.value(forKey: ChildParentModel.keys.id) as? String else { return nil }

        self.id = id
        self.childRef = record.value(forKey: ChildParentModel.keys.childRef) as? CKRecord.Reference
        self.parentRef = record.value(forKey: ChildParentModel.keys.parentRef) as? CKRecord.Reference
        self.associatedRecord = record
    }
    
    
    func toDictonary(childRef: CKRecord.Reference, parentRef: CKRecord.Reference) -> [String: Any] {
        return [
            ChildParentModel.keys.id: id,
            ChildParentModel.keys.childRef: childRef,
            ChildParentModel.keys.parentRef: parentRef
        ]
    }
}
