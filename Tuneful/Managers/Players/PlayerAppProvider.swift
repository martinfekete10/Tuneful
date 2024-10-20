//
//  PlayerAppProvider.swift
//  Tuneful
//
//  Created by Martin Fekete on 15/10/2024.
//

import SwiftUI
import Combine

class PlayerAppProvider {
    private var spotify: SpotifyManager
    private var appleMusic: AppleMusicManager
    private var systemPlayer: SystemPlayerManager
    
    init(notificationSubject: PassthroughSubject<AlertItem, Never>) {
        self.spotify = SpotifyManager(notificationSubject: notificationSubject)
        self.appleMusic = AppleMusicManager(notificationSubject: notificationSubject)
        self.systemPlayer = SystemPlayerManager(notificationSubject: notificationSubject)
    }
    
    func getPlayerApp(connectedApp: ConnectedApps) -> PlayerProtocol {
        switch connectedApp {
        case .spotify:
            return spotify
        case .appleMusic:
            return appleMusic
        case.system:
            return systemPlayer
        }
    }
}
