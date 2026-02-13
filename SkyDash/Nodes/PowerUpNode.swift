import SpriteKit

enum PowerUpType: CaseIterable {
    case shield
    case magnet
    case multiplier

    var color: UIColor {
        switch self {
        case .shield: return GameColors.shield
        case .magnet: return GameColors.magnet
        case .multiplier: return GameColors.multiplier
        }
    }

    var symbol: String {
        switch self {
        case .shield: return "S"
        case .magnet: return "M"
        case .multiplier: return "x2"
        }
    }
}

class PowerUpNode: SKNode {

    let type: PowerUpType
    private let size: CGFloat = 30

    init(type: PowerUpType) {
        self.type = type
        super.init()
        setupVisual()
        setupPhysics()
        startAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupVisual() {
        // Outer glow
        let glow = SKShapeNode(circleOfRadius: size / 2 + 4)
        glow.fillColor = type.color.withAlphaComponent(0.2)
        glow.strokeColor = .clear
        glow.name = "glow"
        addChild(glow)

        // Main circle
        let circle = SKShapeNode(circleOfRadius: size / 2)
        circle.fillColor = type.color
        circle.strokeColor = .white
        circle.lineWidth = 2
        addChild(circle)

        // Symbol
        let label = SKLabelNode(text: type.symbol)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = type == .multiplier ? 12 : 16
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        addChild(label)
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: size / 2)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }

    private func startAnimation() {
        // Float up and down
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 10, duration: 0.6),
            SKAction.moveBy(x: 0, y: -10, duration: 0.6)
        ])
        run(SKAction.repeatForever(float))

        // Pulsing glow
        if let glow = childNode(withName: "glow") {
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.3, duration: 0.5),
                SKAction.scale(to: 1.0, duration: 0.5)
            ])
            glow.run(SKAction.repeatForever(pulse))
        }
    }

    func collect() {
        physicsBody = nil
        removeAllActions()

        let burst = SKAction.group([
            SKAction.scale(to: 2.0, duration: 0.3),
            SKAction.fadeOut(withDuration: 0.3)
        ])
        run(SKAction.sequence([burst, SKAction.removeFromParent()]))
    }

    func move(speed: CGFloat) {
        position.x -= speed
    }

    var isOffScreen: Bool {
        return position.x < -50
    }
}
