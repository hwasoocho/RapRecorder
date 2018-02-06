import UIKit
import AVFoundation

class RapTableViewCell: UITableViewCell, AVAudioPlayerDelegate {

    var rapPath: URL?
    var rapPlayer: AVAudioPlayer?
    
    @IBOutlet weak var rapTitle: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if rapPlayer == nil {
            do {
                rapPlayer = try AVAudioPlayer.init(contentsOf: rapPath!)
                rapPlayer?.delegate = self
            } catch {
                return // There is a case where the file is not ready to be played yet.
            }
        }
        if rapPlayer!.isPlaying {
            rapPlayer!.pause()
            rapPlayer!.currentTime = 0
            playButton.setImage(UIImage(named: "Small Play Button"), for: .normal)   // Change play button image.
        } else {
            rapPlayer!.play()
            playButton.setImage(UIImage(named: "Small Stop Button"), for: .normal)   // Change play button image.
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(UIImage(named: "Small Play Button"), for: .normal)   // Change play button image.
    }
}
