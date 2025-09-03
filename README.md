# VoiceNotes 🎙️

A lightweight iOS app built with SwiftUI and AVFoundation that lets you record, play back, and manage your personal voice notes. It features a dynamic waveform visualization, recording management, and smooth animations for a modern user experience.

✨ **Features**

🎤 Record Voice Notes with real-time microphone access

🌊 Animated Waveform View that reacts to your voice amplitude

▶️ Playback Support with a minimalistic player screen

📝 Rename & Delete Recordings directly in-app

📂 Persistent Storage for saving and reloading notes

🛠️ **Tech Stack**

SwiftUI – for UI and animations

AVFoundation – for audio recording & playback

Core Animation + Canvas – for waveform rendering

MVVM-ish Architecture – with AudioRecorder, RecordingStore, and PlayerView

	
🚀 **Getting Started**
Prerequisites

macOS with Xcode 15+

iOS 16+ (tested on iOS 18 simulator)

Installation

Clone the repository:

git clone https://github.com/khyatimirani/VoiceNotes.git
cd VoiceNotes


Open in Xcode:

open VoiceNotes.xcodeproj

Run on a simulator or a physical device.

📂 **Project Structure**
VoiceNotes/
 ├── Models/
 │   ├── Recording.swift
 │   └── RecordingStore.swift
 ├── Views/
 │   ├── ContentView.swift
 │   ├── PlayerView.swift
 │   ├── WaveformView.swift
 │   └── RenameSheet.swift
 ├── Audio/
 │   └── AudioRecorder.swift
 ├── Resources/
 │   └── Assets.xcassets
 └── VoiceNotesApp.swift

🔒 **Permissions**

This app requires Microphone Access.
Make sure Info.plist includes:

<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record your voice notes.</string>

