import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    var beatPlayer: AVAudioPlayer?
    var recorder: AVAudioRecorder?
    var records: [RecordStruct] = []
    var recordsCount = 0                                    // Used for record filename.
    let recordsDirectory = Util.initRecordsDirectory()      // Creates or clears records directory.
    let rapsDirectory = Util.initRapsDirectory()            // Creates raps directory if not exist.
    let recordsBasename = "recordnumber"
    
    struct RecordStruct {
        var path: URL
        var startTime: Double
        var player: AVAudioPlayer?
    }

    // MARK: Outlets
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordsTableView: UITableView!
    @IBOutlet weak var beatButton: UIButton!
    @IBOutlet weak var beatVolumeSlider: UISlider!
    
    // MARK: Initializers
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent

        // Initialize beatPlayer.
        let beatPath = Util.beatPath(file: "1")
        try? beatPlayer = AVAudioPlayer.init(contentsOf: beatPath!)
        beatButton.setTitle("Beat No.1", for: .normal)              // Hard code. TODO.
        
        // Initialize recorder.
        prepareNewRecordFile()
        
        // TableView.
        recordsTableView.delegate = self
        recordsTableView.dataSource = self
        
        return
    }
    
    // MARK: Table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count-1      // Minus last one that is not yet recorded.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RapCellIdentifier", for: indexPath) as! RapTableViewCell
        
        cell.rapTitle.text = String(format: "%.1f", records[indexPath.row].startTime)
        cell.rapPath = records[indexPath.row].path
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            records.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: Private Methods
    func prepareNewRecordFile() {
        let filename = recordsBasename + String(recordsCount) + ".m4a"
        recordsCount += 1                                                               // Update recordsCount for next filename.
        let recordPath = recordsDirectory.appendingPathComponent(filename)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        try? recorder = AVAudioRecorder.init(url: recordPath, settings: settings)
        recorder!.delegate = self
        let record = RecordStruct.init(path: recordPath, startTime: 0.0, player: nil)
        records.append(record)
        recordsTableView.reloadData()   // Reload table data.
    }
    
    func addRecordPlayerToRecords() {
        // Adds an AVAudioPlayer to recordPlayers Array.
        try? records[records.count-1].player = AVAudioPlayer.init(contentsOf: records.last!.path)  // Assign AVAudioPlayer for the record file.
    }
    
    func playRecordPlayers() {
        for record in records {
            if record.player != nil {
                record.player!.play(atTime: record.player!.deviceCurrentTime + record.startTime)
            }
        }
    }
    
    func stopRecordPlayers() {
        for record in records {
            if record.player != nil {
                record.player!.pause()
                record.player!.currentTime = 0
            }
        }
    }
    
    // Export
    func mixRecords(outputFile: String) {
        let composition = AVMutableComposition()
        var audioMixInputParams: [AVMutableAudioMixInputParameters] = []
        
        // Beat
        let asset = AVURLAsset(url: beatPlayer!.url!)
        let timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        let audioTrack = asset.tracks(withMediaType: AVMediaType.audio)[0]
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let audioMixParams = AVMutableAudioMixInputParameters.init(track: audioTrack)
        audioMixParams.setVolume(beatVolumeSlider.value, at: kCMTimeZero)      // TODO: allow user to set volume for beat.
        audioMixInputParams.append(audioMixParams)
        try? compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: kCMTimeZero)
        
        // Records
        for record in records {
            if record.player != nil {
                let asset = AVURLAsset(url: record.path)
                let timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
                let audioTrack = asset.tracks(withMediaType: AVMediaType.audio)[0]
                let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
                let audioMixParams = AVMutableAudioMixInputParameters.init(track: audioTrack)
                audioMixInputParams.append(audioMixParams)
                try? compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: CMTimeMakeWithSeconds(record.startTime, 1))
            }
        }
        
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)!
        let audioMix = AVMutableAudioMix.init()
        audioMix.inputParameters = audioMixInputParams
        exporter.audioMix = audioMix
        exporter.outputURL = rapsDirectory.appendingPathComponent(outputFile)
        exporter.outputFileType = AVFileType.m4a
        
        exporter.exportAsynchronously {
            if exporter.status == AVAssetExportSessionStatus.completed {
                print("Done mixing")
            }
        }
    }
    
    // MARK: IBActions
    @IBAction func beatVolumeSliderValueChanged(_ sender: UISlider) {
        beatPlayer!.volume = sender.value
    }
    
    @IBAction func beatButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Change Beat", message: "Please choose a beat", preferredStyle: .actionSheet)
        func changeBeat(file: String) {
            let beatPath = Util.beatPath(file: file)
            try? beatPlayer = AVAudioPlayer.init(contentsOf: beatPath!)
        }
        for i in 1...8 {
            alert.addAction(UIAlertAction(title: "Beat No."+String(i), style: .default, handler: { (action) in
                changeBeat(file: String(i))
                self.beatButton.setTitle("Beat No."+String(i), for: .normal)
            }))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        beatPlayer!.pause()
        beatPlayer!.currentTime = 0
        stopRecordPlayers()
        playButton.setImage(UIImage(named: "Play Button"), for: .normal)
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        // If beatPlayer is currently not playing, play.
        if !beatPlayer!.isPlaying {
            beatPlayer!.volume = beatVolumeSlider.value
            beatPlayer!.play()
            playRecordPlayers()
        }
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        if !beatPlayer!.isPlaying {
            beatPlayer!.volume = beatVolumeSlider.value
            beatPlayer!.play()
        }
        records[records.count-1].startTime = beatPlayer!.currentTime
        recorder!.record()
    }
    
    @IBAction func recordButtonReleased(_ sender: UIButton) {
        recorder!.stop()
        addRecordPlayerToRecords()
        prepareNewRecordFile()          // Prepare to record file to record on.
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Rap Title", message: nil, preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            //getting the input values from user
            let title = alertController.textFields!.first!.text!
            self.mixRecords(outputFile: title + ".m4a")
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Title"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
}

