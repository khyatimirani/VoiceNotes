//
//  Recording.swift
//  VoiceNote
//
//  Created by Khyati Mirani on 01/09/25.
//


import Foundation


struct Recording: Identifiable, Hashable {
    let id: UUID
    var title: String
    let url: URL
    let createdAt: Date
    let duration: TimeInterval
}


extension TimeInterval {
    var mmss: String {
        let ti = Int(self)
        let m = ti / 60
        let s = ti % 60
        return String(format: "%02d:%02d", m, s)
    }
}


extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
}
