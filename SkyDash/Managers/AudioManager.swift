import AVFoundation
import SpriteKit

/// Audio Manager for game sound effects and music.
/// Uses system sounds as placeholders - replace with your own audio files.
///
/// To add custom sounds:
/// 1. Add .wav or .caf files to the project
/// 2. Update the file names in setupSounds()
/// 3. Audio files should be short (< 2 sec) for sound effects
class AudioManager {
    static let shared = AudioManager()

    private var soundEffects: [String: SKAction] = [:]
    private var backgroundMusicPlayer: AVAudioPlayer?

    var isMusicEnabled: Bool {
        get {
            let hasKey = UserDefaults.standard.object(forKey: StorageKeys.musicEnabled) != nil
            return hasKey ? UserDefaults.standard.bool(forKey: StorageKeys.musicEnabled) : true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StorageKeys.musicEnabled)
            if newValue {
                playBackgroundMusic()
            } else {
                stopBackgroundMusic()
            }
        }
    }

    var isSoundEnabled: Bool {
        get {
            let hasKey = UserDefaults.standard.object(forKey: StorageKeys.soundEnabled) != nil
            return hasKey ? UserDefaults.standard.bool(forKey: StorageKeys.soundEnabled) : true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: StorageKeys.soundEnabled)
        }
    }

    private init() {
        setupSounds()
        configureAudioSession()
    }

    // MARK: - Setup
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    private func setupSounds() {
        // These use placeholder system sounds. Replace with actual audio files:
        // soundEffects["jump"] = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
        // soundEffects["coin"] = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
        // soundEffects["death"] = SKAction.playSoundFileNamed("death.wav", waitForCompletion: false)
        // soundEffects["powerup"] = SKAction.playSoundFileNamed("powerup.wav", waitForCompletion: false)
        // soundEffects["shieldhit"] = SKAction.playSoundFileNamed("shieldhit.wav", waitForCompletion: false)
    }

    // MARK: - Sound Effects
    private func playSound(_ name: String, on scene: SKScene? = nil) {
        guard isSoundEnabled else { return }
        guard let action = soundEffects[name] else { return }

        if let scene = scene ?? currentScene {
            scene.run(action)
        }
    }

    func playJump() { playSound("jump") }
    func playCoinCollect() { playSound("coin") }
    func playDeath() { playSound("death") }
    func playPowerUp() { playSound("powerup") }
    func playShieldHit() { playSound("shieldhit") }

    // MARK: - Background Music
    func playBackgroundMusic() {
        guard isMusicEnabled else { return }

        // TODO: Replace with actual music file
        // guard let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else { return }
        // do {
        //     backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
        //     backgroundMusicPlayer?.numberOfLoops = -1 // Loop forever
        //     backgroundMusicPlayer?.volume = 0.3
        //     backgroundMusicPlayer?.play()
        // } catch {
        //     print("Failed to play background music: \(error)")
        // }
    }

    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }

    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }

    func resumeBackgroundMusic() {
        guard isMusicEnabled else { return }
        backgroundMusicPlayer?.play()
    }

    // MARK: - Helper
    private var currentScene: SKScene? {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first,
              let rootVC = window.rootViewController,
              let skView = rootVC.view as? SKView else {
            return nil
        }
        return skView.scene
    }
}
