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
        DropdownOption(key: uniqueKey, value: "People"),
        DropdownOption(key: uniqueKey, value: "Places"),
        DropdownOption(key: uniqueKey, value: "Tools")
    ]
    @State private var fromTime = Date.now
    @State private var toTime = Date.now
    var body: some View {
        ZStack{
            Color.lightGray.ignoresSafeArea()
            VStack{
                
                HStack{
                    Text("Category").padding()
                    
           

                    Group {
                        DropdownSelector(
                            placeholder: "Select Option",
                            options: SchedulePecsView.options,
                            onOptionSelected: { option in
                                print(option)
                            }).padding()
                         
                    }
                    
                }
                                .frame(maxWidth: .infinity)
                               
                                .background(.white)
                                .cornerRadius(10)
                                .padding(EdgeInsets(.init(top: 20, leading: 20, bottom: 8, trailing: 20)))
                              
                              
                VStack{
                    Text("Time").listRowSeparator(.hidden).padding(.top)   .frame(maxWidth: .infinity, alignment: .leading).padding(.leading)
                    DatePicker("From", selection: $fromTime, displayedComponents: .hourAndMinute).padding(.horizontal,20).listRowSeparator(.hidden)
                    DatePicker("To", selection: $toTime, displayedComponents: .hourAndMinute).padding(EdgeInsets(.init(top: 0, leading: 20, bottom: 20, trailing: 20)))} .frame(maxWidth: .infinity)
                
                    .background(.white)
                    .cornerRadius(10).padding(EdgeInsets(.init(top: 20, leading: 20, bottom: 0, trailing: 20)))
                  
                
                Button {
                } label: {
                    Text("Schedule It").padding(.vertical, 12)
                }
                .frame(maxWidth: .infinity) .foregroundColor(.white)
                .background(Color.buttonBlue)      .cornerRadius(10).padding(.all,20)
                
         
          
            
            } .frame(maxHeight: .infinity, alignment: .top)  .navigationTitle("Scheduled PECS")
            
            
       
           
        }
    }}


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
        HStack{
            Menu{
             
                Dropdown(options: self.options, onOptionSelected: { option in
                    shouldShowDropdown = false
                    selectedOption = option
                    self.onOptionSelected?(option)
                })

              
                  }
        label: {
            Text(selectedOption == nil ? placeholder : selectedOption!.value)
                .font(.system(size: 14))
                .foregroundColor(selectedOption == nil ? Color.gray: Color.black)
            Spacer()
            
            Image(systemName: self.shouldShowDropdown ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                .resizable()
                .frame(width: 9, height: 5)
                .font(Font.system(size: 9, weight: .medium))
                .foregroundColor(Color.black)
                          }   .padding(.horizontal)
                .cornerRadius(5)
                .frame(width: .infinity, height: self.buttonHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
              
                .background(
                    RoundedRectangle(cornerRadius: 5).fill(Color.white)
                )
  
     }
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
        .frame(minHeight: CGFloat(options.count) * 30, maxHeight: 200)
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

