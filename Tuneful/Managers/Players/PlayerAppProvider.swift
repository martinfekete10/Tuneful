//
//  PlayerAppProvider.swift
//  Tuneful
//
//  Created by Martin Fekete on 15/10/2024.
//

import SwiftUI
import Combine

class PlayerAppProvider {
    private var connectedApp: ConnectedApps
    private var spotify: SpotifyManager
    private var appleMusic: AppleMusicManager
    private var systemPlayer: SystemPlayerManager
    
    init(connectedApp: ConnectedApps, notificationSubject: PassthroughSubject<AlertItem, Never>) {
        self.connectedApp = connectedApp
        self.spotify = SpotifyManager(notificationSubject: notificationSubject)
        self.appleMusic = AppleMusicManager(notificationSubject: notificationSubject)
        self.systemPlayer = SystemPlayerManager(notificationSubject: notificationSubject)
    }
    
    func getPlayerApp() -> PlayerProtocol {
        let app = getPrefferedApp()
        if app.isRunning {
            return app
        }
        
        return systemPlayer
    }
    
    private func getPrefferedApp() -> PlayerProtocol {
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
