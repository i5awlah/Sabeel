//
//  PecsModel.swift
//  Sabeel
//
//  Created by Einas Alturki on 12/02/2023.
//

import CloudKit

struct Home_Content: Identifiable {
    let id: String
    let autistic_caregiver_ID : String
    let custom_Pecs_ID : String
    let pecs_ID : String
    let  is_showing: Bool
    let end_time: Date
    let start_time: Date
    var PECS : [PecsModel]
    
    var associatedRecord: CKRecord
    
    static let recordTypeKey = "HomeContent"
    
    init(id: String, autistic_caregiver_ID: String, custom_Pecs_ID: String, pecs_ID: String, is_showing: Bool, end_time: Date, start_time: Date, associatedRecord: CKRecord, PECS: [PecsModel]) {
        self.id = UUID().uuidString
        self.autistic_caregiver_ID = autistic_caregiver_ID
        self.custom_Pecs_ID = custom_Pecs_ID
        self.pecs_ID = pecs_ID
        self.is_showing = is_showing
        self.end_time = end_time
        self.start_time = start_time
        self.PECS = PECS
        self.associatedRecord = CKRecord(recordType: Home_Content.recordTypeKey)
       
    }

    //for easy access to name field
    fileprivate static let keys = (
        id: "ID",
        autistic_caregiver_ID: "autistic_caregiver_ID",
        custom_Pecs_ID: "custom_Pecs_ID",
        pecs_ID:"pecs_ID",
        is_showing : "is_showing",
        end_time : "end_time",
        start_time : "start_time",
        PECS : "PECS"
    )
}

extension Home_Content {
    init?(record: CKRecord) {
        guard
            let id = record.value(forKey: Home_Content.keys.id) as? String,
            let autistic_caregiver_ID = record.value(forKey: Home_Content.keys.autistic_caregiver_ID) as? String
                ,let custom_Pecs_ID = record.value(forKey: Home_Content.keys.custom_Pecs_ID) as? String
                ,let pecs_ID = record.value(forKey: Home_Content.keys.pecs_ID) as? String
                ,let is_showing = record.value(forKey: Home_Content.keys.is_showing) as? Bool
                , let start_time = record.value(forKey: Home_Content.keys.start_time) as? Date
                , let end_time = record.value(forKey: Home_Content.keys.end_time) as? Date
        
        else { return nil }
        
       // var PECS = record.value(forKey: Home_Content.keys.PECS) as? PecsModel
        self.id = id
        self.associatedRecord = record
        self.autistic_caregiver_ID = autistic_caregiver_ID
        self.custom_Pecs_ID = custom_Pecs_ID
        self.pecs_ID = pecs_ID
        self.is_showing = is_showing
        self.start_time = start_time
        self.end_time = end_time
        self.PECS = []
        self.associatedRecord = record

        if custom_Pecs_ID.isEmpty {
            self.PECS = fetchPECS(ID: pecs_ID, recordType:"PECS")
        }else { // check if we need the autistic_caregiver_ID
            self.PECS = fetchPECS(ID:custom_Pecs_ID, recordType:"Custom_PECS")
        }

    }
    
    func fetchPECS(ID: String, recordType: String) -> [PecsModel] {
        let predicate = NSPredicate(format: "\(recordType)_id =%@", ID)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)

        var returnedPECS : [PecsModel] = []
        queryOperation.recordMatchedBlock = { (returnedRecordID, returnedResult) in
            switch returnedResult{
            case .success(let record):
                guard let PECS_id = record["\(recordType)_id"] as? String else {return}
                guard let category = record["category"] as? String else {return}
                guard let name = record["name"] as? String else {return}
                let imageAsset = record["imageURL"] as? CKAsset
                let imageURL = imageAsset?.fileURL
                let AudioAsset = record["audioURL"] as? CKAsset
                let audioURL = AudioAsset?.fileURL

                returnedPECS.append(PecsModel(id: PECS_id,
                                                   category: category,
                                                   imageURL: imageURL,
                                                   audioURL: audioURL,
                                                   name: name,
                                                   associatedRecord: record))

            case .failure(let error):
                print("Error recordMatchBlock : \(error)")
            }
        }

        return returnedPECS
    }

    func toDictionary() -> [String: Any] {

        var dictionary : [String: Any] = [
            Home_Content.keys.autistic_caregiver_ID : autistic_caregiver_ID,
            Home_Content.keys.custom_Pecs_ID : custom_Pecs_ID,
            Home_Content.keys.pecs_ID : pecs_ID,
            Home_Content.keys.is_showing : is_showing,
            Home_Content.keys.start_time : start_time,
            Home_Content.keys.end_time : end_time,
            Home_Content.keys.PECS : PECS
            
        ]

        return dictionary
    }
}

struct PecsModel: Identifiable {
    let id: String
    let category: String
    let imageURL: URL?
    let audioURL: URL?
    let name: String
    let associatedRecord: CKRecord

    static let recordTypeKey = "PECS"
    
    init(id: String, category: String, imageURL: URL?, audioURL: URL?, name: String, associatedRecord: CKRecord) {
        self.id = id
        self.category = category
        self.imageURL = imageURL
        self.audioURL = audioURL
        self.name = name
        self.associatedRecord = CKRecord(recordType: PecsModel.recordTypeKey)
    }
    // For easy access to name fields
    fileprivate static let keys = (
        category: "category",
        imageURL: "imageURL",
        audioURL: "audioURL",
        name: "name"
    )
}

//extension PecsModel {
//    init?(record: CKRecord) {
//        guard let name = record.value(forKey: PecsModel.keys.name) as? String
//                ,let category = record.value(forKey: PecsModel.keys.category) as? String
//                
//        else { return nil }
//
//        self.id = record.recordID.recordName
//        self.associatedRecord = record
//        self.name = name
//        self.category = category
//        
//
//        let imageAsset = record.value(forKey: PecsModel.keys.imageURL) as? CKAsset
//        self.imageURL = imageAsset?.fileURL
//
//        let audioAsset = record.value(forKey: PecsModel.keys.audioURL) as? CKAsset
//        self.audioURL = audioAsset?.fileURL
//    }
//
//    func toDictionary() -> [String: Any] {
//
//        var dictionary : [String: Any] = [
//            PecsModel.keys.name : name,
//            PecsModel.keys.category : category
//            
//        ]
//
//        if let imageURL {
//            dictionary[PecsModel.keys.imageURL] = CKAsset(fileURL: imageURL)
//        }
//        if let audioURL {
//            dictionary[PecsModel.keys.audioURL] = CKAsset(fileURL: audioURL)
//        }
//
//        return dictionary
//    }
//}
//struct Home_Content: Hashable {
//    let id: String
//    let autistic_caregiver_ID : String
//    let custom_Pecs_ID : String
//    let pecs_ID : String
//    let associatedRecord: CKRecord
//    let PECS : PecsModel
//    //for easy access to name field
//
//}
//
//
//
//struct PecsModel: Hashable {
//    let id: String
//    let category: String
//    let imageURL: URL?
//    let audioURL: URL?
//    let name: String
////    let is_showing: Bool
////    var startTime: Date
////    var endTime: Date
//    let associatedRecord: CKRecord
//
//
//}

