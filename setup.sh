#!/bin/bash
# ========================================
# Sky Dash - iOS Game Setup Script
# ========================================

set -e

echo "🎮 Sky Dash - Setup Script"
echo "=========================="
echo ""

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "⚠️  This project requires macOS with Xcode to build."
    echo "   You can still browse and edit the source code on any platform."
    echo ""
    echo "📁 Project structure:"
    echo "   SkyDash/"
    echo "   ├── App/           - App entry points"
    echo "   ├── Scenes/        - Game scenes (Menu, Game, GameOver, Store)"
    echo "   ├── Nodes/         - Game objects (Player, Obstacles, Coins)"
    echo "   ├── Managers/      - Game services (Score, Ads, IAP, Audio)"
    echo "   ├── Utils/         - Constants, extensions, helpers"
    echo "   └── Resources/     - Info.plist, assets, storyboards"
    exit 0
fi

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Check for XcodeGen
if ! command -v xcodegen &> /dev/null; then
    echo "📦 Installing XcodeGen..."
    brew install xcodegen
else
    echo "✅ XcodeGen is installed"
fi

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed."
    echo "   Please install Xcode from the Mac App Store."
    echo "   https://apps.apple.com/us/app/xcode/id497799835"
    exit 1
else
    echo "✅ Xcode is installed"
fi

echo ""
echo "🔨 Generating Xcode project..."
xcodegen generate

echo ""
echo "✅ Setup complete!"
echo ""
echo "📱 Next steps:"
echo "   1. Open SkyDash.xcodeproj in Xcode"
echo "   2. Select your Team in Signing & Capabilities"
echo "   3. Connect your iPhone or use the Simulator"
echo "   4. Press Cmd+R to build and run"
echo ""
echo "💰 To enable monetization:"
echo "   • Ads: Add Google AdMob SDK and update AdManager.swift"
echo "   • IAP: Configure products in App Store Connect"
echo "   • See docs in each Manager file for setup instructions"
echo ""
echo "🚀 To publish to the App Store:"
echo "   1. Enroll in Apple Developer Program (\$99/year)"
echo "   2. Create app in App Store Connect"
echo "   3. Add app icon (1024x1024) to Assets.xcassets"
echo "   4. Configure IAP products in App Store Connect"
echo "   5. Take screenshots on required device sizes"
echo "   6. Archive & upload via Xcode (Product → Archive)"
echo ""
