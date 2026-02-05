import Foundation

#if canImport(AudioToolbox)
import AudioToolbox
public typealias SystemSoundID = AudioToolbox.SystemSoundID
#else
public typealias SystemSoundID = UInt32
#endif

@inline(__always)
func playSystemSound(_ soundId: SystemSoundID) {
    #if canImport(AudioToolbox)
    AudioServicesPlaySystemSound(soundId)
    #else
    _ = soundId
    #endif
}
