//
//  ChooseUserView.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI

struct ChooseUserView: View {
    
    @EnvironmentObject var cloudViewModel: CloudViewModel
    
    var body: some View {
        ZStack {
            puzzleBackground
            userType
        }
    }
}

struct ChooseUserView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseUserView()
            .environmentObject(CloudViewModel())
    }
}

extension ChooseUserView {
    var puzzleBackground: some View {
        Image("puzzleBG")
            .resizable()
            .scaledToFit()
            .frame(maxHeight: .infinity, alignment: .bottom)
    }
    
    var userType: some View {
        VStack {
            Spacer().frame(height: UIScreen.main.bounds.height * 0.19)
            Button {
                let child = ChildModel()
                cloudViewModel.addUser(user: child)
            } label: {
                Image("Autistic")
            }

            Spacer().frame(height: UIScreen.main.bounds.height * 0.11)
            Button {
                let parent = ParentModel()
                cloudViewModel.addUser(user: parent)
            } label: {
                Image("Parents")
            }

            Spacer().frame(height: UIScreen.main.bounds.height * 0.28)
        }
    }
}
