//
//  ChildQRView.swift
//  Sabeel
//
//  Created by Khawlah on 12/02/2023.
//

import SwiftUI

struct ChildQRView: View {
    
    @EnvironmentObject var cloudViewModel: CloudViewModel
    
    var body: some View {
        VStack {
            if let id = cloudViewModel.currentUser?.id {
                if let data = getQRCodeDate(text: id)
                    , let image = UIImage(data: data) {
                    
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 200, height: 200)
                    
                }
                Text("Or you can write it manually: \n \(id)")
                    .multilineTextAlignment(.center)
            }
        }.toolbar(.hidden,for: .tabBar)
    }
}

struct ChildQRView_Previews: PreviewProvider {
    static var previews: some View {
        ChildQRView()
            .environmentObject(CloudViewModel())
    }
}

extension ChildQRView {
    func getQRCodeDate(text: String) -> Data? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let data = text.data(using: .ascii, allowLossyConversion: false)
        filter.setValue(data, forKey: "inputMessage")
        guard let ciimage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCIImage = ciimage.transformed(by: transform)
        let uiimage = UIImage(ciImage: scaledCIImage)
        return uiimage.pngData()!
    }
}
