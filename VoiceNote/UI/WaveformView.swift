//
//  WaveformView.swift
//  VoiceNote
//
//  Created by Khyati Mirani on 01/09/25.
//


import SwiftUI


struct WaveformView: View {
    var levels: [CGFloat]
    
    
    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let w = size.width
                let h = size.height
                let count = levels.count
                guard count > 0 else { return }
                let gap: CGFloat = 2
                let barWidth = max(2, (w / CGFloat(count)) - gap)
                var x: CGFloat = 0
                for level in levels.suffix(count) {
                    let clamped = max(0.05, min(1.0, level))
                    let barHeight = clamped * h
                    let rect = CGRect(x: x, y: (h - barHeight)/2, width: barWidth, height: barHeight)
                    ctx.fill(Path(roundedRect: rect, cornerRadius: barWidth/2), with: .color(.accentColor))
                    x += barWidth + gap
                }
            }
        }
        .accessibilityHidden(true)
    }
}