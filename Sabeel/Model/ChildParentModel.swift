//
//  ChildParentModel.swift
//  Sabeel
//
//  Created by Khawlah on 20/02/2023.
//

import CloudKit

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
