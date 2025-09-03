import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var store = RecordingStore()
    @StateObject private var recorder = AudioRecorder()
    @State private var isRecording = false
    @State private var showRename: Recording? = nil
    @State private var visibleCount = 5
    @State private var showRecordingToast = false

var body: some View {
    NavigationView {
        VStack(spacing: 16) {
            Spacer()
                       
                       if isRecording {
                           WaveformView(levels: recorder.levels)
                               .frame(height: 120)
                               .transition(.opacity.combined(with: .scale))
                               .animation(.easeInOut(duration: 0.4), value: isRecording)
                       }
                       
                       Spacer()
                       
                       Button(action: {
                           withAnimation {
                               if isRecording {
                                   recorder.stopRecording()
                                   isRecording.toggle()
                                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                       store.refresh()
                                   }
                               } else {
                                   do {
                                       let url = store.newRecordingURL()
                                       try recorder.startRecording(to: url)
                                       isRecording.toggle()
                                   } catch {
                                       print("Failed to start recording: \(error)")
                                   }
                               }
                           }
                       }) {
                           Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                               .font(.system(size: 50))
                               .foregroundColor(isRecording ? .red : .blue)
                               .shadow(radius: 6)
                       }
                       .padding(.bottom, 40)
                       if isRecording {
                           Text(recorder.elapsed.mmss)
                               .font(.caption)
                               .foregroundColor(.secondary)
                               .transition(.opacity)
                               .animation(.easeInOut(duration: 0.2), value: recorder.elapsed)
                       }

            // List of recordings
            List {
                if store.recordings.isEmpty {
                    ContentUnavailableView("No recordings yet", systemImage: "waveform", description: Text("Tap the mic to start"))
                }
                ForEach(store.recordings.prefix(visibleCount)) { rec in
                    NavigationLink(destination: PlayerView(recording: rec).environmentObject(store)) {
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
                                if isRecording {
                                    showRecordingToast = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                        showRecordingToast = false
                                    }
                                } else {
                                    showRename = rec
                                }
                            } label: {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            if isRecording {
                                showRecordingToast = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    showRecordingToast = false
                                }
                            } else {
                                store.delete(rec)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                if store.recordings.count > visibleCount {
                    HStack {
                        Spacer()
                        Button("Show more") {
                            if isRecording {
                                showRecordingToast = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    showRecordingToast = false
                                }
                            } else {
                                let newCount = visibleCount + 5
                                visibleCount = min(newCount, store.recordings.count)
                            }
                        }
                        Spacer()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .disabled(isRecording)
        }
        .navigationTitle("Voice Notes")
        .overlay(
            Group {
                if showRecordingToast {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.red)
                            Text("Please stop the recording to perform any further action")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.bottom, 100)
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: showRecordingToast)
                }
            }
        )
    }
    .sheet(item: $showRename) { rec in
        RenameSheet(recording: rec) { newTitle in
            store.rename(rec, to: newTitle)
        }
    }
}

    private func toggleRecording() {
        if isRecording {
            recorder.stopRecording()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                store.refresh()
            }
        } else {
            do {
                let url = store.newRecordingURL()
                try recorder.startRecording(to: url)
            } catch {
                print("Failed to start recording: \(error)")
            }
        }
    }
}
