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

class SoundsService{
    var audioPlayer: AVAudioPlayer?
    var anterior: String?
    
    func falling(){
        prepareAndPlay(forResource: .falling)
        audioPlayer?.volume = 0.002
    }
    
    func didFall(){
        prepareAndPlay(forResource: .didFall)
        audioPlayer?.volume = 0.2
    }
    
    func didBeginDrag(){
        prepareAndPlay(forResource: .didBeginDrag)
        audioPlayer?.volume = 0.2
    }
    
    func prepareAndPlay(forResource: SoundsName, ofType: String = "mp3", repeating: Bool = false) {
        
        if anterior != forResource.rawValue || anterior == nil {
            
            do{
                if let fileURL = Bundle.main.path (forResource: forResource.rawValue, ofType: ofType){
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                    audioPlayer?.numberOfLoops = repeating ? 2 : 0
                    audioPlayer?.prepareToPlay()
                    anterior = forResource.rawValue
                } else {
                    print("No file with specified name exists")
                }
            }
            catch let error {
                print("Can't play the audio file failed with an error \(error.localizedDescription)")
            }
        }
        
        audioPlayer?.play()
    }
}
