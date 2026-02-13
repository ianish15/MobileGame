import SpriteKit

enum ObstacleType {
    case spike       // Jump over
    case barrier     // Slide under
    case doubleTall  // Tall spike, must time jump well
}

class ObstacleNode: SKNode {

    let type: ObstacleType

    init(type: ObstacleType) {
        self.type = type
        super.init()
        setupVisual()
        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupVisual() {
        switch type {
        case .spike:
            createSpike(height: 45, width: 35)
        case .barrier:
            createBarrier()
        case .doubleTall:
            createSpike(height: 70, width: 40)
        }
    }

    private func createSpike(height: CGFloat, width: CGFloat) {
        // Triangle spike
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: width / 2, y: 0))
        path.closeSubpath()

        let spike = SKShapeNode(path: path)
        spike.fillColor = GameColors.obstacle
        spike.strokeColor = GameColors.obstacleDark
        spike.lineWidth = 2
        spike.position = CGPoint(x: 0, y: -height / 2)
        addChild(spike)

        // Warning stripe detail
        let stripe = SKShapeNode(rectOf: CGSize(width: width * 0.4, height: 3))
        stripe.fillColor = GameColors.obstacleDark
        stripe.strokeColor = .clear
        stripe.position = CGPoint(x: 0, y: height * 0.3 - height / 2)
        addChild(stripe)
    }

    private func createBarrier() {
        let width: CGFloat = 50
        let height: CGFloat = 120
        let gapBottom: CGFloat = 55 // Gap starts here (player slides under)

        // Top part of barrier (the part to slide under)
        let topBar = SKShapeNode(rectOf: CGSize(width: width, height: height - gapBottom), cornerRadius: 4)
        topBar.fillColor = GameColors.obstacle
        topBar.strokeColor = GameColors.obstacleDark
        topBar.lineWidth = 2
        topBar.position = CGPoint(x: 0, y: gapBottom + (height - gapBottom) / 2 - height / 2)
        addChild(topBar)

        // Warning stripes on barrier
        for i in 0..<3 {
            let stripe = SKShapeNode(rectOf: CGSize(width: width - 8, height: 2))
            stripe.fillColor = .white.withAlphaComponent(0.3)
            stripe.strokeColor = .clear
            stripe.position = CGPoint(x: 0, y: topBar.position.y - 15 + CGFloat(i) * 12)
            addChild(stripe)
        }

        // Support pole
        let pole = SKShapeNode(rectOf: CGSize(width: 8, height: gapBottom))
        pole.fillColor = GameColors.obstacleDark
        pole.strokeColor = .clear
        pole.position = CGPoint(x: 0, y: -height / 2 + gapBottom / 2)
        addChild(pole)
    }

    private func setupPhysics() {
        var physicsSize: CGSize

        switch type {
        case .spike:
            physicsSize = CGSize(width: 25, height: 40)
            let body = SKPhysicsBody(rectangleOf: physicsSize, center: CGPoint(x: 0, y: -2))
            configurePhysicsBody(body)
        case .barrier:
            physicsSize = CGSize(width: 45, height: 60)
            let body = SKPhysicsBody(rectangleOf: physicsSize, center: CGPoint(x: 0, y: 25))
            configurePhysicsBody(body)
        case .doubleTall:
            physicsSize = CGSize(width: 30, height: 65)
            let body = SKPhysicsBody(rectangleOf: physicsSize, center: CGPoint(x: 0, y: 5))
            configurePhysicsBody(body)
        }
    }

    private func configurePhysicsBody(_ body: SKPhysicsBody) {
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.none
        physicsBody = body
    }

    func move(speed: CGFloat) {
        position.x -= speed
    }

    var isOffScreen: Bool {
        return position.x < -100
    }
}
