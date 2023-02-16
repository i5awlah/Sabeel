//
//  PecsModel.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import CloudKit

class PecsModel: Identifiable {
    let id: String
    let imageURL: URL?
    let audioURL: URL?
    let name: String
    let category: String
    let associatedRecord: CKRecord
    
    static var recordTypeKey: String { "Pecs" }
    
    // For easy access to name fields
    static let keys = (
        imageURL: "imageURL",
        audioURL: "audioURL",
        id : "id",
        name : "name",
        category : "category"
    )
    
    init(imageURL: URL?, audioURL: URL?, name: String, category: String) {
        self.id = UUID().uuidString
        self.imageURL = imageURL
        self.audioURL = audioURL
        self.name = name
        self.category = category
        self.associatedRecord = CKRecord(recordType: PecsModel.recordTypeKey)
    }
    
    init?(record: CKRecord) {
        guard let name = record.value(forKey: PecsModel.keys.name) as? String
                , let category = record.value(forKey: PecsModel.keys.category) as? String else { return nil }

        self.id = record.recordID.recordName
        self.associatedRecord = record
        self.name = name
        self.category = category

        let imageAsset = record.value(forKey: PecsModel.keys.imageURL) as? CKAsset
        self.imageURL = imageAsset?.fileURL

        let audioAsset = record.value(forKey: PecsModel.keys.audioURL) as? CKAsset
        self.audioURL = audioAsset?.fileURL
    }
    
}

extension PecsModel {
    
    func toDictonary() -> [String: Any] {
        
        var dictonary : [String: Any] = [
            PecsModel.keys.id : id,
            PecsModel.keys.name : name,
            PecsModel.keys.category : category
        ]
        
        if let imageURL {
            dictonary[PecsModel.keys.imageURL] = CKAsset(fileURL: imageURL)
        }
        if let audioURL {
            dictonary[PecsModel.keys.audioURL] = CKAsset(fileURL: audioURL)
        }
        
        return dictonary
    }
}

class CustomPecsModel: PecsModel {
    var childParentRef: CKRecord.Reference?
    
    static var recordType: String { "CustomPecs" }
    
    // For easy access to name fields
    static let childParentRef = (
        "childParentRef"
    )
    
    
    override init(imageURL: URL?, audioURL: URL?, name: String, category: String) {
        super.init(imageURL: imageURL, audioURL: audioURL, name: name, category: category)
    }
    
    override init?(record: CKRecord) {
        self.childParentRef = record.value(forKey: ChildParentModel.keys.childRef) as? CKRecord.Reference
        super.init(record: record)
    }
    
    func toDictonary(childParentRef: CKRecord.Reference) -> [String: Any] {
        var dic: [String: Any] = [:]
        dic = super.toDictonary()
        dic [CustomPecsModel.childParentRef] = childParentRef
        return dic
    }
}
