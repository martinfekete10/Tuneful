//
//  PlayerManagerMock.swift
//  Tuneful
//
//  Created by Martin Fekete on 14/12/2024.
//

import Combine
import Foundation

@MainActor
class PlayerManagerMock: PlayerManager {
    override var track: Track {
        get { return Track(artist: "Test", album: "Test") }
        set { }
    }
    
    override var musicApp: (any PlayerProtocol)? {
        get { return MusicAppMock(notificationSubject: PassthroughSubject<AlertItem, Never>()) }
        set { }
    }
}
