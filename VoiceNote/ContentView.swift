import SwiftUI
import AVFoundation

struct ContentView: View {
@StateObject private var store = RecordingStore()
@StateObject private var recorder = AudioRecorder()

@State private var showRename: Recording? = nil

var body: some View {
    NavigationView {
        VStack(spacing: 16) {
            
            if recorder.isRecording {
                WaveformView(levels: recorder.levelHistory)
                    .frame(height: 120)
                    .background(Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    //.animation(.easeOut(duration: 0.15), value: recorder.levelHistory)
                    .transition(.opacity.combined(with: .scale))
                    .animation(.easeInOut(duration: 0.4), value: recorder.isRecording)
                      }
     
            // Record button
            Button(action: toggleRecording) {
                ZStack {
                    Circle()
                        .fill(recorder.isRecording ? Color.red : Color.accentColor)
                        .frame(width: 88, height: 88)
                        .shadow(radius: 8)
                    Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 8)
            .accessibilityLabel(recorder.isRecording ? "Stop Recording" : "Start Recording")

            // List of recordings
            List {
                if store.recordings.isEmpty {
                    ContentUnavailableView("No recordings yet", systemImage: "waveform", description: Text("Tap the mic to start"))
                }
                ForEach(store.recordings) { rec in
                    NavigationLink(destination: PlayerView(recording: rec)) {
                        HStack {
                            Image(systemName: "waveform")
                            VStack(alignment: .leading, spacing: 4) {
                                Text(rec.title).font(.headline)
                                Text("\(rec.createdAt, formatter: DateFormatter.shortDateTime) · \(rec.duration.mmss)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button {
                                showRename = rec
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            store.delete(rec)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Voice Notes")
    }
    .sheet(item: $showRename) { rec in
        RenameSheet(recording: rec) { newTitle in
            store.rename(rec, to: newTitle)
        }
    }
}

private func toggleRecording() {
    if recorder.isRecording {
        recorder.stopRecording()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            store.refresh()
        }
    } else {
        recorder.requestPermissionIfNeeded { granted in
            guard granted else { return }
            do {
                let url = store.newRecordingURL()
                try recorder.startRecording(to: url)
            } catch {
                print("Start record error: \(error)")
            }
        }
    }
}


}
