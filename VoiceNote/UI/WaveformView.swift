//
//  WaveformView.swift
//  VoiceNote
//
//  Created by Khyati Mirani on 01/09/25.
//

import SwiftUI

struct WaveformView: View {
    var levels: [CGFloat]

    // Visual tuning
    let amplitudeScale: CGFloat = 2.0   // exaggerates mic values
    let sineAmplitude: CGFloat = 0.1    // small ripple for extra curve
    let baseFrequency: CGFloat = 1.8    // how “wavy” the path is

    var body: some View {
        GeometryReader { _ in
            TimelineView(.animation) { timeline in
                Canvas { ctx, size in
                    let w = size.width
                    let h = size.height
                    let count = levels.count
                    guard count > 1 else { return }

                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let phase = CGFloat(t) * 2.5  // continuous wave motion
                    let stepX = w / CGFloat(max(1, count - 1))

                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: h/2))

                    for (i, level) in levels.enumerated() {
                        let normalized = max(0, min(1, level))
                        let micValue = (normalized - 0.5) * h * amplitudeScale

                        // extra sine offset for more curve
                        let x = CGFloat(i) * stepX
                        let sineOffset = sin((x / w) * baseFrequency * .pi * 2 + phase) * h * sineAmplitude

                        let y = h/2 - micValue + sineOffset
                        path.addLine(to: CGPoint(x: x, y: y))
                    }

                    // close path to fill
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.addLine(to: CGPoint(x: 0, y: h))
                    path.closeSubpath()

                    ctx.fill(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [.cyan.opacity(0.85), .teal.opacity(0.85)]),
                            startPoint: CGPoint(x: 0, y: 0),
                            endPoint:   CGPoint(x: 0, y: h)
                        )
                    )
                }
            }
        }
        .accessibilityHidden(true)
    }
}

