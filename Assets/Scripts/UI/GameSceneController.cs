using UnityEngine;
using UnityEngine.SceneManagement;
using System.Collections;

public class GameSceneController : MonoBehaviour
{
    private ParallaxBackground background;
    private PlayerController player;
    private ObstacleSpawner obstacleSpawner;
    private CoinSpawner coinSpawner;
    private bool gameStarted;

    // HUD elements
    private TextMesh scoreText;
    private TextMesh coinText;
    private GameObject tapToStartLabel;

    void Start()
    {
        EnsureManagers();
        SetupCamera();
        BuildScene();
        BuildHUD();
        ShowTapToStart();
    }

    void EnsureManagers()
    {
        if (GameManager.Instance == null)
        {
            var gm = new GameObject("GameManager");
            gm.AddComponent<GameManager>();
        }
        if (ScoreManager.Instance == null)
        {
            var sm = new GameObject("ScoreManager");
            sm.AddComponent<ScoreManager>();
        }
        if (AudioManager.Instance == null)
        {
            var am = new GameObject("AudioManager");
            am.AddComponent<AudioManager>();
        }
    }

    void SetupCamera()
    {
        Camera.main.backgroundColor = GameConfig.Colors.SkyBottom;
        Camera.main.orthographicSize = 5f;
        if (Camera.main.GetComponent<CameraShake>() == null)
            Camera.main.gameObject.AddComponent<CameraShake>();
    }

    void BuildScene()
    {
        // Background
        var bgObj = new GameObject("Background");
        background = bgObj.AddComponent<ParallaxBackground>();
        background.Initialize(true);

        // Ground physics
        var ground = new GameObject("Ground");
        ground.tag = "Ground";
        ground.transform.position = new Vector3(0, GameConfig.GroundY, 0);
        var groundCol = ground.AddComponent<BoxCollider2D>();
        groundCol.size = new Vector2(30f, GameConfig.GroundHeight);
        var groundRb = ground.AddComponent<Rigidbody2D>();
        groundRb.bodyType = RigidbodyType2D.Static;

        // Player
        var playerObj = new GameObject("Player");
        playerObj.transform.position = new Vector3(GameConfig.PlayerStartX, GameConfig.GroundY + GameConfig.GroundHeight / 2f + GameConfig.PlayerSize / 2f + 0.05f, 0);

        player = playerObj.AddComponent<PlayerController>();
        var playerRb = playerObj.AddComponent<Rigidbody2D>();
        var playerCol = playerObj.AddComponent<BoxCollider2D>();
        playerCol.size = new Vector2(0.45f, 0.45f);

        // Build player visual
        string selectedSkin = ScoreManager.Instance?.SelectedSkin ?? "Classic";
        Color skinColor = GameConfig.Colors.Player;
        foreach (var skin in GameConfig.Skins)
        {
            if (skin.name == selectedSkin) { skinColor = skin.color; break; }
        }
        PlayerVisualBuilder.Build(playerObj.transform, skinColor);

        player.Initialize();

        // Spawners (inactive until game starts)
        var spawnerObj = new GameObject("Spawners");
        obstacleSpawner = spawnerObj.AddComponent<ObstacleSpawner>();
        coinSpawner = spawnerObj.AddComponent<CoinSpawner>();
        obstacleSpawner.enabled = false;
        coinSpawner.enabled = false;

        // Events
        player.OnDeath += HandleGameOver;

        if (GameManager.Instance != null)
        {
            GameManager.Instance.OnGameOver += OnGameOverTransition;
        }

        if (ScoreManager.Instance != null)
        {
            ScoreManager.Instance.ResetRun();
            ScoreManager.Instance.OnScoreChanged += UpdateScoreDisplay;
            ScoreManager.Instance.OnCoinsChanged += UpdateCoinDisplay;
        }
    }

    void BuildHUD()
    {
        // Score text
        var scoreObj = new GameObject("ScoreText");
        scoreObj.transform.position = new Vector3(0, 4.2f, 0);
        scoreText = scoreObj.AddComponent<TextMesh>();
        scoreText.text = "0";
        scoreText.fontSize = 50;
        scoreText.characterSize = 0.1f;
        scoreText.anchor = TextAnchor.MiddleCenter;
        scoreText.alignment = TextAlignment.Center;
        scoreText.color = Color.white;
        scoreText.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        var scoreMr = scoreObj.GetComponent<MeshRenderer>();
        scoreMr.sortingOrder = 100;

        // Shadow for score
        var shadowObj = new GameObject("ScoreShadow");
        shadowObj.transform.position = new Vector3(0.03f, 4.17f, 0);
        var shadowTm = shadowObj.AddComponent<TextMesh>();
        shadowTm.text = "0";
        shadowTm.fontSize = 50;
        shadowTm.characterSize = 0.1f;
        shadowTm.anchor = TextAnchor.MiddleCenter;
        shadowTm.alignment = TextAlignment.Center;
        shadowTm.color = new Color(0, 0, 0, 0.3f);
        shadowTm.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        var shadowMr = shadowObj.GetComponent<MeshRenderer>();
        shadowMr.sortingOrder = 99;

        // Coin counter
        var coinIcon = new GameObject("CoinIcon");
        coinIcon.transform.position = new Vector3(5.5f, 4.2f, 0);
        var iconSr = coinIcon.AddComponent<SpriteRenderer>();
        iconSr.sprite = SpriteGenerator.CreateCircleSprite(16);
        iconSr.color = GameConfig.Colors.CoinGold;
        iconSr.sortingOrder = 100;
        coinIcon.transform.localScale = Vector3.one * 0.18f;

        var coinObj = new GameObject("CoinText");
        coinObj.transform.position = new Vector3(6.1f, 4.2f, 0);
        coinText = coinObj.AddComponent<TextMesh>();
        coinText.text = (ScoreManager.Instance?.TotalCoins ?? 0).ToString();
        coinText.fontSize = 34;
        coinText.characterSize = 0.08f;
        coinText.anchor = TextAnchor.MiddleLeft;
        coinText.alignment = TextAlignment.Left;
        coinText.color = Color.white;
        coinText.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        var coinMr = coinObj.GetComponent<MeshRenderer>();
        coinMr.sortingOrder = 100;
    }

    void ShowTapToStart()
    {
        tapToStartLabel = new GameObject("TapToStart");
        tapToStartLabel.transform.position = new Vector3(0, 1f, 0);
        var tm = tapToStartLabel.AddComponent<TextMesh>();
        tm.text = "PRESS SPACE TO START";
        tm.fontSize = 40;
        tm.characterSize = 0.1f;
        tm.anchor = TextAnchor.MiddleCenter;
        tm.alignment = TextAlignment.Center;
        tm.color = Color.white;
        tm.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        var mr = tapToStartLabel.GetComponent<MeshRenderer>();
        mr.sortingOrder = 100;
    }

    void Update()
    {
        // Pulse tap to start
        if (!gameStarted && tapToStartLabel != null)
        {
            float alpha = 0.5f + Mathf.PingPong(Time.time * 1.5f, 0.5f);
            var tm = tapToStartLabel.GetComponent<TextMesh>();
            tm.color = new Color(1, 1, 1, alpha);
        }

        if (!gameStarted)
        {
            if (Input.GetKeyDown(KeyCode.Space) || Input.GetKeyDown(KeyCode.UpArrow) ||
                Input.GetKeyDown(KeyCode.W) || Input.GetMouseButtonDown(0))
            {
                StartGame();
            }
        }

        // Escape to menu
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            SceneManager.LoadScene("MenuScene");
        }
    }

    void StartGame()
    {
        gameStarted = true;
        if (tapToStartLabel != null) Destroy(tapToStartLabel);

        player.Activate();
        obstacleSpawner.enabled = true;
        coinSpawner.enabled = true;

        GameManager.Instance?.StartGame();
    }

    void UpdateScoreDisplay(int score)
    {
        if (scoreText != null)
            scoreText.text = score.ToString("N0");

        // Update shadow too
        var shadow = GameObject.Find("ScoreShadow");
        if (shadow != null)
        {
            var tm = shadow.GetComponent<TextMesh>();
            if (tm != null) tm.text = score.ToString("N0");
        }
    }

    void UpdateCoinDisplay(int coins)
    {
        if (coinText != null)
            coinText.text = coins.ToString();
    }

    void HandleGameOver()
    {
        obstacleSpawner.enabled = false;
        coinSpawner.enabled = false;

        // Screen flash red
        StartCoroutine(FlashRed());

        // Camera shake
        CameraShake.Instance?.Shake(0.4f, 0.25f);
    }

    void OnGameOverTransition()
    {
        StartCoroutine(TransitionToGameOver());
    }

    IEnumerator FlashRed()
    {
        var flash = new GameObject("RedFlash");
        flash.transform.position = Vector3.zero;
        var sr = flash.AddComponent<SpriteRenderer>();
        sr.sprite = SpriteGenerator.CreateSquareSprite(4);
        sr.color = new Color(1, 0, 0, 0.3f);
        sr.sortingOrder = 200;
        flash.transform.localScale = Vector3.one * 20f;

        float t = 0;
        while (t < 0.3f)
        {
            t += Time.deltaTime;
            sr.color = new Color(1, 0, 0, 0.3f * (1f - t / 0.3f));
            yield return null;
        }
        Destroy(flash);
    }

    IEnumerator TransitionToGameOver()
    {
        yield return new WaitForSeconds(0.5f);

        // Store score data for game over screen
        bool isNewBest = ScoreManager.Instance?.SubmitScore() ?? false;
        PlayerPrefs.SetInt("last_score", ScoreManager.Instance?.CurrentScore ?? 0);
        PlayerPrefs.SetInt("last_coins", ScoreManager.Instance?.CoinsCollectedThisRun ?? 0);
        PlayerPrefs.SetInt("last_is_new_best", isNewBest ? 1 : 0);

        SceneManager.LoadScene("GameOverScene");
    }

    void OnDestroy()
    {
        if (ScoreManager.Instance != null)
        {
            ScoreManager.Instance.OnScoreChanged -= UpdateScoreDisplay;
            ScoreManager.Instance.OnCoinsChanged -= UpdateCoinDisplay;
        }
        if (GameManager.Instance != null)
        {
            GameManager.Instance.OnGameOver -= OnGameOverTransition;
        }
    }
}
