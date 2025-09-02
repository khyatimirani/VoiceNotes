//
//  AudioPlayer.swift
//  VoiceNote
//
//  Created by Khyati Mirani on 01/09/25.
//


import Foundation
import AVFoundation
import Combine


final class AudioPlayer: ObservableObject {
@Published private(set) var isPlaying = false
@Published var progress: Double = 0 // 0..1
@Published private(set) var duration: TimeInterval = 0


private var player: AVAudioPlayer?
private var timer: Timer?


func load(url: URL) {
stop()
do {
let p = try AVAudioPlayer(contentsOf: url)
p.prepareToPlay()
player = p
duration = p.duration
progress = 0
} catch {
print("Player load error: \(error)")
}
}


func play() {
guard let p = player else { return }
if !p.isPlaying { p.play(); isPlaying = true; startTimer() }
}


func pause() {
player?.pause(); isPlaying = false; stopTimer()
}


func stop() {
player?.stop(); isPlaying = false; progress = 0; stopTimer()
}


func seek(to fraction: Double) {
guard let p = player else { return }
p.currentTime = fraction * p.duration
progress = fraction
}


private func startTimer() {
stopTimer()
timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
guard let self, let p = self.player else { return }
self.progress = p.duration > 0 ? p.currentTime / p.duration : 0
if !p.isPlaying { self.isPlaying = false; self.stopTimer() }
}
}


private func stopTimer() {
timer?.invalidate(); timer = nil
}
}