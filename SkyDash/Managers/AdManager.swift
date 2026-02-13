import UIKit

/// Ad Manager handles ad display logic.
/// To integrate with a real ad network (e.g., Google AdMob):
/// 1. Add the GoogleMobileAds SDK via Swift Package Manager or CocoaPods
/// 2. Configure your AdMob App ID in Info.plist (GADApplicationIdentifier)
/// 3. Replace the placeholder methods below with real AdMob API calls
///
/// AdMob documentation: https://developers.google.com/admob/ios/quick-start
class AdManager {
    static let shared = AdManager()

    // MARK: - Configuration
    // Replace these with your actual AdMob ad unit IDs
    private let bannerAdUnitID = "ca-app-pub-xxxxxxxxxxxxx/yyyyyyyyyy"
    private let interstitialAdUnitID = "ca-app-pub-xxxxxxxxxxxxx/yyyyyyyyyy"
    private let rewardedAdUnitID = "ca-app-pub-xxxxxxxxxxxxx/yyyyyyyyyy"

    var adsRemoved: Bool {
        get { UserDefaults.standard.bool(forKey: StorageKeys.adsRemoved) }
        set { UserDefaults.standard.set(newValue, forKey: StorageKeys.adsRemoved) }
    }

    private init() {}

    // MARK: - Initialization
    /// Call this in AppDelegate.application(_:didFinishLaunchingWithOptions:)
    func configure() {
        guard !adsRemoved else { return }
        // TODO: Initialize Google Mobile Ads SDK
        // GADMobileAds.sharedInstance().start(completionHandler: nil)
        preloadInterstitial()
        preloadRewardedAd()
    }

    // MARK: - Banner Ads
    /// Returns a banner ad view to be added to the view hierarchy
    func createBannerAd() -> UIView? {
        guard !adsRemoved else { return nil }

        // TODO: Create and return a GADBannerView
        // let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        // bannerView.adUnitID = bannerAdUnitID
        // bannerView.rootViewController = rootViewController
        // bannerView.load(GADRequest())
        // return bannerView

        // Placeholder - returns nil until AdMob SDK is integrated
        return nil
    }

    // MARK: - Interstitial Ads
    private func preloadInterstitial() {
        guard !adsRemoved else { return }
        // TODO: Load interstitial ad
        // GADInterstitialAd.load(withAdUnitID: interstitialAdUnitID, request: GADRequest()) { ad, error in
        //     self.interstitialAd = ad
        // }
    }

    func showInterstitial(completion: @escaping () -> Void) {
        guard !adsRemoved else {
            completion()
            return
        }

        // TODO: Present interstitial ad
        // if let ad = interstitialAd, let rootVC = UIApplication.shared.rootViewController {
        //     ad.present(fromRootViewController: rootVC)
        //     preloadInterstitial() // Preload next one
        // } else {
        //     completion()
        // }

        // Placeholder - just call completion until AdMob is integrated
        completion()
    }

    // MARK: - Rewarded Ads
    private func preloadRewardedAd() {
        guard !adsRemoved else { return }
        // TODO: Load rewarded ad
        // GADRewardedAd.load(withAdUnitID: rewardedAdUnitID, request: GADRequest()) { ad, error in
        //     self.rewardedAd = ad
        // }
    }

    func showRewardedAd(completion: @escaping (_ rewarded: Bool) -> Void) {
        // TODO: Present rewarded ad
        // if let ad = rewardedAd, let rootVC = UIApplication.shared.rootViewController {
        //     ad.present(fromRootViewController: rootVC) {
        //         completion(true)
        //     }
        //     preloadRewardedAd()
        // } else {
        //     completion(false)
        // }

        // Placeholder - simulate reward until AdMob is integrated
        completion(true)
    }
}
