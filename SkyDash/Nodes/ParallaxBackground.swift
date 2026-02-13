import SpriteKit

class ParallaxBackground: SKNode {

    private var skyNode: SKSpriteNode!
    private var groundPairs: [(grass: SKShapeNode, dirt: SKShapeNode)] = []
    private var cloudNodes: [SKShapeNode] = []
    private var mountainNodes: [SKShapeNode] = []

    private let sceneSize: CGSize

    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        super.init()
        createSky()
        createMountains()
        createClouds()
        createGround()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Sky
    private func createSky() {
        let skyTexture = SKTexture(imageNamed: "")
        skyNode = SKSpriteNode(color: GameColors.skyBottom, size: sceneSize)
        skyNode.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        skyNode.zPosition = GameConfig.backgroundZ

        // Create gradient effect with multiple strips
        let stripCount = 10
        let stripHeight = sceneSize.height / CGFloat(stripCount)
        for i in 0..<stripCount {
            let fraction = CGFloat(i) / CGFloat(stripCount)
            let color = lerpColor(from: GameColors.skyBottom, to: GameColors.skyTop, fraction: fraction)
            let strip = SKSpriteNode(color: color, size: CGSize(width: sceneSize.width * 3, height: stripHeight + 1))
            strip.position = CGPoint(x: sceneSize.width / 2, y: CGFloat(i) * stripHeight + stripHeight / 2)
            strip.zPosition = GameConfig.backgroundZ
            addChild(strip)
        }
    }

    private func lerpColor(from: UIColor, to: UIColor, fraction: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        from.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        to.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let t = max(0, min(1, fraction))
        return UIColor(
            red: r1 + (r2 - r1) * t,
            green: g1 + (g2 - g1) * t,
            blue: b1 + (b2 - b1) * t,
            alpha: a1 + (a2 - a1) * t
        )
    }

    // MARK: - Mountains (distant background)
    private func createMountains() {
        for i in 0..<4 {
            let mountain = createMountainShape()
            mountain.position = CGPoint(
                x: CGFloat(i) * sceneSize.width * 0.5,
                y: GameConfig.groundHeight + 20
            )
            mountain.zPosition = GameConfig.mountainsZ
            addChild(mountain)
            mountainNodes.append(mountain)
        }
    }

    private func createMountainShape() -> SKShapeNode {
        let width = CGFloat.random(min: 200, max: 350)
        let height = CGFloat.random(min: 80, max: 160)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: -width / 2, y: 0))
        path.addLine(to: CGPoint(x: -width * 0.15, y: height * 0.85))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.75))
        path.addLine(to: CGPoint(x: width / 2, y: 0))
        path.closeSubpath()

        let mountain = SKShapeNode(path: path)
        mountain.fillColor = GameColors.mountain
        mountain.strokeColor = .clear
        return mountain
    }

    // MARK: - Clouds
    private func createClouds() {
        for _ in 0..<6 {
            let cloud = createCloudShape()
            cloud.position = CGPoint(
                x: CGFloat.random(min: -100, max: sceneSize.width + 100),
                y: CGFloat.random(min: sceneSize.height * 0.5, max: sceneSize.height * 0.9)
            )
            cloud.zPosition = GameConfig.cloudsZ
            cloud.alpha = CGFloat.random(min: 0.4, max: 0.8)
            let scale = CGFloat.random(min: 0.6, max: 1.2)
            cloud.setScale(scale)
            addChild(cloud)
            cloudNodes.append(cloud)
        }
    }

    private func createCloudShape() -> SKShapeNode {
        let cloud = SKShapeNode()
        let path = CGMutablePath()

        // Create a fluffy cloud from overlapping circles
        path.addEllipse(in: CGRect(x: -30, y: -10, width: 40, height: 25))
        path.addEllipse(in: CGRect(x: -10, y: 0, width: 45, height: 30))
        path.addEllipse(in: CGRect(x: 15, y: -8, width: 35, height: 22))
        path.addEllipse(in: CGRect(x: -20, y: -15, width: 50, height: 20))

        cloud.path = path
        cloud.fillColor = GameColors.cloud
        cloud.strokeColor = .clear
        return cloud
    }

    // MARK: - Ground
    private func createGround() {
        // Create two pairs of ground segments for seamless scrolling
        for i in 0..<2 {
            let xPos = CGFloat(i) * sceneSize.width

            // Dirt layer
            let dirt = SKShapeNode(rectOf: CGSize(width: sceneSize.width + 2, height: GameConfig.groundHeight))
            dirt.fillColor = GameColors.groundDirt
            dirt.strokeColor = .clear
            dirt.position = CGPoint(x: xPos + sceneSize.width / 2, y: GameConfig.groundHeight / 2)
            dirt.zPosition = GameConfig.groundZ

            // Grass layer on top
            let grassHeight: CGFloat = 15
            let grass = SKShapeNode(rectOf: CGSize(width: sceneSize.width + 2, height: grassHeight))
            grass.fillColor = GameColors.ground
            grass.strokeColor = .clear
            grass.position = CGPoint(x: xPos + sceneSize.width / 2, y: GameConfig.groundHeight - grassHeight / 2)
            grass.zPosition = GameConfig.groundZ + 0.1

            // Add grass tufts
            let tuftCount = 20
            for j in 0..<tuftCount {
                let tuft = SKShapeNode()
                let tuftPath = CGMutablePath()
                let tuftX = -sceneSize.width / 2 + CGFloat(j) * (sceneSize.width / CGFloat(tuftCount)) + CGFloat.random(min: -10, max: 10)
                tuftPath.move(to: CGPoint(x: tuftX - 3, y: grassHeight / 2))
                tuftPath.addLine(to: CGPoint(x: tuftX, y: grassHeight / 2 + CGFloat.random(min: 5, max: 12)))
                tuftPath.addLine(to: CGPoint(x: tuftX + 3, y: grassHeight / 2))
                tuft.path = tuftPath
                tuft.fillColor = UIColor(red: 0.25, green: 0.75, blue: 0.25, alpha: 1.0)
                tuft.strokeColor = .clear
                grass.addChild(tuft)
            }

            addChild(dirt)
            addChild(grass)
            groundPairs.append((grass: grass, dirt: dirt))
        }

        // Physics body for ground (static)
        let groundBody = SKNode()
        groundBody.position = CGPoint(x: sceneSize.width / 2, y: GameConfig.groundHeight)
        groundBody.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sceneSize.width * 3, height: 2))
        groundBody.physicsBody?.isDynamic = false
        groundBody.physicsBody?.categoryBitMask = PhysicsCategory.ground
        groundBody.physicsBody?.contactTestBitMask = PhysicsCategory.player
        groundBody.physicsBody?.collisionBitMask = PhysicsCategory.player
        groundBody.physicsBody?.friction = 0.5
        addChild(groundBody)
    }

    // MARK: - Update (scrolling)
    func update(speed: CGFloat) {
        // Scroll ground at full speed
        for pair in groundPairs {
            pair.grass.position.x -= speed
            pair.dirt.position.x -= speed

            if pair.grass.position.x <= -sceneSize.width / 2 {
                pair.grass.position.x += sceneSize.width * 2
                pair.dirt.position.x += sceneSize.width * 2
            }
        }

        // Scroll mountains at slower speed (parallax)
        for mountain in mountainNodes {
            mountain.position.x -= speed * 0.2
            if mountain.position.x < -sceneSize.width * 0.5 {
                mountain.position.x += sceneSize.width * 2.0
            }
        }

        // Scroll clouds at slowest speed
        for cloud in cloudNodes {
            cloud.position.x -= speed * 0.1
            if cloud.position.x < -100 {
                cloud.position.x = sceneSize.width + 100
                cloud.position.y = CGFloat.random(min: sceneSize.height * 0.5, max: sceneSize.height * 0.9)
            }
        }
    }
}
