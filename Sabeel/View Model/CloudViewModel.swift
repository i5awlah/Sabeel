//
//  CloudViewModel.swift
//  Sabeel
//
//  Created by Khawlah on 09/02/2023.
//

import Foundation
import CloudKit

class CloudViewModel: ObservableObject {
    
    private var container: CKContainer
    @Published var iCloudAvailable: Bool = false
    
    init() {
        self.container = CKContainer.default()
        getiCloudStatus()
    }
    
    func getiCloudStatus() {
        container.accountStatus { status, error in
            if status == .available {
                DispatchQueue.main.async {
                    self.iCloudAvailable = true
                }
            } else {
                DispatchQueue.main.async {
                    self.iCloudAvailable = false
                }
            }
        }
    }
    
}
