import SpriteKit

// MARK: - Game Configuration
enum GameConfig {
    // Scene
    static let sceneWidth: CGFloat = 1334
    static let sceneHeight: CGFloat = 750

    // Ground
    static let groundHeight: CGFloat = 100

    // Player
    static let playerStartX: CGFloat = 250
    static let playerSize: CGFloat = 50
    static let jumpImpulse: CGFloat = 620
    static let gravity: CGFloat = -25
    static let maxJumps: Int = 2

    // Speed & Difficulty
    static let initialSpeed: CGFloat = 7.0
    static let maxSpeed: CGFloat = 16.0
    static let speedIncrement: CGFloat = 0.003

    // Spawning
    static let obstacleSpawnMin: TimeInterval = 1.4
    static let obstacleSpawnMax: TimeInterval = 2.8
    static let coinSpawnInterval: TimeInterval = 2.0
    static let powerUpSpawnChance: Double = 0.08
    static let gapChance: Double = 0.25

    // Scoring
    static let pointsPerFrame: Int = 1
    static let coinPoints: Int = 10
    static let coinCurrencyValue: Int = 1

    // Ads
    static let interstitialFrequency: Int = 3

    // Z Positions
    static let backgroundZ: CGFloat = -100
    static let cloudsZ: CGFloat = -50
    static let mountainsZ: CGFloat = -30
    static let groundZ: CGFloat = 0
    static let obstacleZ: CGFloat = 5
    static let coinZ: CGFloat = 5
    static let playerZ: CGFloat = 10
    static let particleZ: CGFloat = 15
    static let hudZ: CGFloat = 100
    static let overlayZ: CGFloat = 200
}

// MARK: - Colors
enum GameColors {
    static let skyTop = UIColor(red: 0.29, green: 0.56, blue: 0.85, alpha: 1.0)
    static let skyBottom = UIColor(red: 0.53, green: 0.81, blue: 0.92, alpha: 1.0)
    static let ground = UIColor(red: 0.30, green: 0.69, blue: 0.31, alpha: 1.0)
    static let groundDirt = UIColor(red: 0.47, green: 0.33, blue: 0.28, alpha: 1.0)
    static let player = UIColor(red: 1.0, green: 0.42, blue: 0.21, alpha: 1.0)
    static let playerDark = UIColor(red: 0.85, green: 0.35, blue: 0.15, alpha: 1.0)
    static let obstacle = UIColor(red: 0.90, green: 0.22, blue: 0.21, alpha: 1.0)
    static let obstacleDark = UIColor(red: 0.70, green: 0.15, blue: 0.15, alpha: 1.0)
    static let coin = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
    static let coinDark = UIColor(red: 0.90, green: 0.70, blue: 0.0, alpha: 1.0)
    static let powerUp = UIColor(red: 0.49, green: 0.30, blue: 1.0, alpha: 1.0)
    static let shield = UIColor(red: 0.0, green: 0.74, blue: 0.83, alpha: 1.0)
    static let magnet = UIColor(red: 0.96, green: 0.26, blue: 0.56, alpha: 1.0)
    static let multiplier = UIColor(red: 0.0, green: 0.90, blue: 0.46, alpha: 1.0)
    static let cloud = UIColor(white: 1.0, alpha: 0.85)
    static let mountain = UIColor(red: 0.55, green: 0.70, blue: 0.55, alpha: 0.6)
    static let title = UIColor(red: 1.0, green: 0.42, blue: 0.21, alpha: 1.0)
    static let uiBackground = UIColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 0.85)
    static let buttonPrimary = UIColor(red: 1.0, green: 0.42, blue: 0.21, alpha: 1.0)
    static let buttonSecondary = UIColor(red: 0.29, green: 0.56, blue: 0.85, alpha: 1.0)
    static let textPrimary = UIColor.white
    static let textSecondary = UIColor(white: 0.8, alpha: 1.0)
}

// MARK: - Storage Keys
enum StorageKeys {
    static let highScore = "sky_dash_high_score"
    static let totalCoins = "sky_dash_total_coins"
    static let adsRemoved = "sky_dash_ads_removed"
    static let gamesPlayed = "sky_dash_games_played"
    static let selectedSkin = "sky_dash_selected_skin"
    static let unlockedSkins = "sky_dash_unlocked_skins"
    static let musicEnabled = "sky_dash_music_enabled"
    static let soundEnabled = "sky_dash_sound_enabled"
}

// MARK: - IAP Product IDs
enum IAPProducts {
    static let removeAds = "com.skydash.game.removeads"
    static let coinPackSmall = "com.skydash.game.coins.500"
    static let coinPackMedium = "com.skydash.game.coins.1500"
    static let coinPackLarge = "com.skydash.game.coins.5000"

    static let allProductIDs: Set<String> = [
        removeAds, coinPackSmall, coinPackMedium, coinPackLarge
    ]
}

// MARK: - Player Skins
enum PlayerSkin: String, CaseIterable {
    case orange = "default_orange"
    case blue = "skin_blue"
    case green = "skin_green"
    case purple = "skin_purple"
    case gold = "skin_gold"
    case rainbow = "skin_rainbow"

    var color: UIColor {
        switch self {
        case .orange: return GameColors.player
        case .blue: return UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        case .green: return UIColor(red: 0.2, green: 0.85, blue: 0.4, alpha: 1.0)
        case .purple: return UIColor(red: 0.6, green: 0.3, blue: 0.9, alpha: 1.0)
        case .gold: return UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        case .rainbow: return UIColor(red: 1.0, green: 0.42, blue: 0.21, alpha: 1.0)
        }
    }

    var displayName: String {
        switch self {
        case .orange: return "Classic"
        case .blue: return "Ocean"
        case .green: return "Forest"
        case .purple: return "Mystic"
        case .gold: return "Golden"
        case .rainbow: return "Rainbow"
        }
    }

    var price: Int {
        switch self {
        case .orange: return 0
        case .blue: return 50
        case .green: return 50
        case .purple: return 100
        case .gold: return 200
        case .rainbow: return 500
        }
    }
}
