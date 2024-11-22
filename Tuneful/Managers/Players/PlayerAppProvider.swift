//
//  PlayerAppProvider.swift
//  Tuneful
//
//  Created by Martin Fekete on 15/10/2024.
//

import SwiftUI
import Combine

class PlayerAppProvider {
    private var notificationSubject: PassthroughSubject<AlertItem, Never>
    
    init(notificationSubject: PassthroughSubject<AlertItem, Never>) {
        self.notificationSubject = notificationSubject
    }
    
    func getPlayerApp(connectedApp: ConnectedApps) -> PlayerProtocol {
        // TODO: System player
        switch connectedApp {
        case .spotify:
            return SpotifyManager(notificationSubject: notificationSubject)
        case .appleMusic:
            return AppleMusicManager(notificationSubject: notificationSubject)
//        case.system:
//            return systemPlayer
        }
    }
}
