//
//  SystemPlayerManager.swift
//  Tuneful
//
//  Created by Martin Fekete on 06/10/2024.
//

import os
import Combine
import Foundation
import AppKit

class SystemPlayerManager: PlayerProtocol {
    let MRMediaRemoteGetNowPlayingInfo: @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    let MrMediaRemoteSendCommandFunction:@convention(c) (Int, AnyObject?) -> Void
    
    var notificationSubject: PassthroughSubject<AlertItem, Never>
    
    public var bundleId: String { "com.spotify.client" }
    public var appName: String { "Spotify" }
    public var appPath: URL = URL(fileURLWithPath: "/Applications/Spotify.app")
    public var appNotification: String { "" }
    public var defaultAlbumArt: NSImage
    
    public var playerPosition: Double? { 50 }
    public var isPlaying: Bool { getIsPlaying() }
    public var isRunning: Bool = true
    public var volume: CGFloat { 50 }
    public var isLikeAuthorized: Bool { false }
    public var shuffleIsOn: Bool { false }
    public var shuffleContextEnabled: Bool { false }
    public var repeatContextEnabled: Bool { false }
    public var playbackSeekerEnabled: Bool { false }
    
    private var info: [String: Any]?
    
    init(notificationSubject: PassthroughSubject<AlertItem, Never>) {
        let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))
        
        let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString)
        self.MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: (@convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void).self)
        
        let MRMediaRemoteSendCommandPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSendCommand" as CFString)
        typealias MRMediaRemoteSendCommandFunction = @convention(c) (Int, AnyObject?) -> Void
        self.MrMediaRemoteSendCommandFunction = unsafeBitCast(MRMediaRemoteSendCommandPointer, to: MRMediaRemoteSendCommandFunction.self)
        
        self.notificationSubject = notificationSubject
        self.defaultAlbumArt = NSImage()
    }
    
    func refreshInfo(completion: @escaping () -> Void) {
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main) { info in
            Logger.main.log("Refreshing system player info")
            self.info = info
            completion()
        }
    }
    
    func getTrackInfo() -> Track {
        let title = info?["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? ""
        let artist = info?["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? ""
        let album = info?["kMRMediaRemoteNowPlayingInfoAlbum"] as? String ?? ""
        let duration = info?["kMRMediaRemoteNowPlayingInfoDuration"] as? Double ?? 0.0

        return Track(title: title, artist: artist, album: album, duration: duration)
    }

    
    func getAlbumArt(completion: @escaping (FetchedAlbumArt) -> Void) {
        let defaultRestult = FetchedAlbumArt(image: defaultAlbumArt, isAlbumArt: false)
        
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main) { information in
            guard let artworkData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data else {
                completion(defaultRestult)
                return
            }
            
            if let image = NSImage(data: artworkData) {
                completion(FetchedAlbumArt(image: image, isAlbumArt: true))
            } else {
                completion(defaultRestult)
            }
        }
    }
    
    func playPause() {
        if self.isPlaying {
            MrMediaRemoteSendCommandFunction(2, nil)
        } else {
            MrMediaRemoteSendCommandFunction(0, nil)
        }
    }
    
    func previousTrack() {
        MrMediaRemoteSendCommandFunction(5, nil)
    }
    
    func nextTrack() {
        MrMediaRemoteSendCommandFunction(4, nil)
    }
    
    func toggleLoveTrack() -> Bool {
        return false // TODO
    }
    
    func setShuffle(shuffleIsOn: Bool) -> Bool {
        return false // TODO
    }
    
    func setRepeat(repeatIsOn: Bool) -> Bool {
        return false // TODO
    }
    
    func getCurrentSeekerPosition() -> Double {
        let playerPosition = info?["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double ?? 0.0
        return Double(playerPosition)
    }
    
    func seekTrack(seekerPosition: CGFloat) {
        return // TODO
    }
    
    func setVolume(volume: Int) {
        return // TODO
    }
    
    // MARK: Private methods
    
    private func getIsPlaying() -> Bool {
        let state = info?["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Int ?? 0
        print("Is playing: \(state)")
        return state != 0
    }
}
