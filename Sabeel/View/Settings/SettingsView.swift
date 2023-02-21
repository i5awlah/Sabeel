//
//  SettingsView.swift
//  Sabeel
//
//  Created by Ashwaq on 14/02/2023.
//

import SwiftUI

struct SettingsView: View {
    
    var settingsDataLinkChild = SettingTile(title: NSLocalizedString("Link your Autistic child", comment: ""), icon: "link.icloud")
    
    var settingsDataLinkParent = SettingTile(title: NSLocalizedString("Link with your parent", comment: ""), icon: "link.icloud")
    
    var settingsDataSchedule = SettingTile(title:NSLocalizedString("Schedule PECS", comment: ""), icon: "list.bullet.clipboard")
    
    @AppStorage("number0fColumns") var gridRows = 2
    
    @EnvironmentObject var cloudViewModel: CloudViewModel
    @StateObject private var vm = ScanViewModel()
    
    @State private var isPresentedScan = false
    
    @State private var showScannerStatusAlert = false
    @State private var scannerStatusAlertTitle = ""
    
    @State private var showAlreadyLinkedView = false
    
    var body: some View {
    
        NavigationStack {
            List {
                
                // 1- link
                if cloudViewModel.isChild {
                    NavigationLink(destination: cloudViewModel.childParentModel == nil ? AnyView(ChildQRView()) : AnyView(AlreadyLinkedView())) {
                        SettingsCellView(data: settingsDataLinkParent)
                    }
                } else {
                    SettingsCellView(data: settingsDataLinkChild)
                        .onTapGesture {
                            cloudViewModel.childParentModel == nil ?
                            scanButtonPressed() : showAlreadyLinkedView.toggle()
                        }
                }

                // 2- Schedule
                if !cloudViewModel.isChild {
                    if (cloudViewModel.childParentModel != nil) {
                        NavigationLink(destination: SchedulePecsView()) {
                            SettingsCellView(data: settingsDataSchedule)
                        }
                    } else {
                        SettingsCellView(data: settingsDataSchedule)
                            .onTapGesture {
                                cloudViewModel.showNoLinkView.toggle()
                            }
                    }
                }
                
                // 3-
                HStack{
                    Image(systemName:"photo.on.rectangle").frame(width: 35, height: 30).background(Color("buttonBlue")).foregroundColor(.white).cornerRadius(5)
                    Text("Number of PECS per row:").font(Font.customFont(size: 16))
                    Spacer()
              

                            Picker("", selection: $gridRows) {
                                ForEach(1...5, id: \.self) { number in
                                    Text("\(number)")
                                }
                            }.font(Font.customFont(size: 14))
                                .labelsHidden()

                }.padding(EdgeInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0)))
            }
            .navigationTitle("Settings")
            .navigationDestination(isPresented: $isPresentedScan, destination: {
                ScanQRView(
                    isPresentedScan: $isPresentedScan,
                    addChild: addChild
                )
            })
            .navigationDestination(isPresented: $showAlreadyLinkedView, destination: {
                AlreadyLinkedView()
            })
            .alert(scannerStatusAlertTitle.localized, isPresented: $showScannerStatusAlert) {
                TextField("Enter your child id", text: $vm.qr)
                Button("Add", action: addChild)
                Button("Cancel", role: .cancel) { }
            }
        }
        .environmentObject(vm)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(CloudViewModel())
    }
}

struct SettingTile : Identifiable{
    let id = UUID()
    let title: String
    let icon :String
    
    init(title:String, icon: String) {
        self.title = title
        self.icon = icon
    }
}

extension SettingsView {
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
