import SpriteKit

class StoreScene: SKScene {

    private var background: ParallaxBackground!
    private var selectedSkin: PlayerSkin = .orange
    private var coinLabel: SKLabelNode!
    private var previewNode: PlayerNode?
    private var skinsContainer: SKNode!

    override func didMove(to view: SKView) {
        backgroundColor = GameColors.skyBottom

        let skinRaw = UserDefaults.standard.string(forKey: StorageKeys.selectedSkin) ?? PlayerSkin.orange.rawValue
        selectedSkin = PlayerSkin(rawValue: skinRaw) ?? .orange

        setupBackground()
        setupOverlay()
        setupHeader()
        setupSkinStore()
        setupIAPSection()
        setupBackButton()
    }

    // MARK: - Setup
    private func setupBackground() {
        background = ParallaxBackground(sceneSize: size)
        addChild(background)
    }

    private func setupOverlay() {
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.3), size: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = GameConfig.hudZ - 1
        addChild(overlay)
    }

    private func setupHeader() {
        let title = SKLabelNode.styled(text: "STORE", fontSize: 42, color: .white, bold: true)
        title.position = CGPoint(x: size.width / 2, y: size.height - 50)
        title.zPosition = GameConfig.hudZ
        addChild(title)

        // Coin display
        let coinIcon = SKShapeNode(circleOfRadius: 12)
        coinIcon.fillColor = GameColors.coin
        coinIcon.strokeColor = GameColors.coinDark
        coinIcon.lineWidth = 2
        coinIcon.position = CGPoint(x: size.width - 120, y: size.height - 50)
        coinIcon.zPosition = GameConfig.hudZ
        addChild(coinIcon)

        coinLabel = SKLabelNode.styled(text: "\(ScoreManager.shared.totalCoins)", fontSize: 22, color: GameColors.coin, bold: true)
        coinLabel.horizontalAlignmentMode = .left
        coinLabel.position = CGPoint(x: size.width - 100, y: size.height - 50)
        coinLabel.zPosition = GameConfig.hudZ
        addChild(coinLabel)
    }

    private func setupSkinStore() {
        let sectionLabel = SKLabelNode.styled(text: "CHARACTER SKINS", fontSize: 18, color: GameColors.textSecondary)
        sectionLabel.position = CGPoint(x: size.width * 0.3, y: size.height - 100)
        sectionLabel.zPosition = GameConfig.hudZ
        addChild(sectionLabel)

        skinsContainer = SKNode()
        skinsContainer.zPosition = GameConfig.hudZ
        addChild(skinsContainer)

        let unlockedSkins = UserDefaults.standard.stringArray(forKey: StorageKeys.unlockedSkins) ?? [PlayerSkin.orange.rawValue]

        let skins = PlayerSkin.allCases
        let startX: CGFloat = 80
        let spacing: CGFloat = 100
        let y: CGFloat = size.height - 180

        for (index, skin) in skins.enumerated() {
            let x = startX + CGFloat(index) * spacing

            let isUnlocked = unlockedSkins.contains(skin.rawValue)
            let isSelected = skin == selectedSkin

            // Skin preview circle
            let circle = SKShapeNode(circleOfRadius: 25)
            circle.fillColor = skin.color
            circle.strokeColor = isSelected ? .white : (isUnlocked ? .white.withAlphaComponent(0.5) : .gray)
            circle.lineWidth = isSelected ? 3 : 1.5
            circle.position = CGPoint(x: x, y: y)
            circle.name = "skin_\(skin.rawValue)"
            skinsContainer.addChild(circle)

            // Face on the skin preview
            let leftEye = SKShapeNode(circleOfRadius: 3)
            leftEye.fillColor = .white
            leftEye.strokeColor = .clear
            leftEye.position = CGPoint(x: -7, y: 5)
            circle.addChild(leftEye)

            let rightEye = SKShapeNode(circleOfRadius: 3)
            rightEye.fillColor = .white
            rightEye.strokeColor = .clear
            rightEye.position = CGPoint(x: 7, y: 5)
            circle.addChild(rightEye)

            // Name label
            let nameLabel = SKLabelNode.styled(text: skin.displayName, fontSize: 12, color: .white)
            nameLabel.position = CGPoint(x: x, y: y - 40)
            skinsContainer.addChild(nameLabel)

            if !isUnlocked {
                // Lock overlay
                let lock = SKShapeNode(circleOfRadius: 25)
                lock.fillColor = UIColor.black.withAlphaComponent(0.5)
                lock.strokeColor = .gray
                lock.lineWidth = 1
                lock.position = CGPoint(x: x, y: y)
                lock.name = "lock_\(skin.rawValue)"
                skinsContainer.addChild(lock)

                // Price label
                let priceLabel = SKLabelNode.styled(text: "\(skin.price)", fontSize: 14, color: GameColors.coin, bold: true)
                priceLabel.position = CGPoint(x: x, y: y - 55)
                skinsContainer.addChild(priceLabel)

                let miniCoin = SKShapeNode(circleOfRadius: 6)
                miniCoin.fillColor = GameColors.coin
                miniCoin.strokeColor = .clear
                miniCoin.position = CGPoint(x: x + 20, y: y - 55)
                skinsContainer.addChild(miniCoin)
            } else if isSelected {
                let checkLabel = SKLabelNode.styled(text: "EQUIPPED", fontSize: 10, color: GameColors.multiplier, bold: true)
                checkLabel.position = CGPoint(x: x, y: y - 55)
                skinsContainer.addChild(checkLabel)
            }
        }
    }

    private func setupIAPSection() {
        let sectionLabel = SKLabelNode.styled(text: "SHOP", fontSize: 18, color: GameColors.textSecondary)
        sectionLabel.position = CGPoint(x: size.width * 0.3, y: size.height - 280)
        sectionLabel.zPosition = GameConfig.hudZ
        addChild(sectionLabel)

        // Remove Ads button
        if !AdManager.shared.adsRemoved {
            let removeAdsButton = ButtonNode(
                text: "Remove Ads - $2.99",
                size: CGSize(width: 220, height: 40),
                color: GameColors.buttonPrimary,
                fontSize: 18
            ) { [weak self] in
                self?.purchaseRemoveAds()
            }
            removeAdsButton.position = CGPoint(x: size.width * 0.3, y: size.height - 330)
            removeAdsButton.zPosition = GameConfig.hudZ
            addChild(removeAdsButton)
        } else {
            let purchased = SKLabelNode.styled(text: "Ads Removed", fontSize: 16, color: GameColors.multiplier)
            purchased.position = CGPoint(x: size.width * 0.3, y: size.height - 330)
            purchased.zPosition = GameConfig.hudZ
            addChild(purchased)
        }

        // Coin packs
        let packs: [(String, String, Int)] = [
            ("500 Coins - $0.99", IAPProducts.coinPackSmall, 500),
            ("1500 Coins - $2.99", IAPProducts.coinPackMedium, 1500),
            ("5000 Coins - $4.99", IAPProducts.coinPackLarge, 5000),
        ]

        for (index, pack) in packs.enumerated() {
            let button = ButtonNode(
                text: pack.0,
                size: CGSize(width: 220, height: 38),
                color: GameColors.buttonSecondary,
                fontSize: 16
            ) { [weak self] in
                self?.purchaseCoinPack(productID: pack.1, coins: pack.2)
            }
            button.position = CGPoint(
                x: size.width * 0.75,
                y: size.height - 280 - CGFloat(index) * 50
            )
            button.zPosition = GameConfig.hudZ
            addChild(button)
        }

        // Restore purchases
        let restoreButton = ButtonNode(
            text: "Restore Purchases",
            size: CGSize(width: 180, height: 35),
            color: UIColor.gray,
            fontSize: 14
        ) {
            IAPManager.shared.restorePurchases()
        }
        restoreButton.position = CGPoint(x: size.width * 0.75, y: size.height - 430)
        restoreButton.zPosition = GameConfig.hudZ
        addChild(restoreButton)
    }

    private func setupBackButton() {
        let backButton = ButtonNode(
            text: "BACK",
            size: CGSize(width: 100, height: 38),
            color: UIColor.gray.withAlphaComponent(0.8),
            fontSize: 18
        ) { [weak self] in
            self?.goBack()
        }
        backButton.position = CGPoint(x: 70, y: size.height - 50)
        backButton.zPosition = GameConfig.hudZ
        addChild(backButton)
    }

    // MARK: - Touch Handling for Skin Selection
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: skinsContainer)

        for skin in PlayerSkin.allCases {
            if let node = skinsContainer.childNode(withName: "skin_\(skin.rawValue)") {
                if node.contains(location) {
                    handleSkinTap(skin)
                    return
                }
            }
        }
    }

    private func handleSkinTap(_ skin: PlayerSkin) {
        let unlockedSkins = UserDefaults.standard.stringArray(forKey: StorageKeys.unlockedSkins) ?? [PlayerSkin.orange.rawValue]

        if unlockedSkins.contains(skin.rawValue) {
            // Select this skin
            selectedSkin = skin
            UserDefaults.standard.set(skin.rawValue, forKey: StorageKeys.selectedSkin)
            refreshSkins()
        } else {
            // Try to purchase with coins
            if ScoreManager.shared.totalCoins >= skin.price {
                ScoreManager.shared.spendCoins(skin.price)
                var skins = unlockedSkins
                skins.append(skin.rawValue)
                UserDefaults.standard.set(skins, forKey: StorageKeys.unlockedSkins)
                selectedSkin = skin
                UserDefaults.standard.set(skin.rawValue, forKey: StorageKeys.selectedSkin)
                refreshSkins()
                updateCoinDisplay()
            }
        }
    }

    private func refreshSkins() {
        skinsContainer.removeAllChildren()
        // Re-setup after removing all children so we rebuild
        let unlockedSkins = UserDefaults.standard.stringArray(forKey: StorageKeys.unlockedSkins) ?? [PlayerSkin.orange.rawValue]
        let skins = PlayerSkin.allCases
        let startX: CGFloat = 80
        let spacing: CGFloat = 100
        let y: CGFloat = size.height - 180

        for (index, skin) in skins.enumerated() {
            let x = startX + CGFloat(index) * spacing
            let isUnlocked = unlockedSkins.contains(skin.rawValue)
            let isSelected = skin == selectedSkin

            let circle = SKShapeNode(circleOfRadius: 25)
            circle.fillColor = skin.color
            circle.strokeColor = isSelected ? .white : (isUnlocked ? .white.withAlphaComponent(0.5) : .gray)
            circle.lineWidth = isSelected ? 3 : 1.5
            circle.position = CGPoint(x: x, y: y)
            circle.name = "skin_\(skin.rawValue)"
            skinsContainer.addChild(circle)

            let leftEye = SKShapeNode(circleOfRadius: 3)
            leftEye.fillColor = .white
            leftEye.strokeColor = .clear
            leftEye.position = CGPoint(x: -7, y: 5)
            circle.addChild(leftEye)

            let rightEye = SKShapeNode(circleOfRadius: 3)
            rightEye.fillColor = .white
            rightEye.strokeColor = .clear
            rightEye.position = CGPoint(x: 7, y: 5)
            circle.addChild(rightEye)

            let nameLabel = SKLabelNode.styled(text: skin.displayName, fontSize: 12, color: .white)
            nameLabel.position = CGPoint(x: x, y: y - 40)
            skinsContainer.addChild(nameLabel)

            if !isUnlocked {
                let lock = SKShapeNode(circleOfRadius: 25)
                lock.fillColor = UIColor.black.withAlphaComponent(0.5)
                lock.strokeColor = .gray
                lock.lineWidth = 1
                lock.position = CGPoint(x: x, y: y)
                lock.name = "lock_\(skin.rawValue)"
                skinsContainer.addChild(lock)

                let priceLabel = SKLabelNode.styled(text: "\(skin.price)", fontSize: 14, color: GameColors.coin, bold: true)
                priceLabel.position = CGPoint(x: x, y: y - 55)
                skinsContainer.addChild(priceLabel)
            } else if isSelected {
                let checkLabel = SKLabelNode.styled(text: "EQUIPPED", fontSize: 10, color: GameColors.multiplier, bold: true)
                checkLabel.position = CGPoint(x: x, y: y - 55)
                skinsContainer.addChild(checkLabel)
            }
        }
    }

    private func updateCoinDisplay() {
        coinLabel.text = "\(ScoreManager.shared.totalCoins)"
    }

    // MARK: - IAP Actions
    private func purchaseRemoveAds() {
        IAPManager.shared.purchase(productID: IAPProducts.removeAds) { [weak self] success in
            if success {
                AdManager.shared.adsRemoved = true
                // Reload scene to reflect changes
                let scene = StoreScene(size: self?.size ?? CGSize(width: GameConfig.sceneWidth, height: GameConfig.sceneHeight))
                scene.scaleMode = self?.scaleMode ?? .aspectFill
                self?.view?.presentScene(scene)
            }
        }
    }

    private func purchaseCoinPack(productID: String, coins: Int) {
        IAPManager.shared.purchase(productID: productID) { [weak self] success in
            if success {
                ScoreManager.shared.addCoins(coins)
                self?.updateCoinDisplay()
            }
        }
    }

    // MARK: - Navigation
    private func goBack() {
        let transition = SKTransition.push(with: .right, duration: 0.4)
        let menuScene = MenuScene(size: size)
        menuScene.scaleMode = scaleMode
        view?.presentScene(menuScene, transition: transition)
    }

    override func update(_ currentTime: TimeInterval) {
        background.update(speed: 0.5)
    }
}
