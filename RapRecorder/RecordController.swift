//
//  RecordController.swift
//  Rap
//
//  Created by Hwa Soo on 07/10/2017.
//  Copyright © 2017 hwa. All rights reserved.
//

import AVFoundation

class RecordController: NSObject, AVAudioRecorderDelegate {
    var beatPlayer: AVAudioPlayer?
    var recorder: AVAudioRecorder?
    
    init?(beatFile: String) {
        super.init()
        
        setupBeatPlayer(beatFile: beatFile)
        setupRecorder()
        
        if (beatPlayer == nil || recorder == nil) {
            return nil
        }
    }
    
    func setupBeatPlayer(beatFile: String) {
        let beatPath = Util.beatPath(file: beatFile)
        do {
            try beatPlayer = AVAudioPlayer.init(contentsOf: beatPath!)
        } catch let error as NSError {
            print("Error: \(error.domain)")
            return
        }
    }
    
    func setupRecorder() {
        let recordPath = Util.documentsDirectory().appendingPathComponent("RapRecording.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            try recorder = AVAudioRecorder.init(url: recordPath, settings: settings)
            recorder!.delegate = self
        } catch let error as NSError {
            print("Error: \(error.domain)")
            return
        }
    }
    
    
}
