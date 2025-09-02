//
//  RenameSheet.swift
//  VoiceNote
//
//  Created by Khyati Mirani on 01/09/25.
//
import SwiftUI
import AVFoundation

struct RenameSheet: View {
    let recording: Recording
    var onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $text)
            }
            .navigationTitle("Rename")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(text)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear { text = recording.title }
    }
}
