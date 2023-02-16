//
//  AudioManger.swift
//  Sabeel
//
//  Created by hoton on 26/07/1444 AH.
//

import Foundation
import SwiftUI
import AVFoundation


class AudioPlayer: NSObject , ObservableObject, AVAudioPlayerDelegate  {
    var audioPlayer: AVAudioPlayer!
    
    var isPlaying = false
    func startPlayback (audio: URL) {
        let playbackSession = AVAudioSession.sharedInstance()
        
        do {
            try playbackSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing over the device's speakers failed")
        }
        
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audio)
            audioPlayer.delegate = self
            audioPlayer.play()
            isPlaying = true
        } catch {
            print("Playback failed.")
        }
    }
    

    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            isPlaying = false
        }
    }
}

