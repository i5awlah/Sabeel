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
        self.associatedRecord = CKRecord(recordType: "CustomPecs")
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

class MainPecs: PecsModel {
    let arabicAudioURL: URL?
    let arabicName: String
    let arabicCategory: String
    
    // For easy access to name fields
    let keys = (
        arabicAudioURL: "arabicAudioURL",
        arabicName: "arabicName",
        arabicCategory : "arabicCategory"
    )
    
    init(imageURL: URL?, audioURL: URL?, name: String, category: String, arabicAudioURL: URL?, arabicName: String, arabicCategory: String) {
        self.arabicAudioURL = arabicAudioURL
        self.arabicName = arabicName
        self.arabicCategory = arabicCategory
        super.init(imageURL: imageURL, audioURL: audioURL, name: name, category: category)
    }
    
    override init?(record: CKRecord) {
        guard let arabicName = record.value(forKey: keys.arabicName) as? String
                , let arabicCategory = record.value(forKey: keys.arabicCategory) as? String else { return nil }

        
        self.arabicName = arabicName
        self.arabicCategory = arabicCategory

        let audioAsset = record.value(forKey: keys.arabicAudioURL) as? CKAsset
        self.arabicAudioURL = audioAsset?.fileURL
        
        super.init(record: record)
    }
    
    override func toDictonary() -> [String: Any] {
        
        var dictonary = super.toDictonary()
        
        dictonary[keys.arabicName] = arabicName
        dictonary[keys.arabicCategory] = arabicCategory
        
        if let arabicAudioURL {
            dictonary[keys.arabicAudioURL] = CKAsset(fileURL: arabicAudioURL)
        }
        
        return dictonary
    }
}
