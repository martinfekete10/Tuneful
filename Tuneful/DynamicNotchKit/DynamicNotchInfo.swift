//
//  DynamicNotchInfoWindow.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-25.
//

import SwiftUI

internal final class DynamicNotchInfoPublisher: ObservableObject {
    @Published var icon: Image?
    @Published var iconColor: Color
    @Published var title: String
    @Published var description: String?

    init(icon: Image?, iconColor: Color, title: String, description: String? = nil) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.description = description
    }

    @MainActor
    func publish(icon: Image?, iconColor: Color, title: String, description: String?) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.description = description
    }
}

public class DynamicNotchInfo {
    private var internalDynamicNotch: DynamicNotch<InfoView>
    private let publisher: DynamicNotchInfoPublisher

    public init(contentID: UUID = .init(), icon: Image! = nil, title: String, description: String? = nil, iconColor: Color = .white, style: DynamicNotch<InfoView>.Style = .auto, onTap: @escaping () -> Void) {
        let publisher = DynamicNotchInfoPublisher(icon: icon, iconColor: iconColor, title: title, description: description)
        self.publisher = publisher
        internalDynamicNotch = DynamicNotch(contentID: contentID, style: style) {
            InfoView(publisher: publisher, onTap: onTap)
        }
    }

    @MainActor
    public func setContent(contentID: UUID = .init(), icon: Image? = nil, title: String, description: String? = nil, iconColor: Color = .white) {
        withAnimation {
            publisher.publish(icon: icon, iconColor: iconColor, title: title, description: description)
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

public extension DynamicNotchInfo {
    struct InfoView: View {
        @State private var isTapped: Bool = false
        
        private var publisher: DynamicNotchInfoPublisher
        private var onTap: () -> Void

        init(publisher: DynamicNotchInfoPublisher, onTap: @escaping () -> Void) {
            self.publisher = publisher
            self.onTap = onTap
        }
        
        public var body: some View {
            HStack(spacing: 10) {
                InfoImageView(publisher: publisher)
                InfoTextView(publisher: publisher)
                Spacer(minLength: 0)
            }
            .frame(height: 40)
            .tapAnimation {
                self.onTap()
            }
        }
    }

    struct InfoImageView: View {
        @ObservedObject private var publisher: DynamicNotchInfoPublisher

        init(publisher: DynamicNotchInfoPublisher) {
            self.publisher = publisher
        }

        public var body: some View {
            if let image = publisher.icon {
                image
                    .resizable()
                    .foregroundStyle(publisher.iconColor)
                    .padding(3)
                    .scaledToFit()
            } else {
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .padding(-5)
                    .scaledToFit()
            }
        }
    }

    struct InfoTextView: View {
        @ObservedObject private var publisher: DynamicNotchInfoPublisher

        init(publisher: DynamicNotchInfoPublisher) {
            self.publisher = publisher
        }

        public var body: some View {
            VStack(alignment: .leading, spacing: publisher.description != nil ? nil : 0) {
                Text(publisher.title)
                    .font(.headline)
                Text(publisher.description ?? "")
                    .foregroundStyle(.secondary)
                    .font(.caption2)
                    .opacity(publisher.description != nil ? 1 : 0)
                    .frame(maxHeight: publisher.description != nil ? nil : 0)
            }
        }
    }
}

struct DynamicNotchInfo_Previews: PreviewProvider {
    static let publisher = DynamicNotchInfoPublisher(icon: nil, iconColor: .blue, title: "testing")
    static var previews: some View {
        VStack {
            DynamicNotchInfo.InfoView(publisher: publisher, onTap: {})
        }
    }
}
