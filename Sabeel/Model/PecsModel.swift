//
//  PecsModel.swift
//  Sabeel
//
//  Created by Einas Alturki on 12/02/2023.
//

import CloudKit

struct PecsModel: Identifiable {
    let id: String
    let category: String
    let imageURL: URL?
    let audioURL: URL?
    let name: String
//    var startTime: Date
//    var endTime: Date
    let associatedRecord: CKRecord
    
    // For easy access to name fields
    fileprivate static let keys = (
        category: "category",
        imageURL: "imageURL",
        audioURL: "audioURL",
        name: "name"
//        startTime : "startTime",
//        endTime : "endTime"
    )
}

extension PecsModel {
    init?(record: CKRecord) {
        guard let name = record.value(forKey: PecsModel.keys.name) as? String
                ,let category = record.value(forKey: PecsModel.keys.category) as? String
//                , let startTime = record.value(forKey: PecsModel.keys.startTime) as? Date
//                , let endTime = record.value(forKey: PecsModel.keys.endTime) as? Date
        else { return nil }
        
        self.id = record.recordID.recordName
        self.associatedRecord = record
        self.name = name
        self.category = category
//        self.startTime = startTime
//        self.endTime = endTime
        
        let imageAsset = record.value(forKey: PecsModel.keys.imageURL) as? CKAsset
        self.imageURL = imageAsset?.fileURL
        
        let audioAsset = record.value(forKey: PecsModel.keys.audioURL) as? CKAsset
        self.audioURL = audioAsset?.fileURL
    }
    
    func toDictonary() -> [String: Any] {
        
        var dictonary : [String: Any] = [
            PecsModel.keys.name : name,
            PecsModel.keys.category : category
//            ,PecsModel.keys.startTime : startTime,
//            PecsModel.keys.endTime : endTime
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
