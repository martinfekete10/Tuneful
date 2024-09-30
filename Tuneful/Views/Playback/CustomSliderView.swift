//
//  CustomSliderView.swift
//  Tuneful
//
//  Created by Martin Fekete on 18/08/2023.
//

import SwiftUI

struct CustomSliderView: View {
    
    @Environment(\.isEnabled) var isEnabled

    @Binding var value: CGFloat
    @Binding var isDragging: Bool
    
    @State var lastOffset: CGFloat = 0
    
    let range: ClosedRange<CGFloat>
    let knobDiameter: CGFloat
    let knobColor: Color
    let knobScaleEffectMagnitude: CGFloat
    let leadingRectangleColor: Color

    /// Called when the drag gesture ends.
    let onEndedDragging: ((DragGesture.Value) -> Void)?

    let sliderHeight: CGFloat = 5

    let knobAnimation: Animation?
    let knobTransition = AnyTransition.scale
    
    init(
        value: Binding<CGFloat>,
        isDragging: Binding<Bool>,
        range: ClosedRange<CGFloat>,
        knobDiameter: CGFloat,
        knobColor: Color,
        knobScaleEffectMagnitude: CGFloat = 1,
        knobAnimation: Animation? = nil,
        leadingRectangleColor: Color,
        onEndedDragging: ((DragGesture.Value) -> Void)? = nil
    ) {
        self._value = value
        self._isDragging = isDragging
        self.range = range
        self.knobDiameter = knobDiameter
        self.knobColor = knobColor
        self.knobScaleEffectMagnitude = knobScaleEffectMagnitude
        self.knobAnimation = knobAnimation
        self.leadingRectangleColor = leadingRectangleColor
        self.onEndedDragging = onEndedDragging
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    // MARK: Leading Rectangle
                    Capsule()
                        .fill(leadingRectangleColor)
                        .opacity(isEnabled ? 1 : 0.25)
                        .frame(
                            width: leadingRectangleWidth(geometry),
                            height: sliderHeight
                        )
                    // MARK: Trailing Rectangle
                    Capsule()
                        .fill(Color.primary.opacity(0.25))
                        .opacity(isEnabled ? 1 : 0.25)
                        .frame(height: sliderHeight)
                }
                HStack(spacing: 0) {
                    // MARK: Knob
                    Circle()
                        .fill(isEnabled ? knobColor : .gray)
                        .frame(width: knobDiameter)
                        .scaleEffect(isDragging ? knobScaleEffectMagnitude : 1)
                        .shadow(radius: 5)
                        .transition(knobTransition)
                        .offset(x: knobOffset(geometry))
                        .gesture(knobDragGesture(geometry))
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .gesture(knobPositionDragGesture(geometry))
        }
        .frame(height: knobDiameter + 2)
        .padding(.horizontal, 5)
    }
    
    func knobOffset(_ geometry: GeometryProxy) -> CGFloat {
        let maxKnobOffset = geometry.size.width - self.knobDiameter
        let result = max(0, self.value.map(from: self.range, to: 0...maxKnobOffset))
        return result
    }
    
    func leadingRectangleWidth(_ geometry: GeometryProxy) -> CGFloat {
        let result = max(0, knobOffset(geometry) + knobDiameter / 2)
        return result
    }
    
    func knobDragGesture(_ geometry: GeometryProxy) -> some Gesture {
        return DragGesture(minimumDistance: 0)
            .onChanged { dragValue in

                if let animation = self.knobAnimation {
                    withAnimation(animation) {
                        self.isDragging = true
                    }
                }
                else {
                    self.isDragging = true
                }
                
                if abs(dragValue.translation.width) < 0.1 {
                    self.lastOffset = knobOffset(geometry)
                }
                
                let knobOffsetMin: CGFloat = 0
                let knobOffsetMax = geometry.size.width - self.knobDiameter
                let knobOffsetRange = knobOffsetMin...knobOffsetMax
                let offset = self.lastOffset + dragValue.translation.width
                let knobOffset = offset.clamped(to: knobOffsetRange)
                self.value = knobOffset.map(
                    from: knobOffsetRange,
                    to: self.range
                )
            }
            .onEnded { dragValue in
                if let animation = self.knobAnimation {
                    withAnimation(animation) {
                        self.isDragging = false
                    }
                }
                else {
                    self.isDragging = false
                }
                self.onEndedDragging?(dragValue)
            }
    }
    
    func knobPositionDragGesture(_ geometry: GeometryProxy) -> some Gesture {
        return DragGesture(minimumDistance: 0)
            .onChanged { dragValue in
                
                if let animation = self.knobAnimation {
                    withAnimation(animation) {
                        self.isDragging = true
                    }
                }
                else {
                    self.isDragging = true
                }

                let knobOffsetMin = knobDiameter / 2
                let knobOffsetMax = geometry.size.width - knobDiameter / 2
                let knobOffsetRange = knobOffsetMin...knobOffsetMax
                let knobOffset = dragValue.location.x.clamped(
                    to: knobOffsetRange
                )
                self.value = knobOffset.map(
                    from: knobOffsetRange,
                    to: self.range
                )
            }
            .onEnded { dragValue in
                if let animation = self.knobAnimation {
                    withAnimation(animation) {
                        self.isDragging = false
                    }
                }
                else {
                    self.isDragging = false
                }
                self.onEndedDragging?(dragValue)
            }
    }
}
