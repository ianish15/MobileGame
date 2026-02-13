using UnityEngine;

public class CoinSpawner : MonoBehaviour
{
    private float spawnTimer;

    void OnEnable()
    {
        spawnTimer = GameConfig.CoinSpawnInterval;
    }

    void Update()
    {
        if (GameManager.Instance == null || GameManager.Instance.CurrentState != GameManager.GameState.Playing) return;

        spawnTimer -= Time.deltaTime;
        if (spawnTimer <= 0)
        {
            SpawnCoinPattern();
            spawnTimer = GameConfig.CoinSpawnInterval;
        }
    }

    void SpawnCoinPattern()
    {
        // Maybe spawn a power-up instead
        if (Random.value < GameConfig.PowerUpChance)
        {
            SpawnPowerUp();
            return;
        }

        int pattern = Random.Range(0, 3);
        int count = Random.Range(1, 5);
        float baseY = GameConfig.GroundY + GameConfig.GroundHeight / 2f + 0.5f;

        for (int i = 0; i < count; i++)
        {
            float x = GameConfig.SpawnX + i * 0.6f;
            float y = baseY;

            switch (pattern)
            {
                case 0: // Horizontal line
                    break;
                case 1: // Arc
                    y += Mathf.Sin((float)i / count * Mathf.PI) * 1.2f;
                    break;
                case 2: // Ascending
                    y += i * 0.4f;
                    break;
            }

            CreateCoin(new Vector3(x, y, 0));
        }
    }

    void CreateCoin(Vector3 position)
    {
        var go = new GameObject("Coin");
        go.tag = "Coin";
        go.transform.position = position;

        // Gold circle
        var sr = go.AddComponent<SpriteRenderer>();
        sr.sprite = SpriteGenerator.CreateCircleSprite(16);
        sr.color = GameConfig.Colors.CoinGold;
        sr.sortingOrder = 5;
        go.transform.localScale = Vector3.one * 0.25f;

        // Star inside
        var star = new GameObject("Star");
        star.transform.SetParent(go.transform);
        star.transform.localPosition = Vector3.zero;
        var starSr = star.AddComponent<SpriteRenderer>();
        starSr.sprite = SpriteGenerator.CreateDiamondSprite(8);
        starSr.color = new Color(1f, 0.95f, 0.5f);
        starSr.sortingOrder = 6;
        star.transform.localScale = Vector3.one * 0.5f;

        // Trigger collider
        var col = go.AddComponent<CircleCollider2D>();
        col.isTrigger = true;
        col.radius = 0.4f;

        go.AddComponent<Coin>();
    }

    void SpawnPowerUp()
    {
        int type = Random.Range(0, 3);
        float y = GameConfig.GroundY + GameConfig.GroundHeight / 2f + 0.8f;
        Vector3 pos = new Vector3(GameConfig.SpawnX, y, 0);

        var go = new GameObject("PowerUp");
        go.tag = "PowerUp";
        go.transform.position = pos;

        Color color;
        string label;
        PowerUp.PowerUpType pType;

        switch (type)
        {
            case 0:
                color = GameConfig.Colors.Shield;
                label = "S";
                pType = PowerUp.PowerUpType.Shield;
                break;
            case 1:
                color = GameConfig.Colors.Magnet;
                label = "M";
                pType = PowerUp.PowerUpType.Magnet;
                break;
            default:
                color = GameConfig.Colors.Multiplier;
                label = "x2";
                pType = PowerUp.PowerUpType.Multiplier;
                break;
        }

        var sr = go.AddComponent<SpriteRenderer>();
        sr.sprite = SpriteGenerator.CreateCircleSprite(16);
        sr.color = color;
        sr.sortingOrder = 5;
        go.transform.localScale = Vector3.one * 0.3f;

        // Label
        var labelObj = new GameObject("Label");
        labelObj.transform.SetParent(go.transform);
        labelObj.transform.localPosition = Vector3.zero;
        var tm = labelObj.AddComponent<TextMesh>();
        tm.text = label;
        tm.fontSize = 28;
        tm.characterSize = 0.08f;
        tm.anchor = TextAnchor.MiddleCenter;
        tm.alignment = TextAlignment.Center;
        tm.color = Color.white;
        var mr = labelObj.GetComponent<MeshRenderer>();
        mr.sortingOrder = 6;

        var col = go.AddComponent<CircleCollider2D>();
        col.isTrigger = true;
        col.radius = 0.4f;

        var powerUp = go.AddComponent<PowerUp>();
        powerUp.Type = pType;
    }
}
