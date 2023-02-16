//
//  SchedulePecsView.swift
//  Sabeel
//
//  Created by Ashwaq on 16/02/2023.
//

import SwiftUI

struct SchedulePecsView: View {
    static var uniqueKey: String {
        UUID().uuidString
    }
    static let options: [DropdownOption] = [
        DropdownOption(key: uniqueKey, value: "Food"),
        DropdownOption(key: uniqueKey, value: "Utensils"),
        DropdownOption(key: uniqueKey, value: "Clothes"),
        DropdownOption(key: uniqueKey, value: "Bathroom"),
        DropdownOption(key: uniqueKey, value: "Activities"),
        DropdownOption(key: uniqueKey, value: "Feelings"),
        DropdownOption(key: uniqueKey, value: "Family"),
        DropdownOption(key: uniqueKey, value: "people"),
        DropdownOption(key: uniqueKey, value: "places"),
        DropdownOption(key: uniqueKey, value: "Tools")
    ]
    var body: some View {
        HStack{
            Text("Category")
            Group {
                DropdownSelector(
                    placeholder: "Select Option",
                    options: SchedulePecsView.options,
                    onOptionSelected: { option in
                        print(option)
                    })
                .padding(.horizontal)
            }}.background()
    }
   }


struct SchedulePecsView_Previews: PreviewProvider {
    static var previews: some View {
        SchedulePecsView()
    }
}





struct DropdownSelector: View {
    @State private var shouldShowDropdown = false
       @State private var selectedOption: DropdownOption? = nil
       var placeholder: String
       var options: [DropdownOption]
       var onOptionSelected: ((_ option: DropdownOption) -> Void)?
       private let buttonHeight: CGFloat = 45

       var body: some View {
           Button(action: {
               self.shouldShowDropdown.toggle()
           }) {
               HStack {
                   Text(selectedOption == nil ? placeholder : selectedOption!.value)
                       .font(.system(size: 14))
                       .foregroundColor(selectedOption == nil ? Color.gray: Color.black)

                   Spacer()

                   Image(systemName: self.shouldShowDropdown ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                       .resizable()
                       .frame(width: 9, height: 5)
                       .font(Font.system(size: 9, weight: .medium))
                       .foregroundColor(Color.black)
               }
           }
           .padding(.horizontal)
           .cornerRadius(5)
           .frame(width: .infinity, height: self.buttonHeight)
           .overlay(
               RoundedRectangle(cornerRadius: 5)
                   .stroke(Color.gray, lineWidth: 1)
           )
           .overlay(
               VStack {
                   if self.shouldShowDropdown {
                       Spacer(minLength: buttonHeight + 10)
                       Dropdown(options: self.options, onOptionSelected: { option in
                           shouldShowDropdown = false
                           selectedOption = option
                           self.onOptionSelected?(option)
                       })
                   }
               }, alignment: .topLeading
           )
           .background(
               RoundedRectangle(cornerRadius: 5).fill(Color.white)
           )
       }
   }

struct DropdownOption: Hashable {
    let key: String
    let value: String

    public static func == (lhs: DropdownOption, rhs: DropdownOption) -> Bool {
        return lhs.key == rhs.key
    }
}


struct Dropdown: View {
    var options: [DropdownOption]
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(self.options, id: \.self) { option in
                    DropdownRow(option: option, onOptionSelected: self.onOptionSelected)
                }
            }
        }
        .frame(minHeight: CGFloat(options.count) * 30, maxHeight: 250)
        .padding(.vertical, 5)
        .background(Color.white)
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

struct DropdownRow: View {
    var option: DropdownOption
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?

    var body: some View {
        Button(action: {
            if let onOptionSelected = self.onOptionSelected {
                onOptionSelected(self.option)
            }
        }) {
            HStack {
                Text(self.option.value)
                    .font(.system(size: 14))
                    .foregroundColor(Color.black)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }
}

