using UnityEngine;
using UnityEngine.SceneManagement;

public class GameOverScene : MonoBehaviour
{
    private GameObject newBestText;
    private float pulseTime;

    void Start()
    {
        EnsureManagers();

        Camera.main.backgroundColor = GameConfig.Colors.SkyBottom;
        Camera.main.orthographicSize = 5f;

        // Slow scrolling background
        var bgObj = new GameObject("Background");
        var bg = bgObj.AddComponent<ParallaxBackground>();
        bg.Initialize(false);
        bg.SetScrollSpeed(0.5f);

        // Dark overlay
        var overlay = new GameObject("Overlay");
        overlay.transform.position = Vector3.zero;
        var overlaySr = overlay.AddComponent<SpriteRenderer>();
        overlaySr.sprite = SpriteGenerator.CreateSquareSprite(4);
        overlaySr.color = new Color(0, 0, 0, 0.4f);
        overlaySr.sortingOrder = 50;
        overlay.transform.localScale = Vector3.one * 20f;

        int lastScore = PlayerPrefs.GetInt("last_score", 0);
        int lastCoins = PlayerPrefs.GetInt("last_coins", 0);
        bool isNewBest = PlayerPrefs.GetInt("last_is_new_best", 0) == 1;
        int highScore = ScoreManager.Instance?.HighScore ?? 0;

        BuildUI(lastScore, lastCoins, isNewBest, highScore);
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

    void BuildUI(int score, int coins, bool isNewBest, int highScore)
    {
        // Title
        CreateText("GAME OVER", new Vector3(0, 3.5f, 0), 0.18f, 55, Color.white);

        // New best indicator
        if (isNewBest)
        {
            newBestText = CreateText("NEW BEST!", new Vector3(0, 2.7f, 0), 0.12f, 40, GameConfig.Colors.CoinGold);
        }

        // Score panel background
        var panel = new GameObject("Panel");
        panel.transform.position = new Vector3(0, 1.2f, 0);
        var panelSr = panel.AddComponent<SpriteRenderer>();
        panelSr.sprite = SpriteGenerator.CreateRoundedSquareSprite(32, 6);
        panelSr.color = new Color(0, 0, 0, 0.5f);
        panelSr.sortingOrder = 60;
        panel.transform.localScale = new Vector3(4f, 2.5f, 1);

        // Score
        CreateText("SCORE", new Vector3(0, 2f, 0), 0.07f, 28, new Color(1, 1, 1, 0.7f));
        CreateText(score.ToString("N0"), new Vector3(0, 1.5f, 0), 0.14f, 45, Color.white);

        // Coins
        CreateText("COINS", new Vector3(-1.2f, 0.8f, 0), 0.06f, 24, new Color(1, 1, 1, 0.7f));
        CreateText(coins.ToString(), new Vector3(-1.2f, 0.4f, 0), 0.1f, 36, GameConfig.Colors.CoinGold);

        // Best
        CreateText("BEST", new Vector3(1.2f, 0.8f, 0), 0.06f, 24, new Color(1, 1, 1, 0.7f));
        CreateText(highScore.ToString("N0"), new Vector3(1.2f, 0.4f, 0), 0.1f, 36, Color.white);

        // Buttons
        CreateButton("PLAY AGAIN", new Vector3(0, -1.2f, 0), GameConfig.Colors.ButtonPrimary, 3f, 0.65f, () => {
            SceneManager.LoadScene("GameScene");
        });

        CreateButton("MENU", new Vector3(0, -2.2f, 0), GameConfig.Colors.ButtonSecondary, 2.2f, 0.55f, () => {
            SceneManager.LoadScene("MenuScene");
        });
    }

    void Update()
    {
        // Pulse new best text
        if (newBestText != null)
        {
            pulseTime += Time.deltaTime;
            float scale = 1f + Mathf.Sin(pulseTime * 3f) * 0.08f;
            newBestText.transform.localScale = Vector3.one * scale;
        }

        // Quick restart
        if (Input.GetKeyDown(KeyCode.Space) || Input.GetKeyDown(KeyCode.Return))
        {
            SceneManager.LoadScene("GameScene");
        }

        if (Input.GetKeyDown(KeyCode.Escape))
        {
            SceneManager.LoadScene("MenuScene");
        }
    }

    GameObject CreateText(string text, Vector3 position, float charSize, int fontSize, Color color)
    {
        var go = new GameObject("Text_" + text);
        go.transform.position = position;
        var tm = go.AddComponent<TextMesh>();
        tm.text = text;
        tm.fontSize = fontSize;
        tm.characterSize = charSize;
        tm.anchor = TextAnchor.MiddleCenter;
        tm.alignment = TextAlignment.Center;
        tm.color = color;
        tm.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        var mr = go.GetComponent<MeshRenderer>();
        mr.sortingOrder = 100;
        return go;
    }

    void CreateButton(string text, Vector3 position, Color color, float width, float height, System.Action onClick)
    {
        var btn = new GameObject("Button_" + text);
        btn.transform.position = position;

        var bgSr = btn.AddComponent<SpriteRenderer>();
        bgSr.sprite = SpriteGenerator.CreateRoundedSquareSprite(32, 6);
        bgSr.color = color;
        bgSr.sortingOrder = 100;
        btn.transform.localScale = new Vector3(width, height, 1);

        var label = new GameObject("Label");
        label.transform.SetParent(btn.transform);
        label.transform.localPosition = Vector3.zero;
        var tm = label.AddComponent<TextMesh>();
        tm.text = text;
        tm.fontSize = 38;
        tm.characterSize = 0.08f;
        tm.anchor = TextAnchor.MiddleCenter;
        tm.alignment = TextAlignment.Center;
        tm.color = Color.white;
        tm.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        label.transform.localScale = new Vector3(1f / width, 1f / height, 1);
        var mr = label.GetComponent<MeshRenderer>();
        mr.sortingOrder = 101;

        var col = btn.AddComponent<BoxCollider2D>();
        col.size = Vector2.one;
        var handler = btn.AddComponent<UIButton>();
        handler.OnClick = onClick;
    }
}
