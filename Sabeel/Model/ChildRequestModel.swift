//
//  ChildRequestModel.swift
//  Sabeel
//
//  Created by Khawlah on 20/02/2023.
//

import CloudKit

struct ChildRequestModel {
    var id: String
    var associatedRecord: CKRecord
    var homeContentRef: CKRecord.Reference
    var pecs: PecsModel
    var isRead: Bool = false
    
    static let recordTypeKey = "ChildRequest"
    
    // For easy access to name fields
    static let keys = (
        id: "id",
        isRead: "isRead",
        homeContentRef: "homeContentRef",
        childParentID: "childParentID"
    )
    
    init(homeContentRef: CKRecord.Reference, pec: PecsModel) {
        self.id = UUID().uuidString
        self.associatedRecord = CKRecord(recordType: ChildRequestModel.recordTypeKey)
        self.homeContentRef = homeContentRef
        self.pecs = pec
    }
    
    init?(record: CKRecord, pec: PecsModel) {
        guard let id = record.value(forKey: ChildRequestModel.keys.id) as? String
                , let homeContentRef = record.value(forKey: ChildRequestModel.keys.homeContentRef) as? CKRecord.Reference else { return nil }

        self.id = id
        self.isRead = record.value(forKey: ChildRequestModel.keys.isRead) as? Bool ?? false
        self.homeContentRef = homeContentRef
        self.associatedRecord = record
        self.pecs = pec
    }
    
    
    func toDictonary(childParentID: String) -> [String: Any] {
        return [
            ChildRequestModel.keys.id: id,
            ChildRequestModel.keys.isRead: isRead,
            ChildRequestModel.keys.homeContentRef: homeContentRef,
            ChildRequestModel.keys.childParentID : childParentID
        ]
    }
}
