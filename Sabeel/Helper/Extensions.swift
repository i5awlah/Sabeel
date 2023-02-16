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

