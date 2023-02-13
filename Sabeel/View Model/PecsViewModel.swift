// Created by Einas on 12/02/2023.

import Foundation
import CloudKit

class PECSViewModel: ObservableObject {
    
    private var container: CKContainer
    @Published var iCloudAvailable: Bool = false
    @Published var currentUser: UserModel?
    
    init() {
        self.container = CKContainer.default()
        
    }
    
    //Fetch all PECS from Home_Content for one child
    //Home_Content fetches from PECS and Custom_PECS
    func fetchPECS(){
        let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: "Home_Content", predicate: predicate)
//        container.privateCloudDatabase.fetch(withQuery: query) { result in
//            switch(result) {
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
