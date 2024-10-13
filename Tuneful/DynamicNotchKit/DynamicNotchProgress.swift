//
//  DynamicNotchProgress.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2024-08-30.
//

import SwiftUI

public class DynamicNotchProgress {
    private var internalDynamicNotch: DynamicNotch<InfoView>

    public init(progress: Binding<CGFloat>, title: String, description: String? = nil, progressText: Bool = false, progressBarColor: Color = .white, style: DynamicNotch<InfoView>.Style = .auto) {
        internalDynamicNotch = DynamicNotch(style: style) {
            InfoView(progress: progress, progressBarColor: progressBarColor, title: title, description: description, numberOverlay: progressText)
        }
    }

    public func setContent(progress: Binding<CGFloat>, title: String, description: String? = nil, progressText: Bool = false, progressBarColor: Color = .white) {
        internalDynamicNotch.setContent {
            InfoView(progress: progress, progressBarColor: progressBarColor, title: title, description: description, numberOverlay: progressText)
        }
    }

    public init(progress: Binding<CGFloat>, title: String, description: String? = nil, iconOverlay: Image! = nil, progressBarColor: Color = .white, style: DynamicNotch<InfoView>.Style = .auto) {
        internalDynamicNotch = DynamicNotch(style: style) {
            InfoView(progress: progress, progressBarColor: progressBarColor, title: title, description: description, iconOverlay: iconOverlay)
        }
    }

    public func setContent(progress: Binding<CGFloat>, title: String, description: String? = nil, iconOverlay: Image! = nil, progressBarColor: Color = .white) {
        internalDynamicNotch.setContent {
            InfoView(progress: progress, progressBarColor: progressBarColor, title: title, description: description, iconOverlay: iconOverlay)
        }
    }

    public func show(on screen: NSScreen = NSScreen.screens[0], for time: Double = 0) {
        internalDynamicNotch.show(on: screen, for: time)
    }

    public func hide() {
        internalDynamicNotch.hide()
    }

    public func toggle() {
        internalDynamicNotch.toggle()
    }
}

public extension DynamicNotchProgress {
    struct InfoView: View {
        @Binding var progress: CGFloat
        let progressBarColor: Color

        let title: String
        let description: String?

        let numberOverlay: Bool?
        let iconOverlay: Image?

        init(progress: Binding<CGFloat>, progressBarColor: Color, title: String, description: String? = nil, numberOverlay: Bool? = nil, iconOverlay: Image? = nil) {
            _progress = progress
            self.progressBarColor = progressBarColor
            self.title = title
            self.description = description
            self.numberOverlay = numberOverlay
            self.iconOverlay = iconOverlay
        }

        public var body: some View {
            HStack(spacing: 10) {
                ProgressRing(to: $progress, color: progressBarColor)
                    .overlay {
                        if numberOverlay == true {
                            if #available(macOS 13.0, *) {
                                Text("\(Int(progress * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.numericText()) // .numericText() is only available on macOS 13+
                                    .animation(.smooth, value: progress)
                            } else {
                                Text("\(Int(progress * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        if iconOverlay != nil {
                            iconOverlay
                                .foregroundStyle(progressBarColor)
                        }
                    }
                textView()
                Spacer(minLength: 0)
            }
            .frame(height: 40)
        }

        func textView() -> some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)

                if let description {
                    Text(description)
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                }
            }
        }
    }

    struct ProgressRing: View {
        @Binding var target: CGFloat
        let color: Color
        let thickness: CGFloat

        @State private var isLoaded = false

        public init(to target: Binding<CGFloat>, color: Color = .white, thickness: CGFloat = 5) {
            self._target = target
            self.color = color
            self.thickness = thickness
        }

        public var body: some View {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: thickness))
                .foregroundStyle(.tertiary)
                .overlay {
                    // Foreground ring
                    if #available(macOS 13.0, *) {
                        Circle()
                            .trim(from: 0, to: isLoaded ? target : 0)
                            .stroke(
                                color.gradient, // Gradient is only available on macOS 13+
                                style: StrokeStyle(
                                    lineWidth: thickness,
                                    lineCap: .round
                                )
                            )
                            .opacity(isLoaded ? 1 : 0)
                    } else {
                        Circle()
                            .trim(from: 0, to: isLoaded ? target : 0)
                            .stroke(
                                color,
                                style: StrokeStyle(
                                    lineWidth: thickness,
                                    lineCap: .round
                                )
                            )
                            .opacity(isLoaded ? 1 : 0)
                    }
                }
                .rotationEffect(.degrees(-90))
                .padding(thickness / 2)
                .task {
                    withAnimation(Animation.timingCurve(0.22, 1, 0.36, 1, duration: 1)) {
                        isLoaded = true
                    }
                }
        }
    }
}
