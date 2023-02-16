////
////  PecsViewModel.swift
////  Sabeel
////
//// Created by Einas on 12/02/2023.
////
//import Foundation
//import CloudKit
//
//class PECSViewModel: ObservableObject {
//    
//    private var container: CKContainer
//    @Published var iCloudAvailable: Bool = false
//    @Published var currentUser: UserModel?
//    var userID = "child1"
//    @Published var allPECS: [Home_Content] = []
//    @Published var returnedPECS : [PecsModel] = []
//    
//    init() {
//        self.container = CKContainer(identifier: "iCloud.icloude.Sabeel")
//        fetchHome_Content()
//        
//    }
//    
//    //Fetch all PECS from Home_Content for this child
//    //Home_Content fetches from PECS and Custom_PECS
//    //1- Fetch PECS_ID  from Home_Content
//    //2- loop each PECS_ID to retrieve their content from PECS record
//    
//    //repeat the same steps 1 and 2 but for the customize_PECs
//    
//// //previous fetch
////    func fetchHome_Content(){
////
////        let predicate = NSPredicate(format: "autistic_caregiver_ID =%@", userID)
////        let query = CKQuery(recordType: "Home_Content", predicate: predicate)
////
////     var allHomeContent : [Home_Content] = []
////
////        container.publicCloudDatabase.fetch(withQuery: query) { result in
////            switch(result) {
////            case .success((let result)):
////                result.matchResults.compactMap { $0.1 }
////                    .forEach {
////                        switch $0 {
////                        case .success(let record):
////
////                            //fetch the PECS here
////
////                            guard let home_Content = Home_Content(record: record) else { return}
////
////                            allHomeContent.append(Home_Content(id: home_Content.id, autistic_caregiver_ID: home_Content.pecs_ID, custom_Pecs_ID: home_Content.custom_Pecs_ID, pecs_ID: home_Content.pecs_ID, is_showing: home_Content.is_showing, end_time: home_Content.end_time, start_time: home_Content.start_time, associatedRecord: home_Content.associatedRecord, PECS: home_Content.PECS))
////
////
////                    case .failure(let error):
////                        print("Error: \(error.localizedDescription)")
////                    }
////
////            }
////            case .failure(let error):
////                print("Error recordMatchBlock : \(error)")
////            }
////            self.allPECS = allHomeContent
////        }
////
////    }
////    func fetchPECS(ID: String, recordType: String) -> PecsModel {
////        let predicate = NSPredicate(format: "\(recordType)_id =%@", ID)
////        let query = CKQuery(recordType: recordType, predicate: predicate)
////        let queryOperation = CKQueryOperation(query: query)
////
////        var returnedPECS : [PecsModel] = []
////
////        queryOperation.recordMatchedBlock = { (returnedRecordID, returnedResult) in
////            switch returnedResult{
////            case .success(let record):
////                guard let PECS_id = record["PECS_id"] as? String else {return}
////                guard let category = record["category"] as? String else {return}
////                guard let name = record["name"] as? String else {return}
////                let imageAsset = record["imageURL"] as? CKAsset
////                let imageURL = imageAsset?.fileURL
////                let AudioAsset = record["audioURL"] as? CKAsset
////                let audioURL = AudioAsset?.fileURL
////
////                returnedPECS.append(PecsModel(id: PECS_id,
////                                              category: category,
////                                              imageURL: imageURL,
////                                              audioURL: audioURL,
////                                              name: name,
////                                              associatedRecord: record))
////
////                return returnedPECS
////            case .failure(let error):
////                print("Error recordMatchBlock : \(error)")
////            }
////        }
////
////    }
//    
//    func fetchHome_Content(){
//        let predicate = NSPredicate(format: "autistic_caregiver_ID =%@", userID)
//        let query = CKQuery(recordType: "HomeContent", predicate: predicate)
//        let queryOperation = CKQueryOperation(query: query)
//        
//        var HomeContent : [Home_Content] = []
//        
//        
//        queryOperation.recordMatchedBlock = { (returnedRecordID, returnedResult) in
//            switch returnedResult{
//            case .success(let record):
//                
//                guard let ID = record["ID"] as? String else {return}
//                print(ID)
//                guard let autistic_caregiver_ID = record["autistic_caregiver_ID"] as? String else {return}
//                print(autistic_caregiver_ID)
//                let custom_Pecs_ID = record["custom_Pecs_ID"] as? String
//                print(custom_Pecs_ID)
//                let pecs_ID = record["PECS_ID"] as? String
//                print(pecs_ID)
//                let is_showing = record["is_showing"] as? Bool
//                print(is_showing)
//                let start_time = record["start_time"] as? Date
//                print(start_time)
//                let end_time = record["end_time"] as? Date
//                print(end_time)
//                
//                if custom_Pecs_ID. {
//                     self.fetchPECS(ID: pecs_ID, recordType:"PECS")
//                }else {
//                    self.fetchPECS(ID:custom_Pecs_ID, recordType:"Custom_PECS")
//                }
//                
//                HomeContent.append(Home_Content(autistic_caregiver_ID: autistic_caregiver_ID, custom_Pecs_ID: custom_Pecs_ID, pecs_ID: pecs_ID, is_showing: is_showing, startTime: start_time, endTime: end_time,
//                                                //PECS: returnedPECS,
//                                                associatedRecord: record))
//                
//            case .failure(let error):
//                print("Error Home Content recordMatchBlock: \(error)")
//            }
//        }
//        queryOperation.queryResultBlock = { [weak self] returnedResult in
//            print("Returned Result: \(returnedResult)")
//            DispatchQueue.main.async {
//                self?.allPECS = HomeContent
//            }
//        }
//        addOperation(operation: queryOperation)
//    }
//    
//    func fetchPECS(ID: String, recordType: String){
//        let predicate = NSPredicate(format: "\(recordType)_id =%@", ID)
//        let query = CKQuery(recordType: recordType, predicate: predicate)
//        let queryOperation = CKQueryOperation(query: query)
//        
//        var returnedPECS : [PecsModel] = []
//        
//        queryOperation.recordMatchedBlock = { (returnedRecordID, returnedResult) in
//            switch returnedResult{
//            case .success(let record):
//                guard let PECS_id = record["\(recordType)_id"] as? String else {return}
//                guard let category = record["category"] as? String else {return}
//                guard let name = record["name"] as? String else {return}
//                let imageAsset = record["imageURL"] as? CKAsset
//                let imageURL = imageAsset?.fileURL
//                //                let AudioAsset = record["audioURL"] as? CKAsset
//                //                let audioURL = AudioAsset?.fileURL
//                
//                returnedPECS.append(PecsModel(PECS_id: PECS_id,
//                                              category: category,
//                                              name: name,
//                                              imageURL: imageURL,
//                                              //audioURL: audioURL,
//                                              associatedRecord: record))
//                
//            case .failure(let error):
//                print("Error PECS recordMatchBlock:\(error)")
//            }
//        }
//        queryOperation.queryResultBlock = { [weak self] returnedResult in
//            print("Returned Result: \(returnedResult)")
//            DispatchQueue.main.async {
//                self?.returnedPECS = returnedPECS
//            }
//        }
//    addOperation(operation: queryOperation)
//    }
//    
//    func addOperation(operation: CKDatabaseOperation){
//        let container = CKContainer(identifier: "iCloud.icloude.Sabeel")
//        container.publicCloudDatabase.add(operation)
//    }
//    
//    //Delete
//    
//    // 1- Delete PECS form Home_Content the record that refers to it
//    //    NEVER DELETE FROM PECS TABLE
//    
//    // 2- Check the PECS TYPE if it is PECS or Custom PECS
//    //      2.1 if it's Custom PECS delete it from Home_Content and Custom_PECS
//    //      2-2 if it's PECS delete the record only from Home_Content
//    
//    func deletePECS(){
//        
//    }
//    
//    func hidePECS(){
//        
//    }
//    
//    
//}
