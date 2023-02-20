//
//  AppLockView.swift
//  Sabeel
//
//  Created by Manal alwayeli on 29/07/1444 AH.
//

import SwiftUI

struct AppLockView: View {
    
    struct PinCode: Equatable {
        public init(_ value: String) { self.value = value }
        public init(_ value: Int) {  self.value = String(value)  }
        
        let value: String
    }
    
    let correctPin: PinCode
    let buttons: [String] = [ "1","2","3","4","5","6","7","8","9","","0","X"]
    @State private var enteredPin: String = ""
    @State private var NextView: Bool = false
    @Namespace private var animation
    @StateObject var cloudViewModel = CloudViewModel()
    
    public init(
        pincode: PinCode) {
            self.correctPin = pincode
        }
    var body: some View {
       
                ZStack(alignment: .top) {
                    VStack {
                        VStack(spacing: 20) {
                            Text("Parent Only !").font(.customFont(size: 35).weight(.bold))
                            
                            Text(" To access enter the code:").font(.customFont(size: 20).weight(.light))
                                .padding()
                            
                            Text("Two - zero - two - three")
                                .font(.customFont(size: 25))
                                .foregroundColor(Color.darkGreen)
                            
                            HStack(spacing: 60) {
                                ForEach(0..<correctPin.value.count) { i in
                                    ZStack {
                                        if !(i < enteredPin.count) {
                                            Rectangle()
                                                .frame(width: 12, height: 2)
                                                .frame(height: 30, alignment: .bottom)
                                                .matchedGeometryEffect(id: i, in: animation)
                                                .foregroundColor(.secondary)
                                        } else {
                                            Image(systemName: "circle.fill")
                                                .resizable()
                                                .frame(width: 12, height: 12)
                                                .frame(height: 20, alignment: .top)
                                                .matchedGeometryEffect(id: i, in: animation)
                                            
                                        }
                                    }
                                }
                            }
                            .frame(height: 30)
                            .padding(.vertical)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 60)
                        
                        LazyVGrid(columns: [
                            GridItem(.fixed(90)),
                            GridItem(.fixed(90)),
                            GridItem(.fixed(90)),
                            
                        ], spacing: 10) {
                            ForEach(buttons, id: \.self) { button in
                                Button {
                                    withAnimation(.easeIn(duration: 0.1)) {
                                        if button == "X" {
                                            if !enteredPin.isEmpty {
                                                enteredPin.removeLast()
                                            }
                                        } else {
                                            enteredPin.append(button)
                                        }
                                    }
                                    impact(style: .rigid)
                                } label: {
                                    Group {
                                        if button == "X" {
                                            Image(systemName: "delete.left")
                                                .resizable()
                                                .frame(width: 22, height: 17)
                                                .opacity(enteredPin.isEmpty ? 0 : 1)
                                            
                                        } else {
                                            if !(button == "") {
                                                Text(button)
                                                    .font(.system(size: 25, weight: .semibold, design: .rounded)).foregroundColor(Color.darkBlue).overlay(Circle().frame(width: 60, height: 70).foregroundColor(Color.lightBlue).opacity(0.4))
                                                
                                            }
                                        }
                                        
                                    }
                                    .padding(10)
                                }
                                .frame(width: 70, height: 70)
                                .foregroundColor(
                                    button == "X" ?
                                    Color.red :
                                        Color(.label)
                                )
                                
                            }
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.bottom, 60)
                        
                    }
                    .opacity(correctPin.value == enteredPin ? 0 : 1)
                    .onChange(of: enteredPin, perform: onChange)
                    .fullScreenCover(isPresented: $NextView){
                                        SettingsView()
                                    }
                }
                .background(Color(.white).ignoresSafeArea())
                
            }
        
    

   func onChange(_ value: String) {
       
        if enteredPin.count == correctPin.value.count {
            if enteredPin == correctPin.value {
                NextView = true
                print("Success")
            } else {
                print("Failed")
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                withAnimation(.easeIn(duration: 0.15)) {
                    enteredPin = ""
                }
            }
            
        }
    }
    private func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
}

struct AppLockView_Previews: PreviewProvider {
    static var previews: some View {
        AppLockView(
            pincode: .init("2023")
        )
    }
}
