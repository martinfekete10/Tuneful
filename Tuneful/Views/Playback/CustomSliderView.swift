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
    @State var sliderHeight: CGFloat = 7
    
    let range: ClosedRange<CGFloat>
    let leadingRectangleColor: Color = .playbackPositionLeadingRectangle

    // Called when the drag gesture ends.
    let onEndedDragging: ((DragGesture.Value) -> Void)?
    
    init(
        value: Binding<CGFloat>,
        isDragging: Binding<Bool>,
        range: ClosedRange<CGFloat>,
        sliderHeight: CGFloat = 7,
        onEndedDragging: ((DragGesture.Value) -> Void)? = nil
    ) {
        self._value = value
        self._isDragging = isDragging
        self.range = range
        self.sliderHeight = sliderHeight
        self.onEndedDragging = onEndedDragging
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.primary.opacity(0.85))
                    .opacity(isEnabled ? 1 : 0.25)
                    .frame(height: sliderHeight)
                    .cornerRadius(5)
                    .mask(alignment: .leading) {
                        Rectangle()
                            .fill(leadingRectangleColor)
                            .frame(
                                width: leadingRectangleWidth(geometry),
                                height: sliderHeight
                            )
                    }
                
                Rectangle()
                    .fill(Color.primary.opacity(0.25))
                    .opacity(isEnabled ? 1 : 0.25)
                    .frame(height: sliderHeight)
                    .cornerRadius(5)
            }
            .contentShape(Rectangle())
            .gesture(knobPositionDragGesture(geometry))
        }
        .frame(height: sliderHeight)
        .onHover() { hovering in
            withAnimation(Animation.timingCurve(0.16, 1, 0.3, 1, duration: 0.7)) {
                if hovering {
                    sliderHeight += 3
                } else {
                    sliderHeight -= 3
                }
            }
        }
    }
    
    func knobOffset(_ geometry: GeometryProxy) -> CGFloat {
        let maxKnobOffset = geometry.size.width// - self.knobDiameter
        let result = max(0, self.value.map(from: self.range, to: 0...maxKnobOffset))
        return result
    }
    
    func leadingRectangleWidth(_ geometry: GeometryProxy) -> CGFloat {
        let result = max(0, knobOffset(geometry)/* + knobDiameter / 2*/)
        return result
    }
    
    func knobDragGesture(_ geometry: GeometryProxy) -> some Gesture {
        return DragGesture(minimumDistance: 0)
            .onChanged { dragValue in
                self.isDragging = true
                
                if abs(dragValue.translation.width) < 0.1 {
                    self.lastOffset = knobOffset(geometry)
                }
                
                let knobOffsetMin: CGFloat = 0
                let knobOffsetMax = geometry.size.width
                let knobOffsetRange = knobOffsetMin...knobOffsetMax
                let offset = self.lastOffset + dragValue.translation.width
                let knobOffset = offset.clamped(to: knobOffsetRange)
                
                self.value = knobOffset.map(
                    from: knobOffsetRange,
                    to: self.range
                )
            }
            .onEnded { dragValue in
                self.isDragging = false
                self.onEndedDragging?(dragValue)
            }
    }
    
    func knobPositionDragGesture(_ geometry: GeometryProxy) -> some Gesture {
        return DragGesture(minimumDistance: 0)
            .onChanged { dragValue in
                self.isDragging = true

                let knobOffsetMax = geometry.size.width
                let knobOffsetRange = 0...knobOffsetMax
                let knobOffset = dragValue.location.x.clamped(
                    to: knobOffsetRange
                )
                
                    self.value = knobOffset.map(
                        from: knobOffsetRange,
                        to: self.range
                    )
            }
            .onEnded { dragValue in
                self.isDragging = false
                self.onEndedDragging?(dragValue)
            }
    }
}
