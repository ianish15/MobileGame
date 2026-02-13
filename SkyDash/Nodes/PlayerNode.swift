import SpriteKit

class PlayerNode: SKNode {

    // MARK: - Properties
    private let body: SKShapeNode
    private let leftEye: SKShapeNode
    private let rightEye: SKShapeNode
    private let mouth: SKShapeNode
    private var shieldEffect: SKShapeNode?

    private(set) var jumpsRemaining: Int = GameConfig.maxJumps
    private(set) var isOnGround: Bool = true
    private(set) var isSliding: Bool = false
    private(set) var hasShield: Bool = false
    private(set) var hasMagnet: Bool = false
    private(set) var scoreMultiplier: Int = 1

    var skin: PlayerSkin = .orange {
        didSet { body.fillColor = skin.color }
    }

    private let bodySize: CGFloat = GameConfig.playerSize

    // MARK: - Init
    override init() {
        // Body - rounded square character
        body = SKShapeNode(rectOf: CGSize(width: bodySize, height: bodySize), cornerRadius: 10)
        body.fillColor = GameColors.player
        body.strokeColor = GameColors.playerDark
        body.lineWidth = 2

        // Eyes
        let eyeSize: CGFloat = 8
        leftEye = SKShapeNode(ellipseOf: CGSize(width: eyeSize, height: eyeSize + 2))
        leftEye.fillColor = .white
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -9, y: 8)

        rightEye = SKShapeNode(ellipseOf: CGSize(width: eyeSize, height: eyeSize + 2))
        rightEye.fillColor = .white
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 9, y: 8)

        // Pupils (added as children of eyes)
        let pupilSize: CGFloat = 4
        let leftPupil = SKShapeNode(circleOfRadius: pupilSize / 2)
        leftPupil.fillColor = .black
        leftPupil.strokeColor = .clear
        leftPupil.position = CGPoint(x: 2, y: 0)

        let rightPupil = SKShapeNode(circleOfRadius: pupilSize / 2)
        rightPupil.fillColor = .black
        rightPupil.strokeColor = .clear
        rightPupil.position = CGPoint(x: 2, y: 0)

        // Mouth - simple smile
        mouth = SKShapeNode()
        let mouthPath = CGMutablePath()
        mouthPath.move(to: CGPoint(x: -8, y: -8))
        mouthPath.addQuadCurve(to: CGPoint(x: 8, y: -8), control: CGPoint(x: 0, y: -16))
        mouth.path = mouthPath
        mouth.strokeColor = .white
        mouth.lineWidth = 2
        mouth.fillColor = .clear

        super.init()

        addChild(body)
        addChild(leftEye)
        leftEye.addChild(leftPupil)
        addChild(rightEye)
        rightEye.addChild(rightPupil)
        addChild(mouth)

        setupPhysics()
        startRunAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Physics
    private func setupPhysics() {
        let physicsSize = CGSize(width: bodySize - 4, height: bodySize - 4)
        physicsBody = SKPhysicsBody(rectangleOf: physicsSize)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0.2
        physicsBody?.restitution = 0.0
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.obstacle | PhysicsCategory.coin | PhysicsCategory.powerUp
        physicsBody?.collisionBitMask = PhysicsCategory.ground
    }

    // MARK: - Animations
    private func startRunAnimation() {
        // Squash and stretch running animation
        let squash = SKAction.scaleY(to: 0.9, duration: 0.15)
        let stretch = SKAction.scaleY(to: 1.05, duration: 0.15)
        let normal = SKAction.scaleY(to: 1.0, duration: 0.1)
        let runCycle = SKAction.sequence([squash, stretch, normal])
        body.run(SKAction.repeatForever(runCycle), withKey: "running")
    }

    private func stopRunAnimation() {
        body.removeAction(forKey: "running")
        body.yScale = 1.0
    }

    // MARK: - Actions
    func jump() {
        guard jumpsRemaining > 0 else { return }

        jumpsRemaining -= 1
        isOnGround = false
        isSliding = false
        restoreFromSlide()

        // Reset vertical velocity before applying impulse for consistent jump height
        physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: GameConfig.jumpImpulse))

        // Jump squash animation
        let squash = SKAction.scaleX(to: 0.85, duration: 0.05)
        let stretch = SKAction.group([
            SKAction.scaleX(to: 1.1, duration: 0.1),
            SKAction.scaleY(to: 1.15, duration: 0.1)
        ])
        let normal = SKAction.scale(to: 1.0, duration: 0.1)
        body.run(SKAction.sequence([squash, stretch, normal]))

        // Eyes go wide during jump
        let widen = SKAction.scaleY(to: 1.3, duration: 0.05)
        let normalEye = SKAction.scaleY(to: 1.0, duration: 0.2)
        leftEye.run(SKAction.sequence([widen, normalEye]))
        rightEye.run(SKAction.sequence([widen, normalEye]))
    }

    func slide() {
        guard isOnGround, !isSliding else { return }

        isSliding = true
        stopRunAnimation()

        // Flatten the player for sliding
        let slideAction = SKAction.group([
            SKAction.scaleY(to: 0.5, duration: 0.1),
            SKAction.scaleX(to: 1.3, duration: 0.1)
        ])
        body.run(slideAction)

        // Update physics body for sliding
        let slideSize = CGSize(width: bodySize * 1.3, height: bodySize * 0.5)
        physicsBody = SKPhysicsBody(rectangleOf: slideSize)
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = false
        physicsBody?.friction = 0.2
        physicsBody?.restitution = 0.0
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.obstacle | PhysicsCategory.coin | PhysicsCategory.powerUp
        physicsBody?.collisionBitMask = PhysicsCategory.ground

        // Auto-restore after a short time
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            SKAction.run { [weak self] in self?.restoreFromSlide() }
        ]), withKey: "slideRestore")
    }

    func restoreFromSlide() {
        guard isSliding else { return }
        removeAction(forKey: "slideRestore")
        isSliding = false

        let restore = SKAction.group([
            SKAction.scaleY(to: 1.0, duration: 0.1),
            SKAction.scaleX(to: 1.0, duration: 0.1)
        ])
        body.run(restore)

        // Restore physics body
        setupPhysics()
        startRunAnimation()
    }

    func landed() {
        isOnGround = true
        jumpsRemaining = GameConfig.maxJumps

        // Landing squash effect
        let squash = SKAction.scaleY(to: 0.85, duration: 0.05)
        let bounce = SKAction.scaleY(to: 1.05, duration: 0.08)
        let normal = SKAction.scaleY(to: 1.0, duration: 0.05)
        body.run(SKAction.sequence([squash, bounce, normal]))

        if !isSliding {
            startRunAnimation()
        }
    }

    func leftGround() {
        isOnGround = false
        stopRunAnimation()
    }

    // MARK: - Power-ups
    func activateShield(duration: TimeInterval = 5.0) {
        hasShield = true

        let shield = SKShapeNode(circleOfRadius: bodySize * 0.75)
        shield.fillColor = GameColors.shield.withAlphaComponent(0.2)
        shield.strokeColor = GameColors.shield
        shield.lineWidth = 2
        shield.glowWidth = 3
        shield.name = "shield"
        addChild(shield)
        shieldEffect = shield

        // Pulsing animation
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 0.95, duration: 0.5)
        ])
        shield.run(SKAction.repeatForever(pulse))

        // Warning flash before expiry
        run(SKAction.sequence([
            SKAction.wait(forDuration: duration - 1.5),
            SKAction.run { [weak shield] in
                let flash = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.3, duration: 0.15),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.15)
                ])
                shield?.run(SKAction.repeat(flash, count: 5))
            },
            SKAction.wait(forDuration: 1.5),
            SKAction.run { [weak self] in self?.deactivateShield() }
        ]), withKey: "shieldTimer")
    }

    func deactivateShield() {
        hasShield = false
        removeAction(forKey: "shieldTimer")
        shieldEffect?.removeFromParent()
        shieldEffect = nil
    }

    func useShieldHit() -> Bool {
        if hasShield {
            deactivateShield()

            // Flash effect when shield absorbs hit
            let flash = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 0.1),
                SKAction.fadeAlpha(to: 1.0, duration: 0.1)
            ])
            run(SKAction.repeat(flash, count: 3))
            return true
        }
        return false
    }

    func activateMagnet(duration: TimeInterval = 8.0) {
        hasMagnet = true

        // Visual indicator
        let indicator = SKShapeNode(circleOfRadius: bodySize * 1.5)
        indicator.fillColor = .clear
        indicator.strokeColor = GameColors.magnet.withAlphaComponent(0.3)
        indicator.lineWidth = 1
        indicator.name = "magnetField"
        addChild(indicator)

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.8),
            SKAction.scale(to: 0.8, duration: 0.8)
        ])
        indicator.run(SKAction.repeatForever(pulse))

        run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.run { [weak self] in
                self?.hasMagnet = false
                self?.childNode(withName: "magnetField")?.removeFromParent()
            }
        ]), withKey: "magnetTimer")
    }

    func activateMultiplier(duration: TimeInterval = 10.0) {
        scoreMultiplier = 2

        let label = SKLabelNode.styled(text: "x2", fontSize: 18, color: GameColors.multiplier, bold: true)
        label.position = CGPoint(x: 0, y: bodySize / 2 + 15)
        label.name = "multiplierLabel"
        addChild(label)

        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 3, duration: 0.3),
            SKAction.moveBy(x: 0, y: -3, duration: 0.3)
        ])
        label.run(SKAction.repeatForever(bounce))

        run(SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.run { [weak self] in
                self?.scoreMultiplier = 1
                self?.childNode(withName: "multiplierLabel")?.removeFromParent()
            }
        ]), withKey: "multiplierTimer")
    }

    // MARK: - Death
    func die() {
        physicsBody = nil
        removeAllActions()
        body.removeAllActions()
        stopRunAnimation()

        // Death animation - spin and fade
        let spinAndFly = SKAction.group([
            SKAction.rotate(byAngle: .pi * 4, duration: 0.8),
            SKAction.moveBy(x: -50, y: 200, duration: 0.5),
            SKAction.sequence([
                SKAction.wait(forDuration: 0.3),
                SKAction.fadeOut(withDuration: 0.5)
            ])
        ])
        run(spinAndFly)
    }

    // MARK: - Reset
    func reset() {
        removeAllActions()
        body.removeAllActions()
        alpha = 1.0
        zRotation = 0
        xScale = 1.0
        yScale = 1.0
        body.xScale = 1.0
        body.yScale = 1.0

        jumpsRemaining = GameConfig.maxJumps
        isOnGround = true
        isSliding = false
        hasShield = false
        hasMagnet = false
        scoreMultiplier = 1

        childNode(withName: "shield")?.removeFromParent()
        childNode(withName: "magnetField")?.removeFromParent()
        childNode(withName: "multiplierLabel")?.removeFromParent()
        shieldEffect = nil

        setupPhysics()
        startRunAnimation()
    }
}
