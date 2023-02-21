//
//  ScanQRView.swift
//  Sabeel
//
//  Created by Khawlah on 12/02/2023.
//

import SwiftUI

struct ScanQRView: View {
    
    @EnvironmentObject var vm: ScanViewModel
    @Binding var isPresentedScan: Bool
    let addChild: () -> Void
    
    var body: some View {
        ZStack {
            mainView
        }
        .onAppear{
            vm.recognizedItems = []
        }
        .toolbar(.hidden, for: .tabBar)
        
    }
}

extension ScanQRView {
    private var mainView: some View {
        DataScannerView(
            recognizedItems: $vm.recognizedItems,
            recognizedDataType: vm.recognizedDataType)
        .ignoresSafeArea()
        .onAppear{
            vm.recognizedItems = []
            vm.qr = ""
        }
        .onChange(of: vm.recognizedText) { _ in handleRecognizedText() }
    }
    
}

extension ScanQRView {
    func handleRecognizedText() {
        print("handleRecognizedText..")
        if vm.recognizedText != nil {
            // save recognized QR on qr
            vm.qr = vm.recognizedText ?? ""
            print("QR: \(vm.qr)")
            isPresentedScan.toggle()
            // Add Child to database
            addChild()
        }
    }
}


struct ScanQRView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ScanQRView(
                isPresentedScan: .constant(false),
                addChild: {}
            )
                .environmentObject(ScanViewModel())
        }
    }
}
