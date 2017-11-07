//
//  RecordViewController.swift
//  CollectionView
//
//  Created by Mac on 10/31/17.
//  Copyright © 2017 AtulPrakash. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {

    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var showTimePicker: UIButton!
    //Mark:- Timer section variable
    let timePicker = UIDatePicker()
    var startTime = TimeInterval()
    var timer = Timer()
    var seconds = 00
    var isTimerRunning = false

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    //Mark:- Audio Section variable
    var recordingSession : AVAudioSession!
    var soundRecorder: AVAudioRecorder!
    var soundPlayer:AVAudioPlayer!
    let fileName = "sound.m4a"
    let saveFileName = "recorded.m4a"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showTimePicker.setTitle("Show Time Picker", for: .normal)
        seconds = UserDefaults.standard.integer(forKey: "timerValue")
        
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("Recording Allowed")
                        self.recordButton.isEnabled = true
                        self.recordButton.alpha = 1.0
                    } else {
                        self.ShowAlert("Info", message: "App require to record Audio. Kindly allow to access the microphone")
                        self.recordButton.isEnabled = false
                        self.recordButton.alpha = 0.5
                    }
                }
            }
        } catch {
            print("failed to record!")
        }
        
        //First time
        soundRecorder = nil
        soundPlayer = nil
        
        stopButton.isEnabled = false
        stopButton.alpha = 0.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if seconds > 0 && isTimerRunning == false {
            timerLabel.text = timeString(time: TimeInterval(seconds))
            runTimer()
        }
        
        if isFileExists() {
            playButton.isEnabled = true
            playButton.alpha = 1.0
        }else{
            playButton.isEnabled = false
            playButton.alpha = 0.5
        }
    }
    
    func openTimePicker()  {
        timePicker.datePickerMode = UIDatePickerMode.time
        timePicker.frame = CGRect(x: 0.0, y: (self.view.frame.height/2 + 60), width: self.view.frame.width, height: 150.0)
        timePicker.backgroundColor = UIColor.white
        self.view.addSubview(timePicker)
        timePicker.addTarget(self, action: #selector(RecordViewController.startTimeDiveChanged), for: UIControlEvents.valueChanged)
    }
    
    @objc func startTimeDiveChanged(sender: UIDatePicker) {
        let date = sender.date
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let hour = components.hour!
        let minute = components.minute!
        let second = components.second!
        seconds = hour*3600 + minute*60 + second
        print(seconds)
        timerLabel.text = timeString(time: TimeInterval(seconds))
//        timePicker.removeFromSuperview() // if you want to remove time picker
//        showTimePicker.setTitle("Show Time Picker", for: .normal)
//
//        if isTimerRunning == false {
//            runTimer()
//        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(RecordViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
        } else {
            seconds -= 1
        }
        timerLabel.text = timeString(time: TimeInterval(seconds))
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i : %02i : %02i", hours, minutes, seconds)
    }
    
    // MARK: - Button Action
    
    @IBAction func selectTimerAction(_ sender: Any) {
        if showTimePicker.titleLabel?.text == "Show Time Picker" {
            showTimePicker.setTitle("Start Timer", for: .normal)
            openTimePicker()
            timer.invalidate()
            isTimerRunning = false

        }else{
            showTimePicker.setTitle("Show Time Picker", for: .normal)
            if seconds > 0 && isTimerRunning == false{
                runTimer()
                isTimerRunning = true
            }
            timePicker.removeFromSuperview()
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: {
                UserDefaults.standard.set(self.seconds, forKey: "timerValue")
                self.commonStop()
            }
        )
    }
    
    @IBAction func resetAllAction(_ sender: Any) {
        timer.invalidate()
        seconds = 0
        timerLabel.text = timeString(time: TimeInterval(seconds))
        UserDefaults.standard.removeObject(forKey: "timerValue")
        saveFile(toDirectory: false)
        playButton.isEnabled = false
        playButton.alpha = 0.5
        stopButton.isEnabled = false
        stopButton.alpha = 0.5
        recordButton.isEnabled = true
        recordButton.alpha = 1.0
    }
    
    @IBAction func recordAction(_ sender: Any) {
        commonStop()
        if soundRecorder == nil{
            do {
                try recordingSession.setActive(true)
                setupRecorder()
                soundRecorder.record()
                recordButton.isEnabled = false
                recordButton.alpha = 0.5
                stopButton.isEnabled = true
                stopButton.alpha = 1.0
                playButton.isEnabled = false
                playButton.alpha = 0.5
            } catch {
                
            }
        }
    }
    
    @IBAction func stopAction(_ sender: Any) {
        commonStop()
        stopButton.isEnabled = false
        stopButton.alpha = 0.5
        recordButton.isEnabled = true
        recordButton.alpha = 1.0
        playButton.isEnabled = true
        playButton.alpha = 1.0
    }
    
    @IBAction func playAction(_ sender: Any) {
        commonStop()
        if soundPlayer == nil{
            preparePlayer()
            soundPlayer.play()
            playButton.isEnabled = false
            playButton.alpha = 0.5
            recordButton.isEnabled = false
            recordButton.alpha = 0.5
            stopButton.isEnabled = true
            stopButton.alpha = 1.0
        }
    }
    
    //Mark:- Audio Method Section
    
    func commonStop() {
        if soundRecorder != nil{
            do {
                soundRecorder.stop()
                soundRecorder = nil
                try recordingSession.setActive(false)
            } catch {
                print("Error in stopping Recorder")
            }
        }
        if soundPlayer != nil{
            soundPlayer.stop()
            soundPlayer = nil
        }
    }
    
    func getFileURL(_ fileName:String) -> NSURL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent(fileName)
        return soundURL as NSURL?
    }
    
    func saveFile(toDirectory:Bool) {
        if isFileExists(){
            do {
                try FileManager.default.removeItem(at: getFileURL(saveFileName)! as URL)
                print("Audio File Removed")
            } catch {
                print("Unable to delete file")
            }
        }
        
        if toDirectory{
            do {
                try FileManager.default.copyItem(at: getFileURL(fileName)! as URL, to: getFileURL(saveFileName)! as URL)
                print("Audio File Saved")
            } catch {
                print("Unable to create file")
            }
        }
    }
    
    func isFileExists() -> Bool {
        if FileManager.default.fileExists(atPath: (getFileURL(saveFileName)?.path)!){
            print("Audio File Available")
            return true
        }else{
            print("Audio File Not Available")
            return false
        }
    }
    
    func setupRecorder() {
        //set the settings for recorder
        
        let recordSettings = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
            ] as [String : Any]
        
        do {
            soundRecorder = try AVAudioRecorder.init(url: getFileURL(fileName)! as URL, settings: recordSettings)
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        } catch let error as NSError {
            print("Recorder error: \(error.localizedDescription)")
            finishRecording(success: false)
        }
    }
    
    func preparePlayer() {
        do {
            soundPlayer = try AVAudioPlayer.init(contentsOf: getFileURL(saveFileName)! as URL)
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            } catch  {
                print("Unable to override speaker")
            }
        } catch let error as NSError {
            print("Audio error: \(error.localizedDescription)")
        }
    }
    
    func finishRecording(success: Bool) {
        if success {
            soundRecorder.stop()
            soundRecorder = nil
            print(success)
        } else {
            print("Somthing Wrong.")
        }
    }
    
    func ShowAlert(_ title:String, message:String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        // Cancel button
        let cancel = UIAlertAction(title: "Ok", style: .destructive, handler: { (action) -> Void in })
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//Mark:- AVAudioRecorderDelegate
extension RecordViewController:AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print(recorder.url)
        self.saveFile(toDirectory: true)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(String(describing: error?.localizedDescription))")
    }
}

//Mark:- AVAudioRecorderDelegate
extension RecordViewController:AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Playing Finished")
        playButton.isEnabled = true
        playButton.alpha = 1.0
        stopButton.isEnabled = false
        stopButton.alpha = 0.5
        recordButton.isEnabled = true
        recordButton.alpha = 1.0
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error while playing audio \(String(describing: error?.localizedDescription))")
    }
}
