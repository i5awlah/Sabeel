//
//  Helper.swift
//  Sabeel
//
//  Created by Khawlah on 18/02/2023.
//

import UIKit
import CloudKit

final class Helper {
    static let shared = Helper()
    
    func isEnglishLanguage() -> Bool {
        if let language = Locale.current.language.languageCode?.identifier {
            return language == "en" ? true : false
        } else {
            return true
        }
    }
    
    func convertUIImageToCKAsset(image: UIImage) async throws -> CKAsset? {
        guard
            let imageURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("\(UUID().uuidString).png"),
            let data = image.jpegData(compressionQuality: 1.0) else { return nil}
        
        do {
            try data.write(to: imageURL)
            let asset = CKAsset(fileURL: imageURL)
            return asset
            
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
}
