//
//  PlayerProtocol.swift
//  Tuneful
//
//  Created by Martin Fekete on 03/10/2024.
//

import Foundation
import Combine
import AppKit

protocol PlayerProtocol {
    var notificationSubject: PassthroughSubject<AlertItem, Never> { get set }
    
    var appName: String { get }
    var appPath: URL { get }
    var appNotification: String { get }
    var bundleId: String { get }
    var defaultAlbumArt: NSImage { get }
    
    var playerPosition: Double? { get }
    var isPlaying: Bool { get }
    var isRunning: Bool { get }
    var volume: CGFloat { get }
    var isLikeAuthorized: Bool { get }
    var shuffleIsOn: Bool { get }
    var shuffleContextEnabled: Bool { get }
    var repeatContextEnabled: Bool { get }
    var playbackSeekerEnabled: Bool { get }
    
    func refreshInfo(completion: @escaping () -> Void)
    
    func getTrackInfo() -> Track
    
    func getAlbumArt(completion: @escaping (FetchedAlbumArt) -> Void)
    
    func playPause() -> Void
    
    func previousTrack() -> Void
    
    func nextTrack() -> Void
    
    func toggleLoveTrack() -> Bool
    
    func setShuffle(shuffleIsOn: Bool) -> Bool
    
    func setRepeat(repeatIsOn: Bool) -> Bool
    
    func getCurrentSeekerPosition() -> Double
    
    func seekTrack(seekerPosition: CGFloat) -> Void
    
    func setVolume(volume: Int) -> Void
}

extension PlayerProtocol {
    func sendNotification(title: String, message: String) {
        let alertTitle = NSLocalizedString(
            title,
            comment: ""
        )
        let alert = AlertItem(
            title: alertTitle,
            message: message
        )
        self.notificationSubject.send(alert)
    }
}
