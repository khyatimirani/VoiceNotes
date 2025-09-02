//
//  RecordingStore.swift
//  VoiceNote
//
//  Created by Khyati Mirani on 01/09/25.
//


import Foundation
import AVFoundation


final class RecordingStore: ObservableObject {
@Published private(set) var recordings: [Recording] = []


private let fm = FileManager.default
private var docsURL: URL { fm.urls(for: .documentDirectory, in: .userDomainMask)[0] }


init() {
refresh()
}


func refresh() {
let urls = (try? fm.contentsOfDirectory(at: docsURL, includingPropertiesForKeys: [.creationDateKey], options: [.skipsHiddenFiles])) ?? []
let audioURLs = urls.filter { $0.pathExtension.lowercased() == "m4a" }


let list: [Recording] = audioURLs.compactMap { url in
let attrs = (try? url.resourceValues(forKeys: [.creationDateKey]))
let created = attrs?.creationDate ?? Date()
let title = url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "Recording-", with: "")
let duration = Self.readDuration(for: url)
return Recording(id: UUID(), title: title, url: url, createdAt: created, duration: duration)
}
.sorted { $0.createdAt > $1.createdAt }


DispatchQueue.main.async { self.recordings = list }
}


static func readDuration(for url: URL) -> TimeInterval {
// Fast way: AVURLAsset duration
let asset = AVURLAsset(url: url)
return CMTimeGetSeconds(asset.duration)
}


func delete(_ rec: Recording) {
try? fm.removeItem(at: rec.url)
refresh()
}


func rename(_ rec: Recording, to newTitle: String) {
let sanitized = newTitle.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "/", with: "-")
guard !sanitized.isEmpty else { return }
let newURL = rec.url.deletingLastPathComponent().appendingPathComponent("Recording-\(sanitized).m4a")
if rec.url != newURL {
try? fm.moveItem(at: rec.url, to: newURL)
refresh()
}
}


func newRecordingURL() -> URL {
let stamp = DateFormatter.shortDateTime.string(from: Date()).replacingOccurrences(of: ":", with: "-")
let name = "Recording-\(stamp).m4a"
return docsURL.appendingPathComponent(name)
}
}