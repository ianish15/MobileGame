import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Initialize managers
        AdManager.shared.configure()
        _ = IAPManager.shared
        _ = AudioManager.shared

        // Set default unlocked skins if first launch
        if UserDefaults.standard.stringArray(forKey: StorageKeys.unlockedSkins) == nil {
            UserDefaults.standard.set([PlayerSkin.orange.rawValue], forKey: StorageKeys.unlockedSkins)
        }

        // Create window
        let window = UIWindow(frame: UIScreen.main.bounds)
        let gameVC = GameViewController()
        window.rootViewController = gameVC
        window.makeKeyAndVisible()
        self.window = window

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        AudioManager.shared.pauseBackgroundMusic()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AudioManager.shared.resumeBackgroundMusic()
    }
}
