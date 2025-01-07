//
//  PlayerAppProvider.swift
//  Tuneful
//
//  Created by Martin Fekete on 15/10/2024.
//

import SwiftUI
import Combine
import Defaults

class PlayerAppProvider {
    private var notificationSubject: PassthroughSubject<AlertItem, Never>
    
    init(notificationSubject: PassthroughSubject<AlertItem, Never>) {
        self.notificationSubject = notificationSubject
    }
    
    func getPlayerApp() -> PlayerProtocol {
        switch Defaults[.connectedApp] {
        case .spotify:
            return SpotifyManager(notificationSubject: notificationSubject)
        case .appleMusic:
            return AppleMusicManager(notificationSubject: notificationSubject)
        }
    }
}
