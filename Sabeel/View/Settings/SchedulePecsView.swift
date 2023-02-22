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


    @AppStorage("schedule1") var scheduleCategories: Data = Data()
   

    static let options: [DropdownOption] = [
        DropdownOption(key: uniqueKey, value: "Food"),
        DropdownOption(key: uniqueKey, value:  "Drink"),
        DropdownOption(key: uniqueKey, value: "Utensils"),
        DropdownOption(key: uniqueKey, value: "Clothes"),
        DropdownOption(key: uniqueKey, value: "Bathroom"),
        DropdownOption(key: uniqueKey, value: "Activities"),
        DropdownOption(key: uniqueKey, value:"Feelings"),
        DropdownOption(key: uniqueKey, value: "Family"),
        DropdownOption(key: uniqueKey, value: "People"),
        DropdownOption(key: uniqueKey, value: "Places"),
        DropdownOption(key: uniqueKey, value: "Tools")
    ]
    @State private var fromTime = Date.now
    @State private var toTime = Date.now
    @State private var optioncategory = ""

    @State private var output1: [sech1] = []
    @State private var showPreviousSec = false
    var userDefaults = UserDefaults.standard

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

                                optioncategory = option.value
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
                                        let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                
                    let record2 = sech1(category: optioncategory, fromTime: dateFormatter.string(from: fromTime), toTime: dateFormatter.string(from:toTime))
                    
                
                    if let valueIndex = output1.firstIndex(where: {$0.category == record2.category}){
                        output1[valueIndex] = record2
                    }else{
                        output1.append(record2)
                    }
                
                    
                
                    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: output1)
                    userDefaults.set(encodedData, forKey: "sec")

                    
                    
                } label: {
                    
                    Text("Schedule It").padding(.vertical, 12).font(Font.customFont(size: 20))
                }.disabled(optioncategory == "" || fromTime >= toTime)
                .frame(maxWidth: .infinity) .foregroundColor(.white)
                .background(optioncategory != "" && fromTime < toTime ? Color.buttonBlue : Color.gray)      .cornerRadius(10).padding(.all,20)
                
                
            
                
                
        
                Divider().padding()
                
                Button{
                    if(output1.isEmpty){
                        let decoded  = userDefaults.data(forKey: "sec")
                        if(decoded != nil){
                            let decodedTeams = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [sech1]
                            print("OUTPUT2 \(decodedTeams[0].category)")
                            
                            output1 = decodedTeams}
                    }
                    
                    showPreviousSec.toggle()
                }label: {
                    HStack{
                        Text("Scheduled Previously")
                            .font(.customFont(size: 18)).bold().frame( alignment: .leading).padding(.horizontal,20).foregroundColor(Color.darkBlue)
                        
                        Image(systemName: showPreviousSec ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                            .resizable()
                            .frame(width: 9, height: 5)
                            .font(Font.system(size: 9, weight: .medium))
                            .foregroundColor(Color.darkBlue)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                if(showPreviousSec && !output1.isEmpty){
                    ForEach(0..<output1.count, id: \.self){ index in
                        
                        ScedhuleRowRowView(record: output1[index], index: index, function:{
                            output1.remove(at: index)
                            if(output1.count == 0){
                                UserDefaults.standard.removeObject(forKey: "sec")
                            }else{
                                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: output1)
                                userDefaults.set(encodedData, forKey: "sec")}
                            
                        })
                        
                        
                    }}
             
                
         

            
            } .frame(maxHeight: .infinity, alignment: .topLeading)  .navigationTitle("Schedule PECS")
            
            
       
           
        }.toolbar(.hidden,for: .tabBar)
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
        HStack{
            Menu{
             
                Dropdown(options: self.options, onOptionSelected: { option in
                    shouldShowDropdown = false
                    selectedOption = option
                    self.onOptionSelected?(option)
                })

              
                  }
        label: {
            Text(selectedOption == nil ? placeholder : NSLocalizedString(selectedOption!.value, comment: "")).font(Font.customFont(size: 14))
    
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





class sech1: NSObject, NSCoding {
    var category: String
    var fromTime: String
    var toTime: String


    init(category: String, fromTime: String, toTime: String) {
        self.category = category
        self.fromTime = fromTime
        self.toTime = toTime

    }

    required convenience init(coder aDecoder: NSCoder) {
        let category = aDecoder.decodeObject(forKey: "category") as! String
        let fromTime = aDecoder.decodeObject(forKey: "fromTime") as! String
        let toTime = aDecoder.decodeObject(forKey: "toTime") as! String
        self.init(category: category, fromTime:fromTime, toTime: toTime)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(category, forKey: "category")
        aCoder.encode(fromTime, forKey: "fromTime")
        aCoder.encode(toTime, forKey: "toTime")
    }
}

struct ScedhuleRowRowView : View {

    private var record : sech1
    private var index : Int
    var function: () -> Void
   


    init(record : sech1, index:Int, function: @escaping () -> Void){
        self.record = record
        self.index = index
        self.function = function
    }
    let preferredLanguage = NSLocale.preferredLanguages[0]
    var body: some View {
        HStack{
            Text("\(index+1)").frame(width: 35, height: 35).background(Color.darkGray).foregroundColor(.white).cornerRadius(5)
            Spacer().frame(width: 16)
            VStack(alignment: .leading, spacing: 2) {
            
                Text("\(NSLocalizedString(record.category, comment: ""))")
                    .font(.customFont(size: 18)).frame(maxWidth: .infinity, alignment: .leading)
                if preferredLanguage == "ar" {
                    Text("\(record.toTime) \(NSLocalizedString("To Time:", comment: "")) \(record.fromTime) \(NSLocalizedString("From Time:", comment: ""))   ")
                        .font(.customFont(size: 12)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(Color.darkGray)
                }else{
                    Text("\(NSLocalizedString("From Time:", comment: "")) \(record.fromTime) \(NSLocalizedString("To Time:", comment: "")) \(record.toTime)")
                        .font(.customFont(size: 12)).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(Color.darkGray)
                }
             
                
            }
            
            Button{
                function()
            }label: {
                Image(systemName:"trash").frame(width: 35, height: 30).foregroundColor(Color.customRed)
            }
        }
      .padding(.horizontal, 20)
        .frame(maxWidth: .infinity,maxHeight: 50)
    }
}


