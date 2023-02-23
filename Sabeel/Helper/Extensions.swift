//
//  Extensions.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI

extension Color {
    static let customRed = Color("customRed")
    static let darkBlue = Color("darkBlue")
    static let darkGray = Color("darkGray")
    static let lightBlue = Color("lightBlue")
    static let lightGray = Color("lightGray")
    static let buttonBlue = Color("buttonBlue")
    static let lightGreen = Color("lightGreen")
    static let darkGreen = Color("darkGreen")
    static let darkGreen1 = Color("darkGreen 1")
    static let Green = Color("Green")
    static let White = Color("white")
    static let Dark = Color("sc")
}

extension Date {
    var polite: String {
        if Calendar.current.isDateInToday(self) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: self)
        }
        
        if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}


extension Font {
    
    static func customFont( size : CGFloat) -> Font {
        let language = NSLocale.current.language.languageCode?.identifier
        switch language {
        case "en":
            return .custom("SF-Pro" , size: size)
        case "ar":
            return .custom("Tajawal-Regular" , size: size)
            
            
        default:
            return .body
        }
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

extension Binding {
    func onUpdate(_ closure: @escaping () -> Void) -> Binding<Value> {
        Binding(get: {
            wrappedValue
        }, set: { newValue in
            wrappedValue = newValue
            closure()
        })
    }
}

extension UIImage {
    func withColor(_ color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        // 1
        let drawRect = CGRect(x: 0,y: 0,width: size.width,height: size.height)
        // 2
        color.setFill()
        UIRectFill(drawRect)
        // 3
        draw(in: drawRect, blendMode: .destinationIn, alpha: 1)
        
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!
    }
}


extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
