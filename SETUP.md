# Sky Dash - Unity PC Edition

An endless runner game rebuilt in Unity for PC.

## Quick Start

1. **Open in Unity**
   - Open Unity Hub
   - Click "Open" → navigate to this `MobileGame` folder
   - Select Unity version 2022.3 LTS or later (2D template)
   - Wait for Unity to import all assets

2. **Configure Scenes in Build Settings**
   - Go to `File > Build Settings`
   - Add scenes in this order:
     1. `Assets/Scenes/MenuScene.unity`
     2. `Assets/Scenes/GameScene.unity`
     3. `Assets/Scenes/GameOverScene.unity`
     4. `Assets/Scenes/StoreScene.unity`

3. **Configure Tags**
   - Go to `Edit > Project Settings > Tags and Layers`
   - Add these tags if not already present:
     - `Obstacle`
     - `Coin`
     - `PowerUp`
     - `Ground`

4. **Link Scripts to Scene Objects**
   - Open `MenuScene.unity` and attach `MenuScene.cs` to the MenuController object
   - Open `GameScene.unity` and attach `GameSceneController.cs` to the GameController object
   - Open `GameOverScene.unity` and attach `GameOverScene.cs` to the GameOverController object
   - Open `StoreScene.unity` and attach `StoreScene.cs` to the StoreController object

5. **Play!**
   - Open `MenuScene` and press Play in Unity Editor
   - Or build for Windows: `File > Build Settings > Build`

## PC Controls

| Action     | Keys                          |
|-----------|-------------------------------|
| Jump       | Space, W, Up Arrow, Left Click |
| Slide      | S, Down Arrow, Swipe Down      |
| Start Game | Space, Enter                   |
| Restart    | Space, Enter (on Game Over)    |
| Back/Menu  | Escape                         |

## Game Features

- **Endless runner** with increasing difficulty
- **Double jump** mechanic
- **Slide** to duck under barriers
- **3 obstacle types**: Spike, Double-tall Spike, Barrier
- **Coins** with 3 spawn patterns (line, arc, ascending)
- **3 Power-ups**: Shield (absorbs hit), Magnet (attracts coins), x2 Multiplier
- **6 character skins** unlockable with coins
- **Store** to purchase skins with earned coins
- **High score** tracking with persistent save
- **Parallax scrolling** background (sky, clouds, mountains, ground)
- **Procedural sound effects** (no audio files needed)
- **Camera shake** on death

## Project Structure

```
Assets/
├── Scenes/
│   ├── MenuScene.unity
│   ├── GameScene.unity
│   ├── GameOverScene.unity
│   └── StoreScene.unity
├── Scripts/
│   ├── Core/           # GameConfig, GameManager, ScoreManager
│   ├── Player/         # PlayerController, PlayerVisualBuilder
│   ├── Obstacles/      # Obstacle, ObstacleSpawner
│   ├── Collectibles/   # Coin, CoinSpawner, PowerUp
│   ├── Background/     # ParallaxBackground
│   ├── UI/             # MenuScene, GameSceneController, GameOverScene, StoreScene, UIButton
│   ├── Audio/          # AudioManager
│   └── Utils/          # SpriteGenerator, FloatingText, CameraShake
```

All visuals are generated procedurally at runtime - no sprite assets needed!
