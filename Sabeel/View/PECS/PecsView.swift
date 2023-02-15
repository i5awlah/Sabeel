//
//  PecsView.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI

struct PecsView: View {
    @State var parent : Bool = true
    @State var isEditing = false
    
    var body: some View {
        NavigationView {
            VStack{
                Text("Hello")
            }
                .navigationTitle("PECS")
                .foregroundColor(parent ? .darkBlue : .darkGreen)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if parent{
                        Button{ isEditing.toggle() }label: {
                                Text( isEditing ? "Close" : "Edit")}
                            .foregroundColor(.darkBlue)
                        }
                        else{
                            Button{}label: {
                                Image(systemName: "gear")
                                    .foregroundColor(.darkGreen)
                            }
                        }
                    }
                }
                
        }
    }
}

struct PecsView_Previews: PreviewProvider {
    static var previews: some View {
        PecsView()
    }
}
