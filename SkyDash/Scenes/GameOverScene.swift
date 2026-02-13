import SpriteKit

class GameOverScene: SKScene {

    var finalScore: Int = 0
    var coinsCollected: Int = 0
    var isNewHighScore: Bool = false

    private var background: ParallaxBackground!

    override func didMove(to view: SKView) {
        backgroundColor = GameColors.skyBottom

        setupBackground()
        setupOverlay()
        setupScoreDisplay()
        setupButtons()
    }

    // MARK: - Setup
    private func setupBackground() {
        background = ParallaxBackground(sceneSize: size)
        addChild(background)
    }

    private func setupOverlay() {
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.4), size: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = GameConfig.hudZ - 1
        addChild(overlay)
    }

    private func setupScoreDisplay() {
        // Game Over title
        let title = SKLabelNode.styled(text: "GAME OVER", fontSize: 52, color: GameColors.title, bold: true)
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.78)
        title.zPosition = GameConfig.hudZ
        addChild(title)

        // New high score indicator
        if isNewHighScore {
            let newBest = SKLabelNode.styled(text: "NEW BEST!", fontSize: 24, color: GameColors.coin, bold: true)
            newBest.position = CGPoint(x: size.width / 2, y: size.height * 0.68)
            newBest.zPosition = GameConfig.hudZ
            addChild(newBest)

            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.15, duration: 0.4),
                SKAction.scale(to: 1.0, duration: 0.4)
            ])
            newBest.run(SKAction.repeatForever(pulse))
        }

        // Score panel background
        let panelSize = CGSize(width: 280, height: 120)
        let panel = SKShapeNode(rectOf: panelSize, cornerRadius: 16)
        panel.fillColor = GameColors.uiBackground
        panel.strokeColor = .white.withAlphaComponent(0.2)
        panel.lineWidth = 1
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.52)
        panel.zPosition = GameConfig.hudZ
        addChild(panel)

        // Score
        let scoreTitle = SKLabelNode.styled(text: "SCORE", fontSize: 16, color: GameColors.textSecondary)
        scoreTitle.position = CGPoint(x: -60, y: 25)
        panel.addChild(scoreTitle)

        let scoreValue = SKLabelNode.styled(text: finalScore.formattedWithCommas, fontSize: 32, color: .white, bold: true)
        scoreValue.position = CGPoint(x: -60, y: -10)
        panel.addChild(scoreValue)

        // Coins collected
        let coinTitle = SKLabelNode.styled(text: "COINS", fontSize: 16, color: GameColors.textSecondary)
        coinTitle.position = CGPoint(x: 70, y: 25)
        panel.addChild(coinTitle)

        let coinValue = SKLabelNode.styled(text: "\(coinsCollected)", fontSize: 32, color: GameColors.coin, bold: true)
        coinValue.position = CGPoint(x: 70, y: -10)
        panel.addChild(coinValue)

        // Best score
        let bestLabel = SKLabelNode.styled(
            text: "Best: \(ScoreManager.shared.highScore.formattedWithCommas)",
            fontSize: 16,
            color: GameColors.textSecondary
        )
        bestLabel.position = CGPoint(x: 0, y: -45)
        panel.addChild(bestLabel)
    }

    private func setupButtons() {
        // Play Again button
        let playAgainButton = ButtonNode(
            text: "PLAY AGAIN",
            size: CGSize(width: 200, height: 50),
            color: GameColors.buttonPrimary,
            fontSize: 24
        ) { [weak self] in
            self?.playAgain()
        }
        playAgainButton.position = CGPoint(x: size.width / 2, y: size.height * 0.28)
        playAgainButton.zPosition = GameConfig.hudZ
        addChild(playAgainButton)

        // Watch Ad to Continue button (only if ads not removed)
        if !AdManager.shared.adsRemoved {
            let adButton = ButtonNode(
                text: "WATCH AD +1 LIFE",
                size: CGSize(width: 220, height: 45),
                color: GameColors.multiplier,
                fontSize: 20
            ) { [weak self] in
                self?.watchAdToContinue()
            }
            adButton.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
            adButton.zPosition = GameConfig.hudZ
            addChild(adButton)
        }

        // Menu button
        let menuButton = ButtonNode(
            text: "MENU",
            size: CGSize(width: 140, height: 40),
            color: GameColors.buttonSecondary,
            fontSize: 20
        ) { [weak self] in
            self?.goToMenu()
        }
        menuButton.position = CGPoint(x: size.width / 2, y: size.height * 0.08)
        menuButton.zPosition = GameConfig.hudZ
        addChild(menuButton)
    }

    // MARK: - Update
    override func update(_ currentTime: TimeInterval) {
        background.update(speed: 0.5)
    }

    // MARK: - Actions
    private func playAgain() {
        // Show interstitial ad every N games
        if !AdManager.shared.adsRemoved && ScoreManager.shared.gamesPlayed % GameConfig.interstitialFrequency == 0 {
            AdManager.shared.showInterstitial { [weak self] in
                self?.transitionToGame()
            }
        } else {
            transitionToGame()
        }
    }

    private func transitionToGame() {
        let transition = SKTransition.fade(withDuration: 0.5)
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        view?.presentScene(gameScene, transition: transition)
    }

    private func watchAdToContinue() {
        AdManager.shared.showRewardedAd { [weak self] rewarded in
            if rewarded {
                // Give bonus coins as reward
                ScoreManager.shared.addCoins(5)
                self?.transitionToGame()
            }
        }
    }

    private func goToMenu() {
        let transition = SKTransition.fade(withDuration: 0.5)
        let menuScene = MenuScene(size: size)
        menuScene.scaleMode = scaleMode
        view?.presentScene(menuScene, transition: transition)
    }
}
