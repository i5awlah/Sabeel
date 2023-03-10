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
import PhotosUI
import CloudKit

enum Category: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    
    case food = "Food"
    case drink = "Drink"
    case utensils = "Utensils"
    case clothes = "Clothes"
    case bathroom = "Bathroom"
    case activities = "Activities"
    case feelings = "Feelings"
    case family = "Family"
    case people = "People"
    case places = "Places"
    case tools = "Tools"
}

struct AddPecsView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cloudViewModel: CloudViewModel
    @State var selectedCategory: Category = .food
    
    @State var isPickerShowing = false
    @State var image: UIImage?
    @State var pecsName = ""
    @State var vName = ""
    @State var isThereAnAudio = false
    @State var record = false
    @State var session : AVAudioSession!
    @State var recorder : AVAudioRecorder!
    @State var imageAlert = false
    @State var voiceAlert = false
    @State var audioPlayer : AVAudioPlayer!
    @State var isRecording = true
    @State var isPlaying = false
    @State var isPermission = true
    @State var isPhotoPermission = false
    @State var countDownTimer = 0.0
    @State var timerRunning = true
    @Binding var isToast : Bool

    @State private var output1: [sech1] = []
    var userDefaults = UserDefaults.standard
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ScrollView{
            VStack(spacing: 24) {
                // image uploading
                
                Group {
                    if let image {
                        Circle()
                            .stroke(Color.gray, lineWidth: 0.5)
                            .frame(width: 155, height: 155)
                            .overlay {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 155, height: 155)
                                    .clipShape(Circle())
                            }
                    }
                    else {
                        Circle()
                            .stroke(Color.gray, lineWidth: 0.5)
                            .frame(width: 155, height: 155)
                            .overlay {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.customFont(size: 60))
                                    .foregroundColor(.gray)
                            }
                        
                    }
                }
                .padding(.top, 80)
                .overlay(alignment: .bottomTrailing, content: {
                    Button {
                        print("Pressed")
                        self.checkPhotoPermission()
                        self.isPickerShowing = true
                        
                    } label: {
                        Circle()
                            .fill(Color.buttonBlue)
                            .frame(width: 33, height: 33)
                            .overlay {
                                Image(systemName: "camera")
                                    .foregroundColor(.white)
                            }
                            .offset(x:-8, y: -8)
                        
                    }
                })
                
                // text filed
                TextField("Enter the name of image", text: $pecsName)
                    .textFieldStyle(CaptionTextFieldStyle())
                    .overlay(alignment: .topLeading) {
                        Text("Name")
                            .foregroundColor(Color.darkBlue)
                            .padding(5)
                            .background(Color.White2)
                            .offset(x: 16, y: -16)
                    }
                
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 0.2)
                        .foregroundColor(Color.darkGray)
                        .frame(height: 52)
                        .overlay(alignment: .topLeading) {
                            Text("Audio")
                                .foregroundColor(Color.darkBlue)
                                .padding(5)
                                .background(Color.White2)
                                .offset(x: 16, y: -16)
                        }
                        .overlay(alignment: .leading) {
                            Text("Click the mic icon to start recording") //Audio
                                .padding(.leading)
                                .foregroundColor(Color(uiColor: .systemGray3))
                                .opacity(self.record ? 0 : 1)
                                .opacity(self.isPlaying ? 0 : 1)
                        }
                        .overlay(alignment: .trailing) {
                            if self.record {
                                HStack {
                                    Text(String(format: "%.1f", countDownTimer))
                                        .font(.system(size: 12, weight: .bold))
                                        .opacity(0.80)
                                        .onReceive(timer) { _ in
                                            if countDownTimer < 0.8 && timerRunning {
                                                countDownTimer += 0.1
                                            } else {
                                                timerRunning = false
                                                self.recorder.stop()
                                                countDownTimer = 0.0
                                                self.record = false
                                            }
                                            timerRunning = true
                                        }
                                    
                                    Image(systemName: "record.circle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.red)
                                        .onTapGesture {
                                            startAndStopRecord()
                                        }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                
                            } else {
                                
                                if isPlaying {
                                    HStack(spacing: 5) {
                                        Text(vName)
                                        Spacer()
                                        
                                        Button {
                                            preparePlayer()
                                            audioPlayer.play()
                                        } label: {
                                            Image(systemName: "play.circle")
                                                .imageScale(.large).foregroundColor(Color.darkBlue)
                                        }
                                        
                                        Button {
                                            do {
                                                try FileManager.default.removeItem(at: getFileUrl())
                                                isRecording = true
                                                isPlaying = false
                                                isThereAnAudio = false
                                            } catch {
                                                print("File could not be deleted!")
                                            }
                                        } label: {
                                            Image(systemName: "x.circle")
                                                .imageScale(.large).foregroundColor(.red)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                if isRecording {
                                    Image(systemName: "mic.fill")
                                        .resizable()
                                        .frame(width: 15, height: 20)
                                        .foregroundColor(Color.darkBlue)
                                        .padding(.trailing)
                                        .onTapGesture {
                                            startAndStopRecord()
                                        }
                                }
                            }
                        }
                    
                }
                
                Picker(
                    selection: $selectedCategory,
                    label: Text(""),
                    content: {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.rawValue.localized)
                                .tag(category)
                        }
                    }
                )
                .padding(5)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 0.2)
                        .foregroundColor(Color.darkGray)
                )
                .overlay(alignment: .topLeading) {
                    Text("Category")
                        .foregroundColor(Color.darkBlue)
                        .padding(6)
                        .background(Color.White2)
                        .offset(x: 16, y: -16)
                    
                }
                
                
                Button {
                    addPecs()
                    self.isToast = true
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                    //.fill(Color.buttonBlue)
                        .foregroundColor(checkRequiredField() ? Color.buttonBlue : Color.gray)
                        .frame(height: 56)
                        .overlay {
                            Text("Add")
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                }.disabled(!checkRequiredField())
                Spacer()
                
                
            }
        }
            .padding(.horizontal, 24)
            .sheet(isPresented: $isPickerShowing) {
                ImagePickerView(sourceType: .photoLibrary) { image in
                    self.image = image }
            }
            .alert(isPresented: $imageAlert, content: {
                Alert(title: Text("Error"), message: Text("Enable Access to photo library from Settings"))
            })
            .alert(isPresented: $voiceAlert, content: {
                Alert(title: Text("Error"), message: Text("Enable Access to microphone from Settings"))
            })
            .navigationBarTitle("Add New PECS")
        }.toolbar(.hidden,for: .tabBar)
      
    }
    
    func startAndStopRecord() {
        if checkPermission() {
            do {
                if self.record {
                    isThereAnAudio = true
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
    }
    
    func checkPhotoPermission() {
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
            } else {
                imageAlert.toggle()
            }
        }
    }
    
    func checkPermission() -> Bool {
        do {
            self.session = AVAudioSession.sharedInstance()
            try self.session.setCategory(.playAndRecord)
            
            self.session.requestRecordPermission { (status) in
                if !status {
                    self.voiceAlert.toggle()
                    isPermission = false
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return isPermission
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
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getFileUrl() -> URL {
        let filename = pecsName.isEmpty ? "myRecording.m4a" : "\(pecsName).m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    func addPecs() {
        Task {
            guard let image else { return }
            let returnedCKAsset: CKAsset? = try await Helper.shared.convertUIImageToCKAsset(image: image)
                        
            let pecs = PecsModel(
                imageURL: returnedCKAsset?.fileURL,
                audioURL: isThereAnAudio ? getFileUrl() : nil,
                name: pecsName,
                category: selectedCategory.rawValue
            )
            let decoded = UserDefaults.standard.data(forKey:"sec")
            
            if(decoded != nil){
                let decodedTeams = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [sech1]
                
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                
                var startTime : Date?
                var endTime : Date?
                
                for d in decodedTeams {
                    if d.category == selectedCategory.rawValue {
                        
                        startTime = dateFormatter.date(from: d.fromTime)
                        endTime = dateFormatter.date(from: d.toTime)
                        print("startTime: \(startTime)")
                    }
                }
                cloudViewModel.addPecs(pecs: pecs, startTime: startTime, endTime: endTime)
            }
            else{
                cloudViewModel.addPecs(pecs: pecs)
            }
            dismiss()
        }
    }
    
    func checkRequiredField() -> Bool {
        if image != nil && !pecsName.isEmpty{
            return true
        }
        return false
    }
    
}


struct AddPecsView_Previews: PreviewProvider {
    static var previews: some View {
        AddPecsView(isToast: Binding<Bool>.constant(false))
            .environmentObject(CloudViewModel())
    }
}
