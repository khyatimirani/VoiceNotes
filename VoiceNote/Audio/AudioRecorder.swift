import Foundation
import AVFoundation
import Combine
import UIKit

final class AudioRecorder: ObservableObject {
    @Published private(set) var isRecording = false
    @Published var levelHistory: [CGFloat] = Array(repeating: 0.0, count: 60) // trailing bars

    private var recorder: AVAudioRecorder?
    private var displayLink: CADisplayLink?
    private var ema: CGFloat = 0 // exponential moving average for smooth waveform

    private let session = AVAudioSession.sharedInstance()

    func requestPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
        switch AVAudioApplication.shared.recordPermission {
        case .granted: completion(true)
        case .denied: completion(false)
        case .undetermined:
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        @unknown default:
            completion(false)
        }
    }

    func startRecording(to url: URL) throws {
        // Configure audio session
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try session.setActive(true)

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let rec = try AVAudioRecorder(url: url, settings: settings)
        rec.isMeteringEnabled = true
        rec.record()
        self.recorder = rec
        isRecording = true
        startMeters()
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    func stopRecording() {
        recorder?.stop()
        recorder = nil
        isRecording = false
        stopMeters()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func startMeters() {
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopMeters() {
        displayLink?.invalidate()
        displayLink = nil
        ema = 0
    }

    @objc private func tick() {
        guard let rec = recorder else { return }
        rec.updateMeters()
        // Map averagePower [-160, 0] dB to [0, 1]
        let p = CGFloat(max(0, (rec.averagePower(forChannel: 0) + 60) / 60))
        // Smooth with EMA for buttery waveform
        let alpha: CGFloat = 0.2
        ema = alpha * p + (1 - alpha) * ema
        levelHistory.append(ema)
        if levelHistory.count > 120 { levelHistory.removeFirst(levelHistory.count - 120) }
    }
}
