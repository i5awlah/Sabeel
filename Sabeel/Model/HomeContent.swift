//
//  HomeContent.swift
//  Sabeel
//
//  Created by Khawlah on 20/02/2023.
//

import CloudKit

struct HomeContent {
    var id: String
    var category: String
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
        category: "category",
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
        self.category = pecs.category
    }
    
    init?(record: CKRecord) {
        guard let id = record.value(forKey: HomeContent.keys.id) as? String
                , let category = record.value(forKey: HomeContent.keys.category) as? String
                , let childParentRef = record.value(forKey: HomeContent.keys.childParentRef) as? CKRecord.Reference
                , let isShown = record.value(forKey: HomeContent.keys.isShown) as? Bool
                , let startTime = record.value(forKey: HomeContent.keys.startTime) as? Date
                , let endTime = record.value(forKey: HomeContent.keys.endTime) as? Date else { return nil }

        self.id = id
        self.category = category
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
                , let category = record.value(forKey: HomeContent.keys.category) as? String
                , let childParentRef = record.value(forKey: HomeContent.keys.childParentRef) as? CKRecord.Reference
                , let isShown = record.value(forKey: HomeContent.keys.isShown) as? Bool
                , let startTime = record.value(forKey: HomeContent.keys.startTime) as? Date
                , let endTime = record.value(forKey: HomeContent.keys.endTime) as? Date else { return nil }

        self.id = id
        self.category = category
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
            HomeContent.keys.category: category,
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
