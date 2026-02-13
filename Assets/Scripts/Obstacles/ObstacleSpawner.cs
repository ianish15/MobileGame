using UnityEngine;

public class ObstacleSpawner : MonoBehaviour
{
    private float spawnTimer;

    void OnEnable()
    {
        ResetTimer();
    }

    void Update()
    {
        if (GameManager.Instance == null || GameManager.Instance.CurrentState != GameManager.GameState.Playing) return;

        spawnTimer -= Time.deltaTime;
        if (spawnTimer <= 0)
        {
            SpawnObstacle();
            ResetTimer();
        }
    }

    void ResetTimer()
    {
        float difficulty = GameManager.Instance != null ? GameManager.Instance.Difficulty : 0;
        float min = GameConfig.ObstacleMinInterval - difficulty * 0.4f;
        float max = GameConfig.ObstacleMaxInterval - difficulty * 0.8f;
        min = Mathf.Max(min, 0.8f);
        max = Mathf.Max(max, min + 0.3f);
        spawnTimer = Random.Range(min, max);
    }

    void SpawnObstacle()
    {
        float difficulty = GameManager.Instance != null ? GameManager.Instance.Difficulty : 0;
        float roll = Random.value;

        Obstacle.ObstacleType type;
        if (difficulty > 0.5f && roll < 0.15f)
            type = Obstacle.ObstacleType.DoubleTallSpike;
        else if (roll < 0.5f)
            type = Obstacle.ObstacleType.Barrier;
        else
            type = Obstacle.ObstacleType.Spike;

        CreateObstacle(type);
    }

    void CreateObstacle(Obstacle.ObstacleType type)
    {
        var go = new GameObject("Obstacle_" + type);
        go.tag = "Obstacle";
        go.transform.position = new Vector3(GameConfig.SpawnX, GameConfig.GroundY + GameConfig.GroundHeight / 2f, 0);

        var obstacle = go.AddComponent<Obstacle>();
        obstacle.Type = type;

        switch (type)
        {
            case Obstacle.ObstacleType.Spike:
                BuildSpike(go, 0.45f, 0.55f);
                go.transform.position = new Vector3(GameConfig.SpawnX, GameConfig.GroundY + GameConfig.GroundHeight / 2f + 0.15f, 0);
                break;

            case Obstacle.ObstacleType.DoubleTallSpike:
                BuildSpike(go, 0.45f, 0.9f);
                go.transform.position = new Vector3(GameConfig.SpawnX, GameConfig.GroundY + GameConfig.GroundHeight / 2f + 0.3f, 0);
                break;

            case Obstacle.ObstacleType.Barrier:
                BuildBarrier(go);
                go.transform.position = new Vector3(GameConfig.SpawnX, GameConfig.GroundY + GameConfig.GroundHeight / 2f + 0.7f, 0);
                break;
        }
    }

    void BuildSpike(GameObject go, float width, float height)
    {
        // Triangle body
        var sr = go.AddComponent<SpriteRenderer>();
        sr.sprite = SpriteGenerator.CreateTriangleSprite(32);
        sr.color = GameConfig.Colors.Obstacle;
        sr.sortingOrder = 5;
        go.transform.localScale = new Vector3(width, height, 1);

        // Collider (trigger for obstacle detection)
        var col = go.AddComponent<BoxCollider2D>();
        col.isTrigger = true;
        col.size = new Vector2(0.6f, 0.85f);
        col.offset = new Vector2(0, -0.075f);
    }

    void BuildBarrier(GameObject go)
    {
        // Main barrier body (top part you must slide under)
        var topPart = new GameObject("TopPart");
        topPart.transform.SetParent(go.transform);
        topPart.transform.localPosition = new Vector3(0, 0.2f, 0);

        var sr = topPart.AddComponent<SpriteRenderer>();
        sr.sprite = SpriteGenerator.CreateSquareSprite(16);
        sr.color = GameConfig.Colors.Obstacle;
        sr.sortingOrder = 5;
        topPart.transform.localScale = new Vector3(0.5f, 0.8f, 1);

        // Warning stripes
        var stripes = new GameObject("Stripes");
        stripes.transform.SetParent(topPart.transform);
        stripes.transform.localPosition = Vector3.zero;
        var stripesSr = stripes.AddComponent<SpriteRenderer>();
        stripesSr.sprite = SpriteGenerator.CreateSquareSprite(8);
        stripesSr.color = GameConfig.Colors.ObstacleDark;
        stripesSr.sortingOrder = 6;
        stripes.transform.localScale = new Vector3(0.8f, 0.3f, 1);

        // Support pole
        var pole = new GameObject("Pole");
        pole.transform.SetParent(go.transform);
        pole.transform.localPosition = new Vector3(0, -0.4f, 0);
        var poleSr = pole.AddComponent<SpriteRenderer>();
        poleSr.sprite = SpriteGenerator.CreateSquareSprite(8);
        poleSr.color = GameConfig.Colors.ObstacleDark;
        poleSr.sortingOrder = 5;
        pole.transform.localScale = new Vector3(0.08f, 0.4f, 1);

        // Collider on parent (trigger, positioned at the barrier top)
        var col = go.AddComponent<BoxCollider2D>();
        col.isTrigger = true;
        col.size = new Vector2(0.45f, 0.7f);
        col.offset = new Vector2(0, 0.2f);
    }
}
