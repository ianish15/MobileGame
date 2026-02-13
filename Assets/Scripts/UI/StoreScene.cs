using UnityEngine;
using UnityEngine.SceneManagement;

public class StoreScene : MonoBehaviour
{
    private TextMesh coinText;
    private GameObject[] skinButtons;

    void Start()
    {
        EnsureManagers();

        Camera.main.backgroundColor = GameConfig.Colors.SkyBottom;
        Camera.main.orthographicSize = 5f;

        // Background
        var bgObj = new GameObject("Background");
        var bg = bgObj.AddComponent<ParallaxBackground>();
        bg.Initialize(false);
        bg.SetScrollSpeed(0.8f);

        // Dark overlay
        var overlay = new GameObject("Overlay");
        overlay.transform.position = Vector3.zero;
        var overlaySr = overlay.AddComponent<SpriteRenderer>();
        overlaySr.sprite = SpriteGenerator.CreateSquareSprite(4);
        overlaySr.color = new Color(0, 0, 0, 0.35f);
        overlaySr.sortingOrder = 50;
        overlay.transform.localScale = Vector3.one * 20f;

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
        CreateText("STORE", new Vector3(0, 3.8f, 0), 0.16f, 50, Color.white);

        // Section: Character Skins
        CreateText("CHARACTER SKINS", new Vector3(0, 3f, 0), 0.08f, 30, new Color(1, 1, 1, 0.8f));

        // Skin grid
        skinButtons = new GameObject[GameConfig.Skins.Length];
        float startX = -(GameConfig.Skins.Length - 1) * 1.1f / 2f;

        for (int i = 0; i < GameConfig.Skins.Length; i++)
        {
            var skin = GameConfig.Skins[i];
            float x = startX + i * 1.1f;
            skinButtons[i] = CreateSkinButton(skin.name, skin.color, skin.price, new Vector3(x, 1.8f, 0), i);
        }

        // Coin counter
        var coinIcon = new GameObject("CoinIcon");
        coinIcon.transform.position = new Vector3(5f, 3.8f, 0);
        var iconSr = coinIcon.AddComponent<SpriteRenderer>();
        iconSr.sprite = SpriteGenerator.CreateCircleSprite(16);
        iconSr.color = GameConfig.Colors.CoinGold;
        iconSr.sortingOrder = 100;
        coinIcon.transform.localScale = Vector3.one * 0.2f;

        var coinObj = new GameObject("CoinText");
        coinObj.transform.position = new Vector3(5.5f, 3.8f, 0);
        coinText = coinObj.AddComponent<TextMesh>();
        coinText.text = (ScoreManager.Instance?.TotalCoins ?? 0).ToString();
        coinText.fontSize = 34;
        coinText.characterSize = 0.08f;
        coinText.anchor = TextAnchor.MiddleLeft;
        coinText.color = Color.white;
        coinText.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        var coinMr = coinObj.GetComponent<MeshRenderer>();
        coinMr.sortingOrder = 100;

        // Hint text
        CreateText("Earn coins by playing! Collect coins during runs.", new Vector3(0, 0.4f, 0), 0.06f, 24, new Color(1, 1, 1, 0.5f));

        // Back button
        CreateButton("BACK", new Vector3(0, -1.5f, 0), GameConfig.Colors.ButtonSecondary, 2f, 0.55f, () => {
            SceneManager.LoadScene("MenuScene");
        });

        // Keyboard hint
        CreateText("Press ESC to go back", new Vector3(0, -2.5f, 0), 0.05f, 20, new Color(1, 1, 1, 0.4f));
    }

    GameObject CreateSkinButton(string skinName, Color color, int price, Vector3 position, int index)
    {
        var btn = new GameObject("Skin_" + skinName);
        btn.transform.position = position;

        bool isUnlocked = ScoreManager.Instance?.IsSkinUnlocked(skinName) ?? (price == 0);
        bool isSelected = (ScoreManager.Instance?.SelectedSkin ?? "Classic") == skinName;

        // Character circle
        var bodySr = btn.AddComponent<SpriteRenderer>();
        bodySr.sprite = SpriteGenerator.CreateCircleSprite(32);
        bodySr.sortingOrder = 60;
        btn.transform.localScale = Vector3.one * 0.7f;

        if (isUnlocked)
        {
            bodySr.color = color;
        }
        else
        {
            bodySr.color = new Color(color.r * 0.4f, color.g * 0.4f, color.b * 0.4f, 0.7f);
        }

        // Eyes
        var leftEye = new GameObject("LeftEye");
        leftEye.transform.SetParent(btn.transform);
        leftEye.transform.localPosition = new Vector3(-0.2f, 0.12f, 0);
        var leSr = leftEye.AddComponent<SpriteRenderer>();
        leSr.sprite = SpriteGenerator.CreateCircleSprite(8);
        leSr.color = Color.white;
        leSr.sortingOrder = 61;
        leftEye.transform.localScale = Vector3.one * 0.25f;

        var rightEye = new GameObject("RightEye");
        rightEye.transform.SetParent(btn.transform);
        rightEye.transform.localPosition = new Vector3(0.2f, 0.12f, 0);
        var reSr = rightEye.AddComponent<SpriteRenderer>();
        reSr.sprite = SpriteGenerator.CreateCircleSprite(8);
        reSr.color = Color.white;
        reSr.sortingOrder = 61;
        rightEye.transform.localScale = Vector3.one * 0.25f;

        // Selection border
        if (isSelected)
        {
            var border = new GameObject("Border");
            border.transform.SetParent(btn.transform);
            border.transform.localPosition = Vector3.zero;
            var borderSr = border.AddComponent<SpriteRenderer>();
            borderSr.sprite = SpriteGenerator.CreateCircleSprite(32);
            borderSr.color = new Color(1, 1, 1, 0.8f);
            borderSr.sortingOrder = 59;
            border.transform.localScale = Vector3.one * 1.15f;
        }

        // Name label
        var nameObj = new GameObject("Name");
        nameObj.transform.SetParent(btn.transform);
        nameObj.transform.localPosition = new Vector3(0, -0.85f, 0);
        var nameTm = nameObj.AddComponent<TextMesh>();
        nameTm.text = skinName;
        nameTm.fontSize = 24;
        nameTm.characterSize = 0.08f;
        nameTm.anchor = TextAnchor.MiddleCenter;
        nameTm.alignment = TextAlignment.Center;
        nameTm.color = Color.white;
        nameTm.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        var nameMr = nameObj.GetComponent<MeshRenderer>();
        nameMr.sortingOrder = 100;

        // Price label if locked
        if (!isUnlocked)
        {
            var priceObj = new GameObject("Price");
            priceObj.transform.SetParent(btn.transform);
            priceObj.transform.localPosition = new Vector3(0, -1.15f, 0);
            var priceTm = priceObj.AddComponent<TextMesh>();
            priceTm.text = price + " coins";
            priceTm.fontSize = 20;
            priceTm.characterSize = 0.07f;
            priceTm.anchor = TextAnchor.MiddleCenter;
            priceTm.alignment = TextAlignment.Center;
            priceTm.color = GameConfig.Colors.CoinGold;
            priceTm.font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
            var priceMr = priceObj.GetComponent<MeshRenderer>();
            priceMr.sortingOrder = 100;
        }

        // Click handler
        var col = btn.AddComponent<CircleCollider2D>();
        col.radius = 0.5f;
        var handler = btn.AddComponent<UIButton>();
        int skinIndex = index;
        handler.OnClick = () => OnSkinClicked(skinIndex);

        return btn;
    }

    void OnSkinClicked(int index)
    {
        var skin = GameConfig.Skins[index];
        bool isUnlocked = ScoreManager.Instance?.IsSkinUnlocked(skin.name) ?? false;

        if (isUnlocked)
        {
            // Select this skin
            if (ScoreManager.Instance != null)
                ScoreManager.Instance.SelectedSkin = skin.name;
            AudioManager.Instance?.PlaySound("coin");
            RefreshUI();
        }
        else
        {
            // Try to purchase
            if (ScoreManager.Instance != null && ScoreManager.Instance.SpendCoins(skin.price))
            {
                ScoreManager.Instance.UnlockSkin(skin.name);
                ScoreManager.Instance.SelectedSkin = skin.name;
                AudioManager.Instance?.PlaySound("powerUp");
                RefreshUI();
            }
        }
    }

    void RefreshUI()
    {
        // Reload scene to refresh skin display
        SceneManager.LoadScene("StoreScene");
    }

    void Update()
    {
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
        tm.fontSize = 36;
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
