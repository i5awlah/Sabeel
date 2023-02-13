//
//  PecsViewModel.swift
//  Sabeel
//
// Created by Einas on 12/02/2023.
//
import Foundation
import CloudKit

class PECSViewModel: ObservableObject {
    
    private var container: CKContainer
    @Published var iCloudAvailable: Bool = false
    @Published var currentUser: UserModel?
    var userID = "1"
    @Published var returnedContent: [Home_Content] = []
    @Published var returnedPECS: [PecsModel] = []
    
    init() {
        self.container = CKContainer.default()
        
    }
    
    //Fetch all PECS from Home_Content for this child
    //Home_Content fetches from PECS and Custom_PECS
    //1- Fetch PECS_ID  from Home_Content
    //2- loop each PECS_ID to retrieve their content from PECS record
    
    //repeat the same steps 1 and 2 but for the customize_PECs
    
 
    func fetchPECS_Content(){

        let predicate = NSPredicate(format: "autistic_caregiver_ID =%@", userID)
        let query = CKQuery(recordType: "Home_Content", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        
        queryOperation.recordMatchedBlock = { (returnedRecordID, returnedResult) in
            switch returnedResult{
            case .success(let record):
                guard let autistic_caregiver_ID = record["autistic_caregiver_ID"] as? String else {return}
                guard let custom_Pecs_ID = record["custom_Pecs_ID"] as? String else {return}
                guard let pecs_ID = record["pecs_ID"] as? String else {return}
                returnedContent.append(Home_Content(id: "1", autistic_caregiver_ID: autistic_caregiver_ID, custom_Pecs_ID: custom_Pecs_ID, pecs_ID: pecs_ID, associatedRecord: record))
                
                if custom_Pecs_ID.isEmpty {
                    self.fetchPECS(ID: pecs_ID)
                }else {
                    self.fetchCustomPECS(ID:custom_Pecs_ID)
                }
                
            case .failure(let error):
                print("Error recordMatchBlock : \(error)")
            }
        }
        
    }
    
    func fetchPECS(ID: String){
        let predicate = NSPredicate(format: "PECS_id =%@", ID)
        let query = CKQuery(recordType: "PECS", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
    }
    
    func fetchCustomPECS(ID:String){
        
    }
    // 1- Delete PECS form Home_Content the record that refers to it
    // 2- Check the PECS TYPE if it is PECS or Custom PECS
    //      2.1 if it's Custom PECS delete it from Home_Content and Custom_PECS
    //      2-2 if it's PECS delete the record only from Home_Content
    //NEVER DELETE FROM PECS TABLE
    func deletePECS(){
        
    }
    
    func hidePECS(){
        
    }
    
    
}
