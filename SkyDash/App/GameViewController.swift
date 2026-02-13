import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = view as? SKView else {
            // Replace view with SKView if needed
            let skView = SKView(frame: view.bounds)
            skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view = skView
            setupScene(in: skView)
            return
        }
        setupScene(in: skView)
    }

    private func setupScene(in skView: SKView) {
        // Configure SKView
        skView.ignoresSiblingOrder = true
        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        #endif

        // Create and present menu scene
        let scene = MenuScene(size: CGSize(
            width: GameConfig.sceneWidth,
            height: GameConfig.sceneHeight
        ))
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }

    // MARK: - View Controller Overrides
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
