//
//  ScreenView.swift
//  Luminare Tester
//
//  Created by Kai Azim on 2024-04-14.
//

import SwiftUI

public struct ScreenView<Content>: View where Content: View {
    @Binding var blurred: Bool
    let screenContent: () -> Content
    @State private var image: NSImage?

    private let screenShape = UnevenRoundedRectangle(
        topLeadingRadius: 12,
        bottomLeadingRadius: 0,
        bottomTrailingRadius: 0,
        topTrailingRadius: 12
    )

    public init(blurred: Binding<Bool> = .constant(false), @ViewBuilder _ screenContent: @escaping () -> Content) {
        self._blurred = blurred
        self.screenContent = screenContent
    }

    public var body: some View {
        ZStack {
            GeometryReader { geo in
                if let image {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .blur(radius: blurred ? 10 : 0)
                        .opacity(blurred ? 0.5 : 1)
                } else {
                    LuminareConstants.tint()
                        .opacity(0.1)
                }
            }
            .allowsHitTesting(false)
            .onAppear {
                DispatchQueue.main.async {
                    Task {
                        await updateImage()
                    }
                }
            }
            .overlay {
                screenContent()
                    .padding(5)
            }
            .clipShape(screenShape)

            screenShape
                .stroke(.gray, lineWidth: 2)

            screenShape
                .inset(by: 2.5)
                .stroke(.black, lineWidth: 5)

            screenShape
                .inset(by: 3)
                .stroke(.gray.opacity(0.2), lineWidth: 1)
        }
        .aspectRatio(16 / 10, contentMode: .fill)
    }

    func updateImage() async {
        guard
            let screen = NSScreen.main,
            let url = NSWorkspace.shared.desktopImageURL(for: screen),
            image == nil || image!.isValid == false
        else {
            return
        }

        if let newImage = NSImage.resize(url, width: 300) {
            await withAnimation(LuminareConstants.fastAnimation) {
                image = newImage
            }
        }
    }
}

extension NSImage {
    static func resize(_ url: URL, width: CGFloat) -> NSImage? {
        guard let inputImage = NSImage(contentsOf: url) else { return nil }
        let aspectRatio = inputImage.size.width / inputImage.size.height
        let thumbSize = NSSize(
            width: width,
            height: width / aspectRatio
        )

        let outputImage = NSImage(size: thumbSize)
        outputImage.lockFocus()
        inputImage.draw(
            in: NSRect(origin: .zero, size: thumbSize),
            from: .zero,
            operation: .sourceOver,
            fraction: 1
        )
        outputImage.unlockFocus()

        return outputImage
    }
}
