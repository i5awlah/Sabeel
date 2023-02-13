//
//  AddChildView.swift
//  Sabeel
//
//  Created by Khawlah on 12/02/2023.
//

import SwiftUI

struct AddChildView: View {
    
    @EnvironmentObject var cloudViewModel: CloudViewModel
    @StateObject private var vm = ScanViewModel()
    
    @State private var isPresentedScan = false
    
    @State private var showScannerStatusAlert = false
    @State private var scannerStatusAlertTitle = ""
    
    var body: some View {
        ZStack {
            VStack {
                Text(vm.qr)
                
                Button("Scan") {
                    scanButtonPressed()
                }
            }
            
            if isPresentedScan {
                ScanQRView(
                    isPresentedScan: $isPresentedScan,
                    addChild: addChild
                )
            }
            
        }
        .environmentObject(vm)
        .alert(scannerStatusAlertTitle, isPresented: $showScannerStatusAlert) {
            TextField("Enter your child id", text: $vm.qr)
            Button("Add", action: addChild)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Or Enter your child id manually.")
        }
    }
}

struct AddChildView_Previews: PreviewProvider {
    static var previews: some View {
        AddChildView()
    }
}

extension AddChildView {
    
    func addChild() {
        guard let currentUser = cloudViewModel.currentUser else { return }
        
        let childID = vm.qr
        vm.qr = ""
        // get child record
        cloudViewModel.fetchUser(id: childID, isChild: true) { child in
            cloudViewModel.addChildToParent(child: child, parent: currentUser)
        }
    }
    
    func showAlert(_ title: String) {
        scannerStatusAlertTitle = title
        showScannerStatusAlert.toggle()
    }
    
    func scanButtonPressed() {
        Task {
            await vm.requestDataScannerAccessStatus()
            
            switch vm.dataScannerAccessStatus {
            case .scannerAvailable:
                withAnimation(.spring()) {
                    isPresentedScan.toggle()
                }
            case .cameraNotAvailable:
                showAlert("Your device doesn't have a camera")
            case .scannerNotAvailable:
                showAlert("Your device doesn't have support for scanning barcode with this app")
            case .cameraAccessNotGranted:
                showAlert("Please provide access to the camera in settings")
            case .notDetermined:
                showAlert("Requesting camera access")
            }
        }
    }
}