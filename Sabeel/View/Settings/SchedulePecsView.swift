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
        DropdownOption(key: uniqueKey, value: NSLocalizedString("Food", comment: "")),
        DropdownOption(key: uniqueKey, value:  NSLocalizedString("Drink", comment: "")),
        DropdownOption(key: uniqueKey, value: NSLocalizedString("Utensils", comment: "")),
        DropdownOption(key: uniqueKey, value: NSLocalizedString("Clothes", comment: "")),
        DropdownOption(key: uniqueKey, value: NSLocalizedString("Bathroom", comment: "")),
        DropdownOption(key: uniqueKey, value: NSLocalizedString("Activities", comment: "")),
        DropdownOption(key: uniqueKey, value: NSLocalizedString("Feelings", comment: "")),
        DropdownOption(key: uniqueKey, value: NSLocalizedString("Family", comment: "")),
        DropdownOption(key: uniqueKey, value: NSLocalizedString("People", comment: "")),
        DropdownOption(key: uniqueKey, value: NSLocalizedString("Places", comment: "")),
        DropdownOption(key: uniqueKey, value: NSLocalizedString("Tools", comment: ""))
    ]
    @State private var fromTime = Date.now
    @State private var toTime = Date.now
    var body: some View {
        ZStack{
            Color.lightGray.ignoresSafeArea()
            VStack{
                
                HStack{
                    Text("Category").padding().font(Font.customFont(size: 16))
                    
           

                    Group {
                        DropdownSelector(
                            placeholder: NSLocalizedString(  "Select Option", comment: "")
                              ,
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
                    .font(Font.customFont(size: 16))
                    .background(.white)
                    .cornerRadius(10).padding(EdgeInsets(.init(top: 20, leading: 20, bottom: 0, trailing: 20)))
                  
                
                Button {
                } label: {
                    Text("Schedule It").padding(.vertical, 12).font(Font.customFont(size: 20))
                }
                .frame(maxWidth: .infinity) .foregroundColor(.white)
                .background(Color.buttonBlue)      .cornerRadius(10).padding(.all,20)
                
         
          
            
            } .frame(maxHeight: .infinity, alignment: .top)  .navigationTitle("Schedule PECS")
            
            
       
           
        }.toolbar(.hidden,for: .tabBar)
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
            Text(selectedOption == nil ? placeholder : selectedOption!.value).font(Font.customFont(size: 14))
    
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
                    DropdownRow(option: option, onOptionSelected: self.onOptionSelected).font(Font.customFont(size: 14))
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
          
                Text(self.option.value)
                   
                    .foregroundColor(Color.black)
                   
         
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }
}

