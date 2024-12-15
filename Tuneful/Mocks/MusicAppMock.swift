//
//  MusicAppMock.swift
//  Tuneful
//
//  Created by Martin Fekete on 14/12/2024.
//

import Combine

class MusicAppMock: AppleMusicManager {
    override var isPlaying: Bool {
        get { return true }
    }
    
    override func isRunning() -> Bool {
        return true
    }
}
