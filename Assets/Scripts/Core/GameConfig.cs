using UnityEngine;

public static class GameConfig
{
    // Scene dimensions (reference resolution)
    public const float ReferenceWidth = 1334f;
    public const float ReferenceHeight = 750f;

    // Ground
    public const float GroundY = -2.5f;
    public const float GroundHeight = 1.5f;

    // Player
    public const float PlayerStartX = -4f;
    public const float PlayerSize = 0.5f;
    public const int MaxJumps = 2;
    public const float JumpForce = 12f;
    public const float SlideDuration = 0.6f;

    // Physics
    public const float Gravity = -35f;

    // Speed & Difficulty
    public const float InitialSpeed = 5f;
    public const float MaxSpeed = 12f;
    public const float SpeedIncrement = 0.002f;

    // Spawning
    public const float ObstacleMinInterval = 1.4f;
    public const float ObstacleMaxInterval = 2.8f;
    public const float CoinSpawnInterval = 2.0f;
    public const float PowerUpChance = 0.08f;

    // Scoring
    public const int CoinPointValue = 10;
    public const int CoinCurrencyValue = 1;
    public const int FramePointInterval = 3;

    // Power-ups
    public const float ShieldDuration = 5f;
    public const float MagnetDuration = 8f;
    public const float MultiplierDuration = 10f;
    public const float MagnetRange = 2.5f;
    public const float MagnetPullStrength = 8f;

    // Spawn positions
    public const float SpawnX = 10f;
    public const float DespawnX = -12f;

    // Parallax speeds
    public const float CloudSpeedFactor = 0.1f;
    public const float MountainSpeedFactor = 0.2f;
    public const float GroundSpeedFactor = 1.0f;

    // Skin prices
    public static readonly (string name, Color color, int price)[] Skins = new[]
    {
        ("Classic", new Color(1f, 0.42f, 0.21f), 0),
        ("Ocean", new Color(0.2f, 0.6f, 0.9f), 100),
        ("Forest", new Color(0.2f, 0.75f, 0.3f), 200),
        ("Mystic", new Color(0.6f, 0.3f, 0.9f), 300),
        ("Golden", new Color(1f, 0.84f, 0f), 400),
        ("Rainbow", new Color(1f, 0.4f, 0.7f), 500),
    };

    // Colors
    public static class Colors
    {
        public static readonly Color SkyTop = new Color(0.29f, 0.56f, 0.85f);
        public static readonly Color SkyBottom = new Color(0.53f, 0.81f, 0.92f);
        public static readonly Color Ground = new Color(0.30f, 0.69f, 0.31f);
        public static readonly Color GroundDirt = new Color(0.47f, 0.33f, 0.28f);
        public static readonly Color Obstacle = new Color(0.90f, 0.22f, 0.21f);
        public static readonly Color ObstacleDark = new Color(0.70f, 0.15f, 0.15f);
        public static readonly Color CoinGold = new Color(1f, 0.84f, 0f);
        public static readonly Color Cloud = new Color(1f, 1f, 1f, 0.85f);
        public static readonly Color Mountain = new Color(0.35f, 0.55f, 0.35f, 0.6f);
        public static readonly Color Shield = new Color(0f, 0.74f, 0.83f);
        public static readonly Color Magnet = new Color(0.96f, 0.26f, 0.56f);
        public static readonly Color Multiplier = new Color(0f, 0.90f, 0.46f);
        public static readonly Color Player = new Color(1f, 0.42f, 0.21f);
        public static readonly Color ButtonPrimary = new Color(1f, 0.42f, 0.21f);
        public static readonly Color ButtonSecondary = new Color(0.29f, 0.56f, 0.85f);
        public static readonly Color ButtonGreen = new Color(0.2f, 0.8f, 0.3f);
    }

    // PlayerPrefs keys
    public static class Keys
    {
        public const string HighScore = "sky_dash_high_score";
        public const string TotalCoins = "sky_dash_total_coins";
        public const string GamesPlayed = "sky_dash_games_played";
        public const string SelectedSkin = "sky_dash_selected_skin";
        public const string UnlockedSkins = "sky_dash_unlocked_skins";
        public const string MusicEnabled = "sky_dash_music_enabled";
        public const string SoundEnabled = "sky_dash_sound_enabled";
    }
}
