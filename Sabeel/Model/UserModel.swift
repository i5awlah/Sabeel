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

struct HomeContent {
    var id: String
    var childParentRef: CKRecord.Reference
    var customPecsRef: CKRecord.Reference?
    var pecsRef: CKRecord.Reference?
    var isShown: Bool
    var startTime: Date
    var endTime: Date
    var associatedRecord: CKRecord
    var pecs: PecsModel
    
    static let recordTypeKey = "HomeContent"
    
    // For easy access to name fields
    static let keys = (
        id: "id",
        childParentRef: "childParentRef",
        customPecsRef: "customPecsRef",
        pecsRef: "pecsRef",
        isShown: "isShown",
        startTime: "startTime",
        endTime: "endTime"
    )
    
    init(childParentRef: CKRecord.Reference, customPecsRef: CKRecord.Reference? = nil, pecsRef: CKRecord.Reference? = nil, isShown: Bool = true, startTime: Date = .now, endTime: Date = .now, pecs: PecsModel) {
        self.id = UUID().uuidString
        self.childParentRef = childParentRef
        self.customPecsRef = customPecsRef
        self.pecsRef = pecsRef
        self.isShown = isShown
        self.startTime = startTime
        self.endTime = endTime
        self.associatedRecord = CKRecord(recordType: HomeContent.recordTypeKey)
        self.pecs = pecs
    }
    
    init?(record: CKRecord) {
        guard let id = record.value(forKey: HomeContent.keys.id) as? String
                , let childParentRef = record.value(forKey: HomeContent.keys.childParentRef) as? CKRecord.Reference
                , let isShown = record.value(forKey: HomeContent.keys.isShown) as? Bool
                , let startTime = record.value(forKey: HomeContent.keys.startTime) as? Date
                , let endTime = record.value(forKey: HomeContent.keys.endTime) as? Date else { return nil }

        self.id = id
        self.childParentRef = childParentRef
        self.customPecsRef = record.value(forKey: HomeContent.keys.customPecsRef) as? CKRecord.Reference
        self.pecsRef = record.value(forKey: HomeContent.keys.pecsRef) as? CKRecord.Reference
        self.isShown = isShown
        self.startTime = startTime
        self.endTime = endTime
        self.associatedRecord = record
        
        self.pecs = PecsModel(imageURL: nil, audioURL: nil, name: "", category: "")
    }

    init?(record: CKRecord, pecs: PecsModel) {
        guard let id = record.value(forKey: HomeContent.keys.id) as? String
                , let childParentRef = record.value(forKey: HomeContent.keys.childParentRef) as? CKRecord.Reference
                , let isShown = record.value(forKey: HomeContent.keys.isShown) as? Bool
                , let startTime = record.value(forKey: HomeContent.keys.startTime) as? Date
                , let endTime = record.value(forKey: HomeContent.keys.endTime) as? Date else { return nil }

        self.id = id
        self.childParentRef = childParentRef
        self.customPecsRef = record.value(forKey: HomeContent.keys.customPecsRef) as? CKRecord.Reference
        self.pecsRef = record.value(forKey: HomeContent.keys.pecsRef) as? CKRecord.Reference
        self.isShown = isShown
        self.startTime = startTime
        self.endTime = endTime
        self.associatedRecord = record
        
        self.pecs = pecs
    }
    
    
    func toDictonary() -> [String: Any] {
        var dic: [String: Any] = [
            HomeContent.keys.id: id,
            HomeContent.keys.childParentRef: childParentRef,
            HomeContent.keys.isShown: isShown,
            HomeContent.keys.startTime: startTime,
            HomeContent.keys.endTime: endTime
        ]
        
        if let pecsRef {
            dic[HomeContent.keys.pecsRef] = pecsRef
            
        } else if let customPecsRef {
            dic[HomeContent.keys.customPecsRef] = customPecsRef
        }

        
        return dic
    }
}
