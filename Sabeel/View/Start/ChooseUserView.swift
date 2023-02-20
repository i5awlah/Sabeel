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
            .ignoresSafeArea()
    }
    
    var userType: some View {
        VStack {
            Spacer().frame(height: UIScreen.main.bounds.height * 0.19)
            Button {
                Task {
                    let id = await cloudViewModel.fetchiCloudUserRecordId()
                    let child = ChildModel(id: id)
                    cloudViewModel.addUser(user: child)
                }
            } label: {
                Image("Autistic")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 220)
            }

            Spacer().frame(height: UIScreen.main.bounds.height * 0.11)
            Button {
                Task {
                    let id = await cloudViewModel.fetchiCloudUserRecordId()
                    let parent = ParentModel(id: id)
                    cloudViewModel.addUser(user: parent)
                }
            } label: {
                Image("Parents")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 220)
            }

            Spacer().frame(height: UIScreen.main.bounds.height * 0.28)
        }
    }
}
