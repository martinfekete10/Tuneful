//
//  PlaybackManager.swift
//  Tuneful
//
//  Created by Harsh Vardhan Goswami: https://github.com/TheBoredTeam/boring.notch
//  Modified by Martin Fekete
//


import SwiftUI
import AppKit
import Combine

class PlaybackManager: ObservableObject {
    @Published var isPlaying = false
    @Published var MrMediaRemoteSendCommandFunction:@convention(c) (Int, AnyObject?) -> Void
    
    init() {
        self.isPlaying = false;
        self.MrMediaRemoteSendCommandFunction = {_,_ in }
        handleLoadMediaHandlerApis()
    }
    
    private func handleLoadMediaHandlerApis(){
        guard let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework")) else { return }
        
        guard let MRMediaRemoteSendCommandPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSendCommand" as CFString) else { return }
        
        typealias MRMediaRemoteSendCommandFunction = @convention(c) (Int, AnyObject?) -> Void
        
        MrMediaRemoteSendCommandFunction = unsafeBitCast(MRMediaRemoteSendCommandPointer, to: MRMediaRemoteSendCommandFunction.self)
    }
    
    deinit {
        self.MrMediaRemoteSendCommandFunction = {_,_ in }
    }
    
    func playPause() -> Bool {
        if self.isPlaying {
            MrMediaRemoteSendCommandFunction(2, nil)
            self.isPlaying = false;
            return false;
        } else {
            MrMediaRemoteSendCommandFunction(0, nil)
            self.isPlaying = true
            return true;
        }
        
        
    }
    
    func nextTrack() {
        MrMediaRemoteSendCommandFunction(4, nil)
    }
    
    func previousTrack() {
        MrMediaRemoteSendCommandFunction(5, nil)
    }
}
