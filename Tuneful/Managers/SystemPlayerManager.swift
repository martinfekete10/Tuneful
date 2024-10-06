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
    
    public var playerPosition: Double? { 50 }
    public var isPlaying: Bool { true }
    public var isRunning: Bool { true }
    public var duration: CGFloat { 50 }
    public var volume: CGFloat { 50 }
    public var isLikeAuthorized: Bool { false }
    public var shuffleIsOn: Bool { false }
    public var shuffleContextEnabled: Bool { false }
    public var repeatContextEnabled: Bool { false }
    
    init(notificationSubject: PassthroughSubject<AlertItem, Never>) {
        let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))
        
        let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString)
        self.MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: (@convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void).self)
        
        let MRMediaRemoteSendCommandPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSendCommand" as CFString)
        typealias MRMediaRemoteSendCommandFunction = @convention(c) (Int, AnyObject?) -> Void
        self.MrMediaRemoteSendCommandFunction = unsafeBitCast(MRMediaRemoteSendCommandPointer, to: MRMediaRemoteSendCommandFunction.self)
        
        self.notificationSubject = notificationSubject
    }
    
    
    func getTrackInfoAsync(completion: @escaping (Track?) -> Void) {
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main) { info in
            let title = info["kMRMediaRemoteNowPlayingInfoTitle"] as? String ?? ""
            let artist = info["kMRMediaRemoteNowPlayingInfoArtist"] as? String ?? ""
            let album = info["kMRMediaRemoteNowPlayingInfoAlbum"] as? String ?? ""
//            let state = info["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Int

            let track = Track(title: title, artist: artist, album: album)
            completion(track)
        }
    }
    
    func getTrackInfo() -> Track {
        return Track()
    }

    
    func getAlbumArt(completion: @escaping (NSImage?) -> Void) {
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main) { information in
            guard let artworkData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data else {
                completion(nil)
                return
            }
            
            if let artwork = NSImage(data: artworkData) {
                completion(artwork)
            } else {
                completion(nil)
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
        fatalError("Not implemented")
    }
    
    func setShuffle(shuffleIsOn: Bool) -> Bool {
        fatalError("Not implemented")
    }
    
    func setRepeat(repeatIsOn: Bool) -> Bool {
        fatalError("Not implemented")
    }
    
    func getCurrentSeekerPosition() -> Double {
        return 50
    }
    
    func seekTrack(seekerPosition: CGFloat) {
        fatalError("Not implemented")
    }
    
    func setVolume(volume: Int) {
        fatalError("Not implemented")
    }
    
}
