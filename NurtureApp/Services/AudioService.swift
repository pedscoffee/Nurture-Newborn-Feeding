import Foundation
import AVFoundation

class AudioService: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    func playSound(_ sound: AlarmSound) {
        guard let fileName = sound.fileName else { return }
        
        // In a real app, these files would need to be in the bundle.
        // Since I cannot add binary assets, this is a placeholder implementation.
        // I will add a comment explaining where to put the files.
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("Audio file not found: \(fileName)")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        audioPlayer?.stop()
    }
}
