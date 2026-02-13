import Foundation

enum GameState {
    case menu
    case playing
    case paused
    case gameOver
}

class GameManager {
    static let shared = GameManager()

    private(set) var state: GameState = .menu

    private init() {}

    func setState(_ newState: GameState) {
        state = newState
    }
}
