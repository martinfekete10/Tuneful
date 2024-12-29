//
//  LuminareInfoView.swift
//
//
//  Created by Kai Azim on 2024-06-02.
//

import SwiftUI

public struct LuminareInfoView: View {
    let color: Color
    let description: LocalizedStringKey
    @State var isShowingDescription: Bool = false
    @State var isHovering: Bool = false

    @State var hoverTimer: Timer?

    public init(_ description: LocalizedStringKey, _ color: Color = .blue) {
        self.color = color
        self.description = description
    }

    public var body: some View {
        VStack {
            Circle()
                .foregroundStyle(color)
                .frame(width: 4, height: 4)
                .padding(.leading, 4)
                .padding(12)
                .contentShape(.circle)
                .padding(-12)
                .onHover { hovering in
                    isHovering = hovering

                    if isHovering {
                        hoverTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
                            isShowingDescription = true
                        }
                    } else {
                        hoverTimer?.invalidate()
                        isShowingDescription = false
                    }
                }

                .popover(isPresented: $isShowingDescription, arrowEdge: .bottom) {
                    Text(description)
                        .multilineTextAlignment(.center)
                        .padding(8)
                }

            Spacer()
        }
    }
}
