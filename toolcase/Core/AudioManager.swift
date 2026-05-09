//
//  AudioManager.swift
//  Toolcase
//
//  Copyright © 2025 Neeraj Kumar. All rights reserved.
//

import Foundation
import Combine
import CoreAudio

/// Manages system microphone mute/unmute at the hardware level via CoreAudio.
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    @Published var isMuted: Bool = false
    
    init() {
        isMuted = fetchIsMicMuted()
    }
    
    /// Set the system default input device mute state.
    func setMicMuted(_ muted: Bool) {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        let deviceID = getDefaultInputDevice()
        guard deviceID != kAudioObjectUnknown else { return }
        
        var muteValue: UInt32 = muted ? 1 : 0
        AudioObjectSetPropertyData(deviceID, &address, 0, nil, UInt32(MemoryLayout<UInt32>.size), &muteValue)
        DispatchQueue.main.async {
            self.isMuted = muted
        }
    }
    
    /// Toggle the microphone state and return the new muted status.
    func toggleMic() -> Bool {
        let currentlyMuted = fetchIsMicMuted()
        setMicMuted(!currentlyMuted)
        return !currentlyMuted
    }
    
    // MARK: - Private
    
    private func fetchIsMicMuted() -> Bool {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeInput,
            mElement: kAudioObjectPropertyElementMain
        )
        let deviceID = getDefaultInputDevice()
        guard deviceID != kAudioObjectUnknown else { return false }
        
        var muted: UInt32 = 0
        var mutedSize = UInt32(MemoryLayout<UInt32>.size)
        let status = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &mutedSize, &muted)
        return status == noErr ? muted == 1 : false
    }
    
    private func getDefaultInputDevice() -> AudioDeviceID {
        var deviceID: AudioDeviceID = kAudioObjectUnknown
        var dataSize = UInt32(MemoryLayout<AudioDeviceID>.size)
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        AudioObjectGetPropertyData(UInt32(kAudioObjectSystemObject), &address, 0, nil, &dataSize, &deviceID)
        return deviceID
    }
}
