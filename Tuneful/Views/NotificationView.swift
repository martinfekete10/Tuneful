//
//  NotificationView.swift
//  Tuneful
//
//  Modified by Martin Fekete on 30/10/2023.
//  Created by Peter Schorn: https://github.com/Peter-Schorn/SoftPlayer
//

import Foundation
import SwiftUI

struct NotificationView: View {
    
    @EnvironmentObject var contentViewModel: ContentViewModel
    
    @State private var isPresented = false
    @State private var title = ""
    @State private var message = ""

    @State private var messageId = UUID()

    @State private var cancelButtonIsShowing = false

    let presentAnimation = Animation.spring(
        response: 0.5,
        dampingFraction: 0.9,
        blendDuration: 0
    )

    var body: some View {
        
        VStack {
            if isPresented {
                VStack {
                    Text(title)
                        .fontWeight(.bold)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 2)
                    if !message.isEmpty {
                        Text(message)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(7)
                .background(
                    VisualEffectView(
                        material: .popover,
                        blendingMode: .withinWindow
                    )
                )
                .cornerRadius(9)
                .padding(10)
                .shadow(radius: 5)
                .onHover { isHovering in
                    withAnimation(.easeOut(duration: 0.1)) {
                        self.cancelButtonIsShowing = isHovering
                    }
                }
                .transition(.move(edge: .top))
                
                Spacer()
            }
        }
        .padding(.top, 7)
        .onReceive(
            contentViewModel.notificationSubject,
            perform: recieveAlert(_:)
        )
        
    }
    
    func recieveAlert(_ alert: AlertItem) {
        let id = UUID()
        self.messageId = id

        self.title = alert.title
        self.message = alert.message

        withAnimation(self.presentAnimation) {
            self.isPresented = true
        }

        let delay: Double = message.isEmpty ? 2 : 3
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if self.messageId == id {
                withAnimation(self.presentAnimation) {
                    self.isPresented = false
                }
            }
        }
    }
}
