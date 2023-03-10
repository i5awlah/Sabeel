//
//  AddChildView.swift
//  Sabeel
//
//  Created by Khawlah on 22/02/2023.
//

import SwiftUI

struct AddChildView: View {
    
    @EnvironmentObject var cloudViewModel: CloudViewModel
    @StateObject private var vm = ScanViewModel()
    
    @State private var isPresentedScan = false
    
    @State private var showScannerStatusAlert = false
    @State private var scannerStatusAlertTitle = ""
    
    var body: some View {
        Group {
            if cloudViewModel.currentUser == nil {
                ProgressView()
            } else {
                ZStack {
                    VStack(spacing : 20){
                        Image("Scan")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal, 16)
                        
                        Text("QR Scan")
                            .bold()
                            .font(.customFont(size: 30))
                            .foregroundColor(.darkBlue)
                        
                        Text("Connect your child by scanning the QR code in their app settings")
                            .font(.customFont(size: 20))
                            .foregroundColor(.darkGray)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            scanButtonPressed()
                        } label: {
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.buttonBlue)
                                .frame(height: 48)
                                .overlay(content: {
                                    Text("Scan")
                                        .font(.customFont(size: 20))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                })
                        }
                    }  .padding(.horizontal, 24)
                    
                    if isPresentedScan {
                        ScanQRView(
                            isPresentedScan: $isPresentedScan,
                            addChild: addChild
                        )
                    }
                    
                }
            }
        }
        .onAppear {
            if cloudViewModel.currentUser == nil {
                cloudViewModel.fetchiCloudUserRecordId() { id in
                    cloudViewModel.getCurrentUser(isChild: false, currentUserID: id) { user in
                        if user == nil {
                            let parent = ParentModel(id: id)
                            cloudViewModel.addUser(user: parent)
                        }
                    }
                }
            }
        }
        .alert(scannerStatusAlertTitle.localized, isPresented: $showScannerStatusAlert) {
            TextField("Enter your child id", text: $vm.qr)
            Button("Add", action: addChild)
            Button("Cancel", role: .cancel) { }
        }
        .environmentObject(vm)
        .toolbar(.hidden,for: .tabBar)
        .background(Color.White2)
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
        cloudViewModel.fetchChild(childID: childID) { child in
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
