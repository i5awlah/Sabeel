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
        VStack(spacing:20){
            
            Image("QRBackground")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 400)
                .overlay(alignment: .bottom) {
                    if let id = cloudViewModel.currentUser?.id {
                        if let data = getQRCodeDate(text: id)
                            , let image = UIImage(data: data)
                            , let imageTransparent = makeTransparent(image: image)
                            , let imageGreen = imageTransparent.withColor(UIColor(Color.darkGreen)) {
                            
                            Image(uiImage: imageGreen)
                                .resizable()
                                .frame(width: 200, height: 200)
                                .offset(
                                    x: Helper.shared.isEnglishLanguage() ? -12 : 12,
                                    y: -10
                                )
                            
                        }
                    }
                }
            
            
            
            VStack(spacing: 20) {
                Text("Link your child using the scan in your app setting")
                VStack(spacing: 5) {
                    Text("or write it manually".localized)
                    Text("\(cloudViewModel.currentUser?.id ?? "")")
                }
                .font(.customFont(size: 16))
            }
                .font(.customFont(size: 20)).multilineTextAlignment(.center)
                .padding(.horizontal, 50)
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
        return uiimage.jpegData(compressionQuality: 1 )!
    }
    
    func makeTransparent(image: UIImage) -> UIImage? {
        guard let rawImage = image.cgImage else { return nil}
        let colorMasking: [CGFloat] = [255, 255, 255, 255, 255, 255]
        UIGraphicsBeginImageContext(image.size)
        
        if let maskedImage = rawImage.copy(maskingColorComponents: colorMasking),
           let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: 0.0, y: image.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.draw(maskedImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return finalImage
        }
        
        return nil
    }
}
