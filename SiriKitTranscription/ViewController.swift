//
//  ViewController.swift
//  SiriKitTranscription
//
//  Created by Allen Lai on 12/18/16.
//  Copyright © 2016 Allen Lai. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    
    var audioRec: AVAudioRecorder?
    var recFileURL: URL!
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermissions()
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    func checkPermissions () {
        if AVAudioSession.sharedInstance().recordPermission() != .granted {
            requestRecordPermissions()
        }
        
        if SFSpeechRecognizer.authorizationStatus() != .authorized {
            requestTranscribePermissions()
        }
    
    }
    
    func requestRecordPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { (allowed) in
            if allowed {
                
            } else {
                
            }
        }
    }

    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            if authStatus == .authorized {
                
            } else {
                
            }
            
            
        }
    }

    @IBAction func recordTapped(_ sender: Any) {

         guard audioRec != nil else {
            recordAudio()
            return
        }
        if (audioRec?.isRecording)! {
            audioRec?.stop()
        } else {
            recordAudio()
        }
        
    }
    
    func recordAudio() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        recFileURL = paths[0].appendingPathComponent("temp.mp4")
        if FileManager.default.fileExists(atPath: recFileURL.absoluteString) {
            do {
                try FileManager.default.removeItem(atPath: recFileURL.absoluteString)
            } catch {
                
            }
        }
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try session.setActive(true)
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 44100,
                            AVNumberOfChannelsKey: 2,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                            ]
            audioRec = try AVAudioRecorder(url: recFileURL, settings: settings)
            audioRec?.delegate = self
            audioRec?.record()
            
            self.recordButton.setTitle("stop", for: .normal)
            
        } catch {
            print("error")
        }
        
    }
    
    func transcribeAudio() {
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: recFileURL)
        
        recognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            guard let result = result else {
                return
            }
            
            let text = result.bestTranscription.formattedString
            self.textView.text = text
            
            if result.isFinal {
                let text = result.bestTranscription.formattedString
                self.textView.text = text
            }
            
        })
        
        
    }
    
}

extension ViewController: AVAudioRecorderDelegate {

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordButton.setTitle("Record", for: .normal)
        if flag {
            // success

            playAudio()
            transcribeAudio()
        } else {

        }
        
    }

    func playAudio () {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recFileURL)
            audioPlayer?.play()
        }catch {
            
        }
    }
    
}






