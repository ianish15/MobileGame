import Foundation

struct PhysicsCategory {
    static let none:     UInt32 = 0
    static let player:   UInt32 = 1 << 0   // 1
    static let ground:   UInt32 = 1 << 1   // 2
    static let obstacle: UInt32 = 1 << 2   // 4
    static let coin:     UInt32 = 1 << 3   // 8
    static let powerUp:  UInt32 = 1 << 4   // 16
    static let boundary: UInt32 = 1 << 5   // 32
}
