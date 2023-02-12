//
//  ScanViewModel.swift
//  Sabeel
//
//  Created by Khawlah on 12/02/2023.
//

import AVKit
import Foundation
import SwiftUI
import VisionKit


enum DataScannerAccessStatusType {
    case notDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}

@MainActor
final class ScanViewModel: ObservableObject {
    
    @Published var dataScannerAccessStatus: DataScannerAccessStatusType = .notDetermined
    @Published var recognizedItems: [RecognizedItem] = []
    var recognizedDataType: DataScannerViewController.RecognizedDataType = .barcode()
    
    var recognizedText: String? {
        if !recognizedItems.isEmpty {
            let item = recognizedItems[0]
            
            switch item {
            case .barcode(let barcode):
                return (barcode.payloadStringValue ?? nil)
                
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    @Published var qr: String = ""
    
    private var isScannerAvailable: Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    func requestDataScannerAccessStatus() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            
        case .restricted, .denied:
            dataScannerAccessStatus = .cameraAccessNotGranted
            
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            } else {
                dataScannerAccessStatus = .cameraAccessNotGranted
            }
        
        default: break
            
        }
    }
    
    
}
