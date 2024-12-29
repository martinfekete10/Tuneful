//
//  PopoverHolder.swift
//  Luminare
//
//  Created by Kai Azim on 2024-08-25.
//

import SwiftUI

public struct PopoverHolder<Content: View>: NSViewRepresentable {
    @Binding var isPresented: Bool
    @ViewBuilder var content: () -> Content

    public init(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self._isPresented = isPresented
        self.content = content
    }

    public func makeNSView(context _: Context) -> NSView {
        .init()
    }

    public func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.setVisible(isPresented, in: nsView)
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self, content: content)
    }

    @MainActor
    public class Coordinator: NSObject, NSWindowDelegate {
        private let parent: PopoverHolder
        private var content: () -> Content
        private var monitor: Any?
        private var originalYPoint: CGFloat?
        var popover: PopoverPanel?

        init(_ parent: PopoverHolder, content: @escaping () -> Content) {
            self.parent = parent
            self.content = content
            super.init()
        }

        // View is optional bevause it is not needed to close the popup
        func setVisible(_ isPresented: Bool, in view: NSView? = nil) {
            // If we're going to be closing the window
            guard isPresented else {
                popover?.resignKey()
                return
            }

            guard let view else { return }

            if popover == nil {
                initializePopup()
                guard let popover else { return }

                // Popover size
                let targetSize = NSSize(width: 300, height: 300)
                let extraPadding: CGFloat = 10

                // Get coordinates to place popopver
                guard let windowFrame = view.window?.frame else { return }
                let viewBounds = view.bounds
                var targetPoint = view.convert(viewBounds, to: nil).origin // Convert to window coordinates
                originalYPoint = targetPoint.y

                // Correct popover position
                targetPoint.y += windowFrame.minY
                targetPoint.x += windowFrame.minX
                targetPoint.y -= targetSize.height + extraPadding

                // Set position and show popover
                popover.setContentSize(targetSize)
                popover.setFrameOrigin(targetPoint)
                popover.makeKeyAndOrderFront(nil)

                if monitor == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        self?.monitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { [weak self] event in
                            if event.window != self?.popover {
                                self?.setVisible(false)
                            }
                            return event
                        }
                    }
                }
            }
        }

        public func windowWillClose(_: Notification) {
            Task {
                await MainActor.run {
                    removeMonitor()
                    parent.isPresented = false
                    self.popover = nil
                }
            }
        }

        func initializePopup() {
            self.popover = .init()
            guard let popover else { return }

            popover.delegate = self
            popover.contentViewController = NSHostingController(
                rootView: content()
                    .background(VisualEffectView(material: .popover, blendingMode: .behindWindow))
                    .overlay {
                        UnevenRoundedRectangle(
                            topLeadingRadius: PopoverPanel.cornerRadius + 2,
                            bottomLeadingRadius: PopoverPanel.cornerRadius + 2,
                            bottomTrailingRadius: PopoverPanel.cornerRadius + 2,
                            topTrailingRadius: PopoverPanel.cornerRadius + 2
                        )
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    }
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: PopoverPanel.cornerRadius,
                            bottomLeadingRadius: PopoverPanel.cornerRadius,
                            bottomTrailingRadius: PopoverPanel.cornerRadius,
                            topTrailingRadius: PopoverPanel.cornerRadius
                        )
                    )
                    .ignoresSafeArea()
                    .environmentObject(popover)
            )
        }

        func removeMonitor() {
            if monitor != nil {
                NSEvent.removeMonitor(monitor!)
                monitor = nil
            }
        }
    }
}
