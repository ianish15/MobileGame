import Foundation

class ScoreManager {
    static let shared = ScoreManager()

    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - High Score
    var highScore: Int {
        return defaults.integer(forKey: StorageKeys.highScore)
    }

    /// Submit a new score. Returns true if it's a new high score.
    @discardableResult
    func submitScore(_ score: Int) -> Bool {
        if score > highScore {
            defaults.set(score, forKey: StorageKeys.highScore)
            return true
        }
        return false
    }

    // MARK: - Coins
    var totalCoins: Int {
        return defaults.integer(forKey: StorageKeys.totalCoins)
    }

    func addCoins(_ amount: Int) {
        let current = totalCoins
        defaults.set(current + amount, forKey: StorageKeys.totalCoins)
    }

    func spendCoins(_ amount: Int) {
        let current = totalCoins
        defaults.set(max(0, current - amount), forKey: StorageKeys.totalCoins)
    }

    // MARK: - Games Played
    var gamesPlayed: Int {
        return defaults.integer(forKey: StorageKeys.gamesPlayed)
    }

    func incrementGamesPlayed() {
        defaults.set(gamesPlayed + 1, forKey: StorageKeys.gamesPlayed)
    }

    // MARK: - Reset (for testing)
    func resetAll() {
        defaults.removeObject(forKey: StorageKeys.highScore)
        defaults.removeObject(forKey: StorageKeys.totalCoins)
        defaults.removeObject(forKey: StorageKeys.gamesPlayed)
        defaults.removeObject(forKey: StorageKeys.selectedSkin)
        defaults.removeObject(forKey: StorageKeys.unlockedSkins)
    }
}
