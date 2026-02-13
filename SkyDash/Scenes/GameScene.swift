import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Nodes
    private var worldNode: SKNode!
    private var background: ParallaxBackground!
    private var player: PlayerNode!
    private var hudNode: SKNode!

    // MARK: - HUD Labels
    private var scoreLabel: SKLabelNode!
    private var coinCountLabel: SKLabelNode!

    // MARK: - Game State
    private var gameSpeed: CGFloat = GameConfig.initialSpeed
    private var score: Int = 0
    private var coinsCollected: Int = 0
    private var isGameOver: Bool = false
    private var isGameStarted: Bool = false
    private var frameCount: Int = 0
    private var lastObstacleSpawnTime: TimeInterval = 0
    private var nextObstacleSpawnInterval: TimeInterval = GameConfig.obstacleSpawnMax
    private var lastCoinSpawnTime: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    private var touchStartLocation: CGPoint?

    // MARK: - Collections
    private var obstacles: [ObstacleNode] = []
    private var coins: [CoinNode] = []
    private var powerUps: [PowerUpNode] = []

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = GameColors.skyBottom
        physicsWorld.gravity = CGVector(dx: 0, dy: GameConfig.gravity)
        physicsWorld.contactDelegate = self

        setupWorld()
        setupBackground()
        setupPlayer()
        setupHUD()
        showGetReady()

        ScoreManager.shared.incrementGamesPlayed()
    }

    // MARK: - Setup
    private func setupWorld() {
        worldNode = SKNode()
        worldNode.name = "world"
        addChild(worldNode)
    }

    private func setupBackground() {
        background = ParallaxBackground(sceneSize: size)
        worldNode.addChild(background)
    }

    private func setupPlayer() {
        player = PlayerNode()
        player.position = CGPoint(x: GameConfig.playerStartX, y: GameConfig.groundHeight + GameConfig.playerSize / 2 + 5)
        player.zPosition = GameConfig.playerZ

        // Apply selected skin
        let skinRaw = UserDefaults.standard.string(forKey: StorageKeys.selectedSkin) ?? PlayerSkin.orange.rawValue
        if let skin = PlayerSkin(rawValue: skinRaw) {
            player.skin = skin
        }

        worldNode.addChild(player)
    }

    private func setupHUD() {
        hudNode = SKNode()
        hudNode.zPosition = GameConfig.hudZ
        addChild(hudNode)

        // Score label (top center)
        scoreLabel = SKLabelNode.styled(text: "0", fontSize: 32, color: .white, bold: true)
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 45)

        let scoreShadow = SKLabelNode.styled(text: "0", fontSize: 32, color: .black.withAlphaComponent(0.3), bold: true)
        scoreShadow.position = CGPoint(x: 2, y: -2)
        scoreShadow.zPosition = -1
        scoreLabel.addChild(scoreShadow)
        hudNode.addChild(scoreLabel)

        // Coin counter (top right)
        let coinIcon = SKShapeNode(circleOfRadius: 9)
        coinIcon.fillColor = GameColors.coin
        coinIcon.strokeColor = GameColors.coinDark
        coinIcon.lineWidth = 1.5
        coinIcon.position = CGPoint(x: size.width - 80, y: size.height - 45)
        hudNode.addChild(coinIcon)

        coinCountLabel = SKLabelNode.styled(text: "0", fontSize: 22, color: GameColors.coin, bold: true)
        coinCountLabel.horizontalAlignmentMode = .left
        coinCountLabel.position = CGPoint(x: size.width - 65, y: size.height - 45)
        hudNode.addChild(coinCountLabel)
    }

    private func showGetReady() {
        let readyLabel = SKLabelNode.styled(text: "TAP TO START", fontSize: 36, color: .white, bold: true)
        readyLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 40)
        readyLabel.zPosition = GameConfig.overlayZ
        readyLabel.name = "readyLabel"

        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.5),
            SKAction.fadeAlpha(to: 1.0, duration: 0.5)
        ])
        readyLabel.run(SKAction.repeatForever(pulse))
        addChild(readyLabel)
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchStartLocation = touch.location(in: self)

        if !isGameStarted {
            startGame()
            return
        }

        if isGameOver { return }

        // Default action: jump
        player.jump()
        AudioManager.shared.playJump()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let startLocation = touchStartLocation,
              isGameStarted && !isGameOver else { return }

        let currentLocation = touch.location(in: self)
        let dy = currentLocation.y - startLocation.y

        // Swipe down to slide
        if dy < -30 {
            player.slide()
            touchStartLocation = nil // Consume the gesture
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStartLocation = nil
    }

    // MARK: - Game Start
    private func startGame() {
        isGameStarted = true
        childNode(withName: "readyLabel")?.removeFromParent()
    }

    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        guard isGameStarted && !isGameOver else {
            lastUpdateTime = currentTime
            return
        }

        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Increase speed over time
        if gameSpeed < GameConfig.maxSpeed {
            gameSpeed += GameConfig.speedIncrement
        }

        // Update background scroll
        background.update(speed: gameSpeed)

        // Update score
        frameCount += 1
        if frameCount % 3 == 0 {
            score += GameConfig.pointsPerFrame * player.scoreMultiplier
            updateScoreLabel()
        }

        // Spawn obstacles
        if currentTime - lastObstacleSpawnTime > nextObstacleSpawnInterval {
            spawnObstacle()
            lastObstacleSpawnTime = currentTime
            // Randomize next spawn interval, decreasing as speed increases
            let speedFactor = Double((gameSpeed - GameConfig.initialSpeed) / (GameConfig.maxSpeed - GameConfig.initialSpeed))
            let minInterval = max(0.8, GameConfig.obstacleSpawnMin - speedFactor * 0.4)
            let maxInterval = max(1.2, GameConfig.obstacleSpawnMax - speedFactor * 0.8)
            nextObstacleSpawnInterval = TimeInterval.random(in: minInterval...maxInterval)
        }

        // Spawn coins
        if currentTime - lastCoinSpawnTime > GameConfig.coinSpawnInterval {
            spawnCoins()
            lastCoinSpawnTime = currentTime

            // Chance to spawn power-up
            if Double.random(in: 0...1) < GameConfig.powerUpSpawnChance {
                spawnPowerUp()
            }
        }

        // Move and cleanup obstacles
        for obstacle in obstacles {
            obstacle.move(speed: gameSpeed)
        }
        obstacles.removeAll { obstacle in
            if obstacle.isOffScreen {
                obstacle.removeFromParent()
                return true
            }
            return false
        }

        // Move and cleanup coins
        for coin in coins {
            if player.hasMagnet {
                let distance = hypot(player.position.x - coin.position.x, player.position.y - coin.position.y)
                if distance < 150 {
                    coin.attractToward(point: player.position, strength: 0.2)
                }
            }
            coin.move(speed: gameSpeed)
        }
        coins.removeAll { coin in
            if coin.isOffScreen {
                coin.removeFromParent()
                return true
            }
            return false
        }

        // Move and cleanup power-ups
        for powerUp in powerUps {
            powerUp.move(speed: gameSpeed)
        }
        powerUps.removeAll { powerUp in
            if powerUp.isOffScreen {
                powerUp.removeFromParent()
                return true
            }
            return false
        }

        // Keep player at fixed X (prevent drift)
        if abs(player.position.x - GameConfig.playerStartX) > 2 {
            player.position.x = GameConfig.playerStartX
        }

        // Failsafe: if player falls below ground
        if player.position.y < 0 {
            gameOver()
        }
    }

    // MARK: - Spawning
    private func spawnObstacle() {
        let difficulty = Double((gameSpeed - GameConfig.initialSpeed) / (GameConfig.maxSpeed - GameConfig.initialSpeed))

        let type: ObstacleType
        let rand = Double.random(in: 0...1)

        if difficulty > 0.5 && rand < 0.15 {
            type = .doubleTall
        } else if rand < 0.35 {
            type = .barrier
        } else {
            type = .spike
        }

        let obstacle = ObstacleNode(type: type)
        obstacle.position = CGPoint(
            x: size.width + 60,
            y: GameConfig.groundHeight + (type == .barrier ? 60 : 22)
        )
        obstacle.zPosition = GameConfig.obstacleZ
        worldNode.addChild(obstacle)
        obstacles.append(obstacle)
    }

    private func spawnCoins() {
        let coinCount = Int.random(in: 1...4)
        let startX = size.width + 80
        let baseY = GameConfig.groundHeight + 60

        // Different coin patterns
        let pattern = Int.random(in: 0...2)

        for i in 0..<coinCount {
            let coin = CoinNode()

            switch pattern {
            case 0: // Horizontal line
                coin.position = CGPoint(x: startX + CGFloat(i) * 35, y: baseY + 30)
            case 1: // Arc
                let arcHeight = sin(CGFloat(i) / CGFloat(coinCount) * .pi) * 80
                coin.position = CGPoint(x: startX + CGFloat(i) * 35, y: baseY + arcHeight)
            default: // Ascending
                coin.position = CGPoint(x: startX + CGFloat(i) * 35, y: baseY + CGFloat(i) * 30)
            }

            coin.zPosition = GameConfig.coinZ
            worldNode.addChild(coin)
            coins.append(coin)
        }
    }

    private func spawnPowerUp() {
        guard let type = PowerUpType.allCases.randomElement() else { return }

        let powerUp = PowerUpNode(type: type)
        powerUp.position = CGPoint(
            x: size.width + 200,
            y: CGFloat.random(min: GameConfig.groundHeight + 80, max: size.height * 0.6)
        )
        powerUp.zPosition = GameConfig.coinZ
        worldNode.addChild(powerUp)
        powerUps.append(powerUp)
    }

    // MARK: - HUD Updates
    private func updateScoreLabel() {
        scoreLabel.text = score.formattedWithCommas
        if let shadow = scoreLabel.children.first as? SKLabelNode {
            shadow.text = scoreLabel.text
        }
    }

    private func updateCoinLabel() {
        coinCountLabel.text = "\(coinsCollected)"
    }

    // MARK: - Score Popup
    private func showScorePopup(at position: CGPoint, text: String, color: UIColor) {
        let popup = SKLabelNode.styled(text: text, fontSize: 18, color: color, bold: true)
        popup.position = position
        popup.zPosition = GameConfig.particleZ
        worldNode.addChild(popup)

        let float = SKAction.group([
            SKAction.moveBy(x: 0, y: 40, duration: 0.6),
            SKAction.sequence([
                SKAction.fadeAlpha(to: 1.0, duration: 0.1),
                SKAction.wait(forDuration: 0.3),
                SKAction.fadeOut(withDuration: 0.2)
            ])
        ])
        popup.run(SKAction.sequence([float, SKAction.removeFromParent()]))
    }

    // MARK: - Particle Effects
    private func spawnCoinParticles(at position: CGPoint) {
        for _ in 0..<6 {
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = GameColors.coin
            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = GameConfig.particleZ
            worldNode.addChild(particle)

            let angle = CGFloat.random(in: 0...(.pi * 2))
            let distance = CGFloat.random(min: 20, max: 45)
            let dx = cos(angle) * distance
            let dy = sin(angle) * distance

            let move = SKAction.group([
                SKAction.moveBy(x: dx, y: dy, duration: 0.3),
                SKAction.fadeOut(withDuration: 0.3),
                SKAction.scale(to: 0.1, duration: 0.3)
            ])
            particle.run(SKAction.sequence([move, SKAction.removeFromParent()]))
        }
    }

    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == PhysicsCategory.player | PhysicsCategory.ground {
            player.landed()
            spawnDustParticles()
        }

        if collision == PhysicsCategory.player | PhysicsCategory.obstacle {
            if !player.useShieldHit() {
                gameOver()
            } else {
                AudioManager.shared.playShieldHit()
                // Remove the obstacle that was hit
                let obstacleBody = contact.bodyA.categoryBitMask == PhysicsCategory.obstacle ? contact.bodyA : contact.bodyB
                obstacleBody.node?.removeFromParent()
                if let index = obstacles.firstIndex(where: { $0 === obstacleBody.node }) {
                    obstacles.remove(at: index)
                }
            }
        }

        if collision == PhysicsCategory.player | PhysicsCategory.coin {
            let coinNode = contact.bodyA.categoryBitMask == PhysicsCategory.coin ? contact.bodyA.node : contact.bodyB.node
            if let coin = coinNode as? CoinNode {
                collectCoin(coin)
            }
        }

        if collision == PhysicsCategory.player | PhysicsCategory.powerUp {
            let powerUpNode = contact.bodyA.categoryBitMask == PhysicsCategory.powerUp ? contact.bodyA.node : contact.bodyB.node
            if let powerUp = powerUpNode as? PowerUpNode {
                collectPowerUp(powerUp)
            }
        }
    }

    // MARK: - Collection
    private func collectCoin(_ coin: CoinNode) {
        AudioManager.shared.playCoinCollect()
        coinsCollected += GameConfig.coinCurrencyValue
        score += GameConfig.coinPoints * player.scoreMultiplier
        updateScoreLabel()
        updateCoinLabel()

        spawnCoinParticles(at: coin.position)
        showScorePopup(at: CGPoint(x: coin.position.x, y: coin.position.y + 20),
                       text: "+\(GameConfig.coinPoints * player.scoreMultiplier)",
                       color: GameColors.coin)

        coin.collect()
        coins.removeAll { $0 === coin }
    }

    private func collectPowerUp(_ powerUp: PowerUpNode) {
        AudioManager.shared.playPowerUp()

        switch powerUp.type {
        case .shield:
            player.activateShield()
            showScorePopup(at: powerUp.position, text: "SHIELD!", color: GameColors.shield)
        case .magnet:
            player.activateMagnet()
            showScorePopup(at: powerUp.position, text: "MAGNET!", color: GameColors.magnet)
        case .multiplier:
            player.activateMultiplier()
            showScorePopup(at: powerUp.position, text: "x2 SCORE!", color: GameColors.multiplier)
        }

        powerUp.collect()
        powerUps.removeAll { $0 === powerUp }
    }

    // MARK: - Dust Particles
    private func spawnDustParticles() {
        guard player.position.y <= GameConfig.groundHeight + GameConfig.playerSize else { return }

        for _ in 0..<4 {
            let dust = SKShapeNode(circleOfRadius: CGFloat.random(min: 2, max: 4))
            dust.fillColor = GameColors.groundDirt.withAlphaComponent(0.5)
            dust.strokeColor = .clear
            dust.position = CGPoint(
                x: player.position.x + CGFloat.random(min: -15, max: 15),
                y: GameConfig.groundHeight + 5
            )
            dust.zPosition = GameConfig.particleZ
            worldNode.addChild(dust)

            let drift = SKAction.group([
                SKAction.moveBy(x: CGFloat.random(min: -20, max: -5), y: CGFloat.random(min: 5, max: 20), duration: 0.4),
                SKAction.fadeOut(withDuration: 0.4),
                SKAction.scale(to: 0.3, duration: 0.4)
            ])
            dust.run(SKAction.sequence([drift, SKAction.removeFromParent()]))
        }
    }

    // MARK: - Game Over
    private func gameOver() {
        guard !isGameOver else { return }
        isGameOver = true

        AudioManager.shared.playDeath()

        // Screen shake
        shakeCamera(duration: 0.4, intensity: 12)

        // Flash red overlay
        let flashOverlay = SKSpriteNode(color: .red.withAlphaComponent(0.3), size: size)
        flashOverlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flashOverlay.zPosition = GameConfig.overlayZ - 1
        addChild(flashOverlay)
        flashOverlay.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ]))

        // Player death animation
        player.die()

        // Stop spawning
        removeAllActions()

        // Save scores
        ScoreManager.shared.addCoins(coinsCollected)
        let isNewHighScore = ScoreManager.shared.submitScore(score)

        // Transition to game over scene
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.2),
            SKAction.run { [weak self] in
                self?.showGameOverScene(isNewHighScore: isNewHighScore)
            }
        ]))
    }

    private func showGameOverScene(isNewHighScore: Bool) {
        let gameOverScene = GameOverScene(size: size)
        gameOverScene.scaleMode = scaleMode
        gameOverScene.finalScore = score
        gameOverScene.coinsCollected = coinsCollected
        gameOverScene.isNewHighScore = isNewHighScore
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameOverScene, transition: transition)
    }
}
