//
//  WaveformView.swift
//  VoiceNote
//
//  Created by Khyati Mirani on 01/09/25.
//


import SwiftUI

struct WaveformView: View {
    var levels: [CGFloat]

    // Sine wave animation
    @State private var phase: CGFloat = 0
    let amplitudeScale: CGFloat = 1.5   // boost mic amplitude
    let sineAmplitude: CGFloat = 0.15   // base sine wave amplitude
    let animationSpeed: CGFloat = 2.0   // oscillation speed

    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let w = size.width
                let h = size.height
                let count = levels.count
                guard count > 1 else { return }

                let stepX = w / CGFloat(count - 1)

                var path = Path()
                path.move(to: CGPoint(x: 0, y: h/2))

                for (i, level) in levels.enumerated() {
                    let normalized = max(0.05, min(1.0, level))
                    let micValue = (normalized - 0.5) * h * amplitudeScale

                    // Add sine wave interpolation
                    let sineOffset = sin((CGFloat(i) / w) * .pi * 2 + phase) * h * sineAmplitude

                    let y = h/2 - micValue + sineOffset
                    path.addLine(to: CGPoint(x: CGFloat(i) * stepX, y: y))
                }

                // Close path downwards to make it fillable
                path.addLine(to: CGPoint(x: w, y: h))
                path.addLine(to: CGPoint(x: 0, y: h))
                path.closeSubpath()

                // Gradient fill
                ctx.fill(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [.purple.opacity(0.7), .blue]),
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: 0, y: h)
                    )
                )
            }
            .onAppear {
                // Animate sine wave oscillation
                withAnimation(.linear(duration: 1 / Double(animationSpeed)).repeatForever(autoreverses: false)) {
                    phase = .pi * 2
                }
            }
        }
        .accessibilityHidden(true)
    }
}
