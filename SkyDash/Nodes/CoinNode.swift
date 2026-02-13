import SpriteKit

class CoinNode: SKNode {

    private let outerCircle: SKShapeNode
    private let innerStar: SKShapeNode
    private let coinSize: CGFloat = 22

    override init() {
        outerCircle = SKShapeNode(circleOfRadius: 11)
        outerCircle.fillColor = GameColors.coin
        outerCircle.strokeColor = GameColors.coinDark
        outerCircle.lineWidth = 2

        // Star shape inside coin
        innerStar = SKShapeNode()
        let starPath = CoinNode.createStarPath(points: 4, radius: 5, innerRadius: 2.5)
        innerStar.path = starPath
        innerStar.fillColor = .white.withAlphaComponent(0.6)
        innerStar.strokeColor = .clear

        super.init()

        addChild(outerCircle)
        addChild(innerStar)

        setupPhysics()
        startAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func createStarPath(points: Int, radius: CGFloat, innerRadius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let angleStep = .pi * 2 / CGFloat(points * 2)

        for i in 0..<(points * 2) {
            let r = i % 2 == 0 ? radius : innerRadius
            let angle = angleStep * CGFloat(i) - .pi / 2
            let point = CGPoint(x: cos(angle) * r, y: sin(angle) * r)
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: coinSize / 2)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = PhysicsCategory.coin
        physicsBody?.contactTestBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.none
    }

    private func startAnimation() {
        // Gentle bob up and down
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 6, duration: 0.5),
            SKAction.moveBy(x: 0, y: -6, duration: 0.5)
        ])
        run(SKAction.repeatForever(bob))

        // Spin the star
        let spin = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
        innerStar.run(SKAction.repeatForever(spin))

        // Subtle shimmer
        let shimmer = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.3),
            SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        ])
        outerCircle.run(SKAction.repeatForever(shimmer))
    }

    func collect() {
        physicsBody = nil
        removeAllActions()

        // Collection animation: scale up, fade out, float up
        let collectAnimation = SKAction.group([
            SKAction.scale(to: 1.8, duration: 0.25),
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.moveBy(x: 0, y: 30, duration: 0.25)
        ])

        run(SKAction.sequence([collectAnimation, SKAction.removeFromParent()]))
    }

    func move(speed: CGFloat) {
        position.x -= speed
    }

    var isOffScreen: Bool {
        return position.x < -50
    }

    func attractToward(point: CGPoint, strength: CGFloat = 0.15) {
        let dx = point.x - position.x
        let dy = point.y - position.y
        position.x += dx * strength
        position.y += dy * strength
    }
}
