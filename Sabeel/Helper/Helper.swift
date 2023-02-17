//
//  Helper.swift
//  Sabeel
//
//  Created by Khawlah on 18/02/2023.
//

import UIKit

final class Helper {
    static let shared = Helper()
    
    func isEnglishLanguage() -> Bool {
        if let language = Locale.current.language.languageCode?.identifier {
            return language == "en" ? true : false
        } else {
            return true
        }
    }
    
}
