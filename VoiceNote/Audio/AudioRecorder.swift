import Foundation
import AVFoundation
import Combine

class AudioRecorder: ObservableObject {
    
    private var engine: AVAudioEngine?
    private var cancellable: AnyCancellable?
    private var recorder: AVAudioRecorder?
    private var displayLink: CADisplayLink?
    
    @Published var levels: [CGFloat] = []
    private let maxSamples = 100  // number of waveform points shown
    @Published var elapsed: TimeInterval = 0
    
    // File-based recording that saves to the provided URL and updates levels
    func startRecording(to url: URL) throws {
        levels.removeAll(keepingCapacity: true)
        // Configure audio session for recording
        let session = AVAudioSession.sharedInstance()
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
        recorder = rec
        startMeters()
    }

    func startRecording() {
        // Configure audio session for recording
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setPreferredSampleRate(44100)
            try session.setPreferredIOBufferDuration(0.0232) // ~1024 frames at 44.1kHz
            try session.setActive(true, options: [])
        } catch {
            print("Audio session setup failed: \(error)")
            return
        }

        // Reset any existing engine
        engine?.stop()
        engine = AVAudioEngine()
        guard let engine = engine else { return }
        
        let input = engine.inputNode
        let format = input.inputFormat(forBus: 0)
        
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            let channelData = buffer.floatChannelData?[0]
            let channelDataValue = stride(from: 0,
                                          to: Int(buffer.frameLength),
                                          by: buffer.stride).map { channelData![$0] }
            
            // RMS power
            let rms = sqrt(channelDataValue.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
            let level = max(0.0, CGFloat(rms) * 10) // normalize
            
            DispatchQueue.main.async {
                self.levels.append(level)
                if self.levels.count > self.maxSamples {
                    self.levels.removeFirst()
                }
            }
        }
        
        do {
            try engine.start()
        } catch {
            print("Failed to start engine: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        if let engine = engine {
            engine.inputNode.removeTap(onBus: 0)
            engine.stop()
            self.engine = nil
        }
        if let rec = recorder {
            rec.stop()
            recorder = nil
        }
        stopMeters()
        elapsed = 0
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            // Non-fatal
        }
    }

    private func startMeters() {
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopMeters() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func tick() {
        guard let rec = recorder else { return }
        rec.updateMeters()
        // Map averagePower [-160, 0] dB to [0, 1]
        let power = max(0, (rec.averagePower(forChannel: 0) + 60) / 60)
        let level = CGFloat(power)
        levels.append(level)
        if levels.count > maxSamples {
            levels.removeFirst()
        }
        elapsed = rec.currentTime
    }
}
