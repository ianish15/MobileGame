using UnityEngine;
using UnityEngine.SceneManagement;

public class MenuScene : MonoBehaviour
{
    private ParallaxBackground background;
    private GameObject titleText;
    private float titleBounceTime;

    void Start()
    {
        // Ensure managers exist
        EnsureManagers();

        // Background
        var bgObj = new GameObject("Background");
        background = bgObj.AddComponent<ParallaxBackground>();
        background.Initialize(false);
        background.SetScrollSpeed(1.5f);

        // Camera setup
        Camera.main.backgroundColor = GameConfig.Colors.SkyBottom;
        Camera.main.orthographicSize = 5f;

        BuildUI();
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

    void BuildUI()
    {
        // Title
        titleText = CreateText("SKY DASH", new Vector3(0, 2.5f, 0), 0.2f, 60, GameConfig.Colors.ButtonPrimary);

        // Subtitle
        CreateText("Space/Tap = Jump  |  Down/Swipe = Slide", new Vector3(0, 1.7f, 0), 0.08f, 32, new Color(1, 1, 1, 0.8f));

        // PC controls hint
        CreateText("W/Up/Space: Jump  |  S/Down: Slide", new Vector3(0, 1.2f, 0), 0.07f, 28, new Color(1, 1, 1, 0.6f));

        // Play button
        CreateButton("PLAY", new Vector3(0, 0f, 0), GameConfig.Colors.ButtonPrimary, 2.5f, 0.7f, () => {
            SceneManager.LoadScene("GameScene");
        });

        // Store button
        CreateButton("STORE", new Vector3(0, -1f, 0), GameConfig.Colors.ButtonSecondary, 2f, 0.55f, () => {
            SceneManager.LoadScene("StoreScene");
        });

        // High score
        int highScore = ScoreManager.Instance != null ? ScoreManager.Instance.HighScore : 0;
        if (highScore > 0)
        {
            CreateText("BEST: " + highScore.ToString("N0"), new Vector3(0, -2.2f, 0), 0.08f, 30, new Color(1, 1, 1, 0.7f));
        }

        // Coin counter
        int coins = ScoreManager.Instance != null ? ScoreManager.Instance.TotalCoins : 0;
        CreateCoinCounter(coins);
    }

    void Update()
    {
        // Bounce title
        if (titleText != null)
        {
            titleBounceTime += Time.deltaTime;
            float yOffset = Mathf.Sin(titleBounceTime * 2f) * 0.1f;
            titleText.transform.position = new Vector3(0, 2.5f + yOffset, 0);
        }

        // Quick start with space
        if (Input.GetKeyDown(KeyCode.Return) || Input.GetKeyDown(KeyCode.Space))
        {
            SceneManager.LoadScene("GameScene");
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

        // Background
        var bgSr = btn.AddComponent<SpriteRenderer>();
        bgSr.sprite = SpriteGenerator.CreateRoundedSquareSprite(32, 6);
        bgSr.color = color;
        bgSr.sortingOrder = 100;
        btn.transform.localScale = new Vector3(width, height, 1);

        // Label
        var label = new GameObject("Label");
        label.transform.SetParent(btn.transform);
        label.transform.localPosition = Vector3.zero;
        var tm = label.AddComponent<TextMesh>();
        tm.text = text;
        tm.fontSize = 40;
        tm.characterSize = 0.08f;
        tm.anchor = TextAnchor.MiddleCenter;
        tm.alignment = TextAlignment.Center;
        tm.color = Color.white;
        tm.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        label.transform.localScale = new Vector3(1f / width, 1f / height, 1);

        var mr = label.GetComponent<MeshRenderer>();
        mr.sortingOrder = 101;

        // Click handler
        var col = btn.AddComponent<BoxCollider2D>();
        col.size = Vector2.one;
        var handler = btn.AddComponent<UIButton>();
        handler.OnClick = onClick;
    }

    void CreateCoinCounter(int coins)
    {
        // Coin icon
        var icon = new GameObject("CoinIcon");
        icon.transform.position = new Vector3(5.5f, 4.2f, 0);
        var sr = icon.AddComponent<SpriteRenderer>();
        sr.sprite = SpriteGenerator.CreateCircleSprite(16);
        sr.color = GameConfig.Colors.CoinGold;
        sr.sortingOrder = 100;
        icon.transform.localScale = Vector3.one * 0.2f;

        CreateText(coins.ToString(), new Vector3(6.1f, 4.2f, 0), 0.08f, 30, Color.white);
    }
}
