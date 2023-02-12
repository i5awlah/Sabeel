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
            closeButton
        }
        .onAppear{
            vm.recognizedItems = []
        }
        .navigationTitle("Scan")
        .toolbar(.hidden)
        
    }
}

extension ScanQRView {
    private var mainView: some View {
        DataScannerView(
            recognizedItems: $vm.recognizedItems,
            recognizedDataType: vm.recognizedDataType)
        .background { Color.gray.opacity(0.3) }
        .ignoresSafeArea()
        .onAppear{
            vm.recognizedItems = []
            vm.qr = ""
        }
        .onChange(of: vm.recognizedText) { _ in handleRecognizedText() }
    }
    
    private var closeButton: some View {
        Button {
            withAnimation(.spring()) {
                isPresentedScan.toggle()
            }
        } label: {
            Image(systemName: "chevron.backward")
                .font(.title)
                .foregroundColor(.accentColor)
                .padding(10)
                .background(Color.white.opacity(0.4))
                .clipShape(Circle())
                .shadow(radius: 2)
                .padding(.leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
