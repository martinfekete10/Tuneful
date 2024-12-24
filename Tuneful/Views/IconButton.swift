//
//  IconButton.swift
//  Tuneful
//
//  Created by Martin Fekete on 24/12/2024.
//

import SwiftUI
import Luminare

struct IconButton: View {
    var buttonText: String
    var url: String
    var image: ImageResource
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 5) {
                Image(image)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.secondary)
                    .frame(width: 16, height: 16)
                
                Text(buttonText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(LuminareCompactButtonStyle())
    }

}
