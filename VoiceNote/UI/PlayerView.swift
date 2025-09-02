//
//  PlayerView.swift
//  VoiceNote
//
//  Created by Khyati Mirani on 01/09/25.
//


import SwiftUI

struct PlayerView: View {
let recording: Recording
@StateObject private var player = AudioPlayer()

var body: some View {
    VStack(spacing: 32) {
        // Title + timestamp
        VStack(spacing: 4) {
            Text(recording.title)
                .font(.title2.bold())
            Text("\(recording.createdAt, formatter: DateFormatter.shortDateTime)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.top, 16)

        // Progress view
        VStack(spacing: 8) {
            ProgressView(value: player.progress)
                .progressViewStyle(.linear)
                .padding(.horizontal)
            HStack {
                Text(formatTime(player.progress * player.duration))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text(recording.duration.mmss)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }

        // Playback controls
        // Playback controls
        HStack(spacing: 40) {
            Button {
                player.seek(to: max(0, player.progress - 0.05))
            } label: {
                Image(systemName: "gobackward.10")
            }

            Button {
                if player.isPlaying {
                    player.pause()
                } else {
                    player.play()
                }
            } label: {
                Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 72))
                    .shadow(radius: 4)
            }

            Button {
                player.seek(to: min(1, player.progress + 0.05))
            } label: {
                Image(systemName: "goforward.10")
            }
        }

        .font(.title)
        .padding(.top, 12)

        Spacer()
    }
    .padding()
    .onAppear { player.load(url: recording.url) }
    .onDisappear { player.stop() }
}

private func formatTime(_ seconds: Double) -> String {
    let secs = Int(seconds)
    let m = secs / 60
    let s = secs % 60
    return String(format: "%02d:%02d", m, s)
}

}
