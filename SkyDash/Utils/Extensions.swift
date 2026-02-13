import SpriteKit

// MARK: - CGFloat Random
extension CGFloat {
    static func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random(in: min...max)
    }
}

// MARK: - SKNode Helpers
extension SKNode {
    func runAfter(_ duration: TimeInterval, action: SKAction) {
        run(SKAction.sequence([SKAction.wait(forDuration: duration), action]))
    }
}

// MARK: - SKScene Helpers
extension SKScene {
    func shakeCamera(duration: TimeInterval = 0.3, intensity: CGFloat = 8) {
        let shakeAction = SKAction.customAction(withDuration: duration) { node, elapsed in
            let fraction = elapsed / CGFloat(duration)
            let dampening = 1.0 - fraction
            let dx = CGFloat.random(in: -intensity...intensity) * dampening
            let dy = CGFloat.random(in: -intensity...intensity) * dampening
            node.position = CGPoint(x: dx, y: dy)
        }
        let resetAction = SKAction.move(to: .zero, duration: 0.05)
        let worldNode = childNode(withName: "world") ?? self
        worldNode.run(SKAction.sequence([shakeAction, resetAction]))
    }
}

// MARK: - SKShapeNode Rounded Rectangle Helper
extension SKShapeNode {
    static func roundedRect(size: CGSize, cornerRadius: CGFloat, color: UIColor) -> SKShapeNode {
        let shape = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        shape.fillColor = color
        shape.strokeColor = .clear
        return shape
    }
}

// MARK: - SKLabelNode Helpers
extension SKLabelNode {
    static func styled(
        text: String,
        fontSize: CGFloat,
        color: UIColor = GameColors.textPrimary,
        bold: Bool = false
    ) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = bold ? "AvenirNext-Bold" : "AvenirNext-Medium"
        label.fontSize = fontSize
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        return label
    }
}

// MARK: - Button Node
class ButtonNode: SKNode {
    private let background: SKShapeNode
    private let label: SKLabelNode
    let action: () -> Void

    init(text: String, size: CGSize, color: UIColor = GameColors.buttonPrimary, fontSize: CGFloat = 24, action: @escaping () -> Void) {
        self.action = action
        background = SKShapeNode(rectOf: size, cornerRadius: 12)
        background.fillColor = color
        background.strokeColor = .clear

        label = SKLabelNode(text: text)
        label.fontName = "AvenirNext-Bold"
        label.fontSize = fontSize
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        super.init()
        isUserInteractionEnabled = true
        addChild(background)
        addChild(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        background.run(SKAction.scale(to: 0.92, duration: 0.08))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        background.run(SKAction.sequence([
            SKAction.scale(to: 1.0, duration: 0.08),
            SKAction.run { [weak self] in self?.action() }
        ]))
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        background.run(SKAction.scale(to: 1.0, duration: 0.08))
    }
}

// MARK: - Number Formatting
extension Int {
    var formattedWithCommas: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
