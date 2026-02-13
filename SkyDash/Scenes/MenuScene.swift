import SpriteKit

class MenuScene: SKScene {

    private var background: ParallaxBackground!

    override func didMove(to view: SKView) {
        backgroundColor = GameColors.skyBottom

        setupBackground()
        setupTitle()
        setupButtons()
        setupHighScore()
        setupCoinsDisplay()
    }

    // MARK: - Setup
    private func setupBackground() {
        background = ParallaxBackground(sceneSize: size)
        addChild(background)
    }

    private func setupTitle() {
        // Game title
        let title = SKLabelNode.styled(text: "SKY DASH", fontSize: 64, color: GameColors.title, bold: true)
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        title.zPosition = GameConfig.hudZ

        // Add shadow
        let shadow = SKLabelNode.styled(text: "SKY DASH", fontSize: 64, color: .black.withAlphaComponent(0.3), bold: true)
        shadow.position = CGPoint(x: 3, y: -3)
        shadow.zPosition = -1
        title.addChild(shadow)

        addChild(title)

        // Bounce animation
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 8, duration: 0.8),
            SKAction.moveBy(x: 0, y: -8, duration: 0.8)
        ])
        title.run(SKAction.repeatForever(bounce))

        // Subtitle
        let subtitle = SKLabelNode.styled(text: "Tap to Jump  |  Swipe to Slide", fontSize: 18, color: GameColors.textSecondary)
        subtitle.position = CGPoint(x: size.width / 2, y: size.height * 0.60)
        subtitle.zPosition = GameConfig.hudZ
        addChild(subtitle)
    }

    private func setupButtons() {
        // Play button
        let playButton = ButtonNode(
            text: "PLAY",
            size: CGSize(width: 200, height: 55),
            color: GameColors.buttonPrimary,
            fontSize: 28
        ) { [weak self] in
            self?.startGame()
        }
        playButton.position = CGPoint(x: size.width / 2, y: size.height * 0.40)
        playButton.zPosition = GameConfig.hudZ
        addChild(playButton)

        // Store button
        let storeButton = ButtonNode(
            text: "STORE",
            size: CGSize(width: 160, height: 45),
            color: GameColors.buttonSecondary,
            fontSize: 22
        ) { [weak self] in
            self?.openStore()
        }
        storeButton.position = CGPoint(x: size.width / 2, y: size.height * 0.26)
        storeButton.zPosition = GameConfig.hudZ
        addChild(storeButton)
    }

    private func setupHighScore() {
        let highScore = ScoreManager.shared.highScore
        if highScore > 0 {
            let label = SKLabelNode.styled(
                text: "Best: \(highScore.formattedWithCommas)",
                fontSize: 20,
                color: GameColors.textSecondary
            )
            label.position = CGPoint(x: size.width / 2, y: size.height * 0.14)
            label.zPosition = GameConfig.hudZ
            addChild(label)
        }
    }

    private func setupCoinsDisplay() {
        let coins = ScoreManager.shared.totalCoins
        let coinLabel = SKLabelNode.styled(text: "\(coins.formattedWithCommas)", fontSize: 20, color: GameColors.coin, bold: true)
        coinLabel.horizontalAlignmentMode = .right
        coinLabel.position = CGPoint(x: size.width - 30, y: size.height - 40)
        coinLabel.zPosition = GameConfig.hudZ

        // Coin icon
        let coinIcon = SKShapeNode(circleOfRadius: 10)
        coinIcon.fillColor = GameColors.coin
        coinIcon.strokeColor = GameColors.coinDark
        coinIcon.lineWidth = 1.5
        coinIcon.position = CGPoint(x: 18, y: 0)
        coinLabel.addChild(coinIcon)

        addChild(coinLabel)
    }

    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        background.update(speed: 1.5) // Slow scroll on menu
    }

    // MARK: - Navigation
    private func startGame() {
        let transition = SKTransition.fade(withDuration: 0.5)
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        view?.presentScene(gameScene, transition: transition)
    }

    private func openStore() {
        let transition = SKTransition.push(with: .left, duration: 0.4)
        let storeScene = StoreScene(size: size)
        storeScene.scaleMode = scaleMode
        view?.presentScene(storeScene, transition: transition)
    }
}
