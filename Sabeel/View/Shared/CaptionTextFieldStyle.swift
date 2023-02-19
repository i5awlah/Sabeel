//
//  CaptionTextFieldStyle.swift
//  Sabeel
//
//  Created by Khawlah on 19/02/2023.
//

import SwiftUI

struct CaptionTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: 0.2)
                    .foregroundColor(Color.darkGray)
            )
        
    }
}
