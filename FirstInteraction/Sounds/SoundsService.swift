//
//  SoundsService.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 17/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class SoundsService {
    var anterior: String?
    
    var audioPlayers: [SoundsName: AVAudioPlayer?] = [:]
    
    func falling(){
        prepareAndPlay(forResource: .falling)?.volume = 0.002
       
    }
    
    func didFall(){
        prepareAndPlay(forResource: .didFall)?.volume = 0.2
       
    }
    
    func didBeginDrag(){
        prepareAndPlay(forResource: .didBeginDrag)?.volume = 0.2
        
    }
    
    func prepareAndPlay(forResource: SoundsName, ofType: String = "mp3", repeating: Bool = false) -> AVAudioPlayer? {
        if let audioPlayer = self.audioPlayers[forResource] {
            audioPlayer?.numberOfLoops = repeating ? 2 : 0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            return audioPlayer
        } else {
            
            do{
                if let fileURL = Bundle.main.path(forResource: forResource.rawValue, ofType: ofType) {
                    let audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                    audioPlayers[forResource] = audioPlayer
                    audioPlayer.numberOfLoops = repeating ? 2 : 0
                    
                    audioPlayer.prepareToPlay()
                    
                    audioPlayer.play()
                    
                    return audioPlayer
                } else {
                    print("No file with specified name exists")
                }
            }
            catch let error {
                print("Can't play the audio file failed with an error \(error.localizedDescription)")
            }
        }
        
        return nil
    }
}
