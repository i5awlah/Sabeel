//
//  AddPecsView.swift
//  Sabeel
//
//  Created by Khawlah on 06/02/2023.
//

import SwiftUI
import UIKit
import AVKit
import AVFoundation

struct AddPecsView: View {
    // Variable
    @State var ispickerShowing = false
    @State var image: UIImage?
    @State var Name = ""
    @State var vName = ""
    @State var Audio = ""
    @State var record = false
    @State var session : AVAudioSession!
    @State var recorder : AVAudioRecorder!
    @State var alert = false
    @State var audioPlayer : AVAudioPlayer!
    @State var isRecording = true
    @State var isPlaying = false
    @State var isPremission = true
    @State var isPhotoPremission = true
    @State var countDownTimer = 0.0
    @State var timerRuning = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    // Varabile
    
    var body: some View {
        NavigationView {
            ZStack {
                // image uploading
                VStack {
                    if image != nil {
                        Image(uiImage: image!)
                            .resizable().frame(width: 100, height: 80).foregroundColor(.gray)   .overlay(Circle().stroke(Color.gray, lineWidth: 0.5).frame(width: 155, height: 155))
                    }
                    else {
                        Image(systemName: "photo.on.rectangle").resizable().frame(width: 70, height: 65).foregroundColor(.gray)   .overlay(Circle().stroke(Color.gray, lineWidth: 0.5).frame(width: 155, height: 155))
                    }
                    Button(action: {
                        self.ispickerShowing = true
                    }) {
                        Image(systemName: "camera")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.buttonBlue)
                            .clipShape(Circle())
                            .padding(.top,-12)
                            .padding(.leading,115)
                    }
                    
                }// end VStack
                .padding(.top, 80)
                
                    .frame(maxHeight: .infinity, alignment: .top)
                
                    .sheet(isPresented: $ispickerShowing) {
                        ImagePickerView(sourceType: .photoLibrary) { image in
                            self.image = image }
                    }
                // text filed
                    VStack (spacing: -20){
                        TextField("Enter the name of image", text: $Name)
                            .textFieldStyle(CaptionTextFieldStyle())
                        VStack(alignment: .leading) {
                            Text("Name").foregroundColor(Color.darkBlue).padding(5)
                                .background(.white)
                                .opacity(1)
                                .offset(x: -130, y: -70)
                        }
                        HStack {
                            Button(action: {
                                if checkPremission() {
                                    do {
                                        if self.record {
                                            self.recorder.stop()
                                            self.record.toggle()
                                            return
                                        }
                                        let audioFilename = getFileUrl()
                                        let settings = [
                                            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                                            AVSampleRateKey: 12000,
                                            AVNumberOfChannelsKey: 1,
                                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                                        ]
                                        
                                        self.recorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                                        self.recorder.record()// recording
                                        vName = getFileUrl().lastPathComponent// Save the URL
                                        isRecording = false // was true
                                        isPlaying = true // was false
                                        countDownTimer = 0.0
                                        self.record.toggle() // true
                                    }
                                    
                                    catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }) {
                                
                                if self.record {
                                    
                                    Text(String(format: "%.1f", countDownTimer)).onReceive(timer) { _ in
                                        if countDownTimer < 0.8 && timerRuning {
                                            countDownTimer += 0.1
                                        } else {
                                            
                                            timerRuning = false
                                            self.recorder.stop()
                                            countDownTimer = 0.0
                                            self.record = false
                                        }
                                        
                                        timerRuning = true
                                        
                                    }.font(.system(size: 12, weight: .bold))
                                        .opacity(0.80)
                                    
                                    TextField("", text: $Audio)
                                    
                                    Image(systemName: "record.circle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.red)
    
                                } else {
                                    
                                    if isPlaying {
                                        Text(vName)
                                        Spacer()
                                        Button(action: {
                                            preparePlayer()
                                            audioPlayer.play()
                                        }) {
                                            Image(systemName: "play.circle")
                                                .imageScale(.large).foregroundColor(Color.darkBlue)
                                        }
                                        Button(action: {
                                            do {
                                                try FileManager.default.removeItem(at: getFileUrl())
                                                isRecording = true
                                                isPlaying = false
                                            } catch {
                                                print("File could not be deleted!")
                                            }
                                        }) {
                                            Image(systemName: "x.circle")
                                                .imageScale(.large).foregroundColor(.red)
                                        }
                                    }
                                    if  isRecording {
                                        TextField("Click the mic icon to start recording", text: $Audio).disabled(true)
                                        
                                        Image(systemName: "mic.fill")
                                            .resizable()
                                            .frame(width: 15, height: 20)
                                            .foregroundColor(Color.darkBlue)
                                        
                                    }
                                }
                            }

                        }.padding()
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 0.2).foregroundColor(Color.darkGray)).padding(20)
                        
                        VStack(alignment: .leading) {
                            Text("Audio").foregroundColor(Color.darkBlue).padding(5)
                                .background(.white)
                                .opacity(1)
                                .offset(x: -130, y: -70)
                        }
                       .padding(.bottom,20)
                    
                    Button(action: {
                       //toggle
                    }) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.buttonBlue)
                            .frame(width: 330, height: 56)
                            .overlay(content: {
                                Text("Save")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    
                            })
                    }
                    
                }
                
 
            }
            .navigationBarTitle("Add New PECS")
        }
        
        
                .alert(isPresented: self.$alert, content: {
                    Alert(title: Text("Error"), message: Text("Enable Access"))
                })
//
//                .onAppear {
//                    do {
//
//
//                        self.session = AVAudioSession.sharedInstance()
//                         try self.session.setCategory(.playAndRecord)
//
//                        self.session.requestRecordPermission { (status) in
//
//                            if !status {
//                                self.alert.toggle()
//                            } else {
//                                self.getAudios()                            }
//
//                        }
//
//                    } catch {
//
//                        print(error.localizedDescription)
//
//                    }
//                }

        }
    
//    func updateAudioMeter()
//    {
//        Text("\(countDownTimer)").onReceive(timer) { _ in
//            if countDownTimer > 0 && timerRuning {
//                countDownTimer -= 1
//            } else {
//                timerRuning = true
//                self.recorder.stop()
//            }
//        }.font(.system(size: 12, weight: .bold))
//            .opacity(0.80)
//    }


func checkPremission() -> Bool {
    do {

        
        self.session = AVAudioSession.sharedInstance()
         try self.session.setCategory(.playAndRecord)

        self.session.requestRecordPermission { (status) in

            if !status {
                
                self.alert.toggle()
                isPremission = false
            }
//                else {
//                    self.getAudios()                            }

        }
        


    } catch {

        print(error.localizedDescription)

    }
    return isPremission
}

func preparePlayer() {
      var error: NSError?
      do {
          audioPlayer = try AVAudioPlayer(contentsOf: getFileUrl() as URL)
      } catch {
          print(error.localizedDescription)
          audioPlayer = nil
      }
      
      if let err = error {
          print("AVAudioPlayer error: \(err.localizedDescription)")
      } else {
          //audioPlayer.delegate = self
          audioPlayer.prepareToPlay()
          audioPlayer.volume = 10.0
      }
  }



func getDocumentsDirectory() -> URL
{
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func getFileUrl() -> URL
{
    let filename = "myRecording.m4a"
    let filePath = getDocumentsDirectory().appendingPathComponent(filename)
return filePath
}

}


struct AddPecsView_Previews: PreviewProvider {
    static var previews: some View {
        AddPecsView()
    }
}


public struct ImagePickerView: UIViewControllerRepresentable {

    private let sourceType: UIImagePickerController.SourceType
    private let onImagePicked: (UIImage) -> Void
    @Environment(\.presentationMode) private var presentationMode

    public init(sourceType: UIImagePickerController.SourceType, onImagePicked: @escaping (UIImage) -> Void) {
        self.sourceType = sourceType
        self.onImagePicked = onImagePicked
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = self.sourceType
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: { self.presentationMode.wrappedValue.dismiss() },
            onImagePicked: self.onImagePicked
        )
    }

    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        private let onDismiss: () -> Void
        private let onImagePicked: (UIImage) -> Void

        init(onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage) -> Void) {
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                self.onImagePicked(image)
            }
            self.onDismiss()
        }

        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onDismiss()
        }

    }

}

struct CaptionTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 0.2).foregroundColor(Color.darkGray)).padding(20)
        
    }
}
