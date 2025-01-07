//
//  LuminareValueAdjuster.swift
//
//
//  Created by Kai Azim on 2024-04-02.
//

import SwiftUI

public struct LuminareValueAdjuster<V>: View where V: Strideable, V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    public enum ControlSize {
        case regular
        case compact

        var height: CGFloat {
            switch self {
            case .regular: 70
            case .compact: 34
            }
        }
    }

    let horizontalPadding: CGFloat = 8

    let formatter: NumberFormatter
    var totalRange: V {
        sliderRange.upperBound - sliderRange.lowerBound
    }

    @State var isShowingTextBox = false

    // Focus
    enum FocusedField {
        case textbox
    }

    @FocusState var focusedField: FocusedField?

    let title: LocalizedStringKey
    let infoView: LuminareInfoView?
    @Binding var value: V
    let sliderRange: ClosedRange<V>
    let suffix: LocalizedStringKey?
    var step: V
    let upperClamp: Bool
    let lowerClamp: Bool
    let controlSize: LuminareValueAdjuster.ControlSize

    let decimalPlaces: Int
    @State var eventMonitor: AnyObject?

    // TODO: MAX DIGIT SPACING FOR LABEL
    public init(
        _ title: LocalizedStringKey,
        info: LuminareInfoView? = nil,
        value: Binding<V>,
        sliderRange: ClosedRange<V>,
        suffix: LocalizedStringKey? = nil,
        step: V? = nil,
        lowerClamp: Bool = false,
        upperClamp: Bool = false,
        controlSize: LuminareValueAdjuster.ControlSize = .regular,
        decimalPlaces: Int = 0
    ) {
        self.title = title
        self.infoView = info
        self._value = value
        self.sliderRange = sliderRange
        self.suffix = suffix
        self.lowerClamp = lowerClamp
        self.upperClamp = upperClamp
        self.controlSize = controlSize

        self.decimalPlaces = decimalPlaces

        self.formatter = NumberFormatter()
        formatter.maximumFractionDigits = 5

        if let step {
            self.step = step
        } else {
            self.step = 1
        }
    }

    public var body: some View {
        VStack {
            if controlSize == .regular {
                HStack {
                    titleView()

                    Spacer()

                    labelView()
                }

                sliderView()
            } else {
                HStack(spacing: 12) {
                    titleView()

                    Spacer(minLength: 0)

                    HStack(spacing: 12) {
                        sliderView()

                        labelView()
                    }
                    .frame(width: 270)
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .frame(height: controlSize.height)
        .animation(LuminareConstants.animation, value: value)
        .animation(LuminareConstants.animation, value: isShowingTextBox)
    }

    func titleView() -> some View {
        HStack(spacing: 0) {
            Text(title)

            if let infoView {
                infoView
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    func sliderView() -> some View {
        Slider(
            value: Binding(
                get: {
                    value
                },
                set: { newValue in
                    value = newValue
                    isShowingTextBox = false
                }
            ),
            in: sliderRange
        )
    }

    @ViewBuilder
    func labelView() -> some View {
        HStack {
            if isShowingTextBox {
                TextField(
                    "",
                    value: Binding(
                        get: {
                            value
                        },
                        set: {
                            if lowerClamp, upperClamp {
                                value = $0.clamped(to: sliderRange)
                            } else if lowerClamp {
                                value = max(sliderRange.lowerBound, $0)
                            } else if upperClamp {
                                value = min(sliderRange.upperBound, $0)
                            } else {
                                value = $0
                            }
                        }
                    ),
                    formatter: formatter
                )
                .onSubmit {
                    withAnimation(LuminareConstants.fastAnimation) {
                        isShowingTextBox.toggle()
                    }
                }
                .focused($focusedField, equals: .textbox)
                .multilineTextAlignment(.trailing)
                .labelsHidden()
                .textFieldStyle(.plain)
                .padding(.leading, -4)
            } else {
                Button {
                    withAnimation(LuminareConstants.fastAnimation) {
                        isShowingTextBox.toggle()
                        focusedField = .textbox
                    }
                } label: {
                    Text(String(format: "%.\(decimalPlaces)f", value as! CVarArg))
                        .contentTransition(.numericText())
                        .multilineTextAlignment(.trailing)
                }
                .buttonStyle(PlainButtonStyle())
            }

            if let suffix {
                Text(suffix)
                    .padding(.leading, -6)
            }
        }
        .frame(maxWidth: 150)
        .monospaced()
        .padding(4)
        .padding(.horizontal, 4)
        .background {
            ZStack {
                Capsule()
                    .strokeBorder(.quaternary, lineWidth: 1)

                if isShowingTextBox {
                    Capsule()
                        .foregroundStyle(.quinary)
                } else {
                    Capsule()
                        .foregroundStyle(.quinary.opacity(0.5))
                }
            }
        }
        .fixedSize()
        .clipShape(.capsule)
        .onChange(of: isShowingTextBox) { _ in
            if isShowingTextBox {
                addEventMonitor()
            } else {
                removeEventMonitor()
            }
        }
        .onDisappear {
            removeEventMonitor()
        }
    }

    func addEventMonitor() {
        if eventMonitor != nil {
            return
        }

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let downArrow: CGKeyCode = 0x7D
            let upArrow: CGKeyCode = 0x7E

            guard event.keyCode == downArrow || event.keyCode == upArrow else {
                return event
            }

            if event.keyCode == upArrow {
                value += step
            }

            if event.keyCode == downArrow {
                value -= step
            }

            if lowerClamp, upperClamp {
                value = value.clamped(to: sliderRange)
            } else if lowerClamp {
                value = max(sliderRange.lowerBound, value)
            } else if upperClamp {
                value = min(sliderRange.upperBound, value)
            } else {
                value = value
            }

            return nil
        } as? NSObject
    }

    func removeEventMonitor() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        eventMonitor = nil
    }
}

//private extension Comparable {
//    func clamped(to limits: ClosedRange<Self>) -> Self {
//        min(max(self, limits.lowerBound), limits.upperBound)
//    }
//}
