using UnityEngine;

public class ParallaxBackground : MonoBehaviour
{
    private Transform[] clouds;
    private Transform[] mountains;
    private Transform[] groundTiles;
    private Transform grassLayer;

    private float scrollSpeed = 1.5f; // menu speed
    private bool useGameSpeed = false;

    public void Initialize(bool gameplayMode)
    {
        useGameSpeed = gameplayMode;
        BuildSky();
        BuildClouds();
        BuildMountains();
        BuildGround();
    }

    public void SetScrollSpeed(float speed)
    {
        scrollSpeed = speed;
    }

    float CurrentSpeed
    {
        get
        {
            if (useGameSpeed && GameManager.Instance != null && GameManager.Instance.CurrentState == GameManager.GameState.Playing)
                return GameManager.Instance.GameSpeed;
            return scrollSpeed;
        }
    }

    void Update()
    {
        float speed = CurrentSpeed;

        // Scroll clouds
        if (clouds != null)
        {
            foreach (var cloud in clouds)
            {
                if (cloud == null) continue;
                cloud.position += Vector3.left * speed * GameConfig.CloudSpeedFactor * Time.deltaTime;
                if (cloud.position.x < -12f)
                    cloud.position = new Vector3(12f + Random.Range(0f, 3f), cloud.position.y, cloud.position.z);
            }
        }

        // Scroll mountains
        if (mountains != null)
        {
            foreach (var mountain in mountains)
            {
                if (mountain == null) continue;
                mountain.position += Vector3.left * speed * GameConfig.MountainSpeedFactor * Time.deltaTime;
                if (mountain.position.x < -12f)
                    mountain.position = new Vector3(12f + Random.Range(0f, 4f), mountain.position.y, mountain.position.z);
            }
        }

        // Scroll ground
        if (groundTiles != null)
        {
            foreach (var tile in groundTiles)
            {
                if (tile == null) continue;
                tile.position += Vector3.left * speed * GameConfig.GroundSpeedFactor * Time.deltaTime;
                if (tile.position.x < -16f)
                    tile.position = new Vector3(tile.position.x + 32f, tile.position.y, tile.position.z);
            }
        }
    }

    void BuildSky()
    {
        var skyParent = new GameObject("Sky");
        skyParent.transform.SetParent(transform);

        // Create gradient strips
        int strips = 10;
        float stripHeight = 12f / strips;
        for (int i = 0; i < strips; i++)
        {
            float t = (float)i / (strips - 1);
            Color color = Color.Lerp(GameConfig.Colors.SkyBottom, GameConfig.Colors.SkyTop, t);

            var strip = new GameObject("SkyStrip_" + i);
            strip.transform.SetParent(skyParent.transform);
            strip.transform.position = new Vector3(0, -4f + i * stripHeight, 0);

            var sr = strip.AddComponent<SpriteRenderer>();
            sr.sprite = SpriteGenerator.CreateSquareSprite(4);
            sr.color = color;
            sr.sortingOrder = -100;
            strip.transform.localScale = new Vector3(25f, stripHeight + 0.05f, 1);
        }
    }

    void BuildClouds()
    {
        clouds = new Transform[6];
        var cloudParent = new GameObject("Clouds");
        cloudParent.transform.SetParent(transform);

        for (int i = 0; i < 6; i++)
        {
            var cloud = CreateCloud();
            cloud.transform.SetParent(cloudParent.transform);
            float x = Random.Range(-10f, 10f);
            float y = Random.Range(1f, 4f);
            cloud.transform.position = new Vector3(x, y, 0);
            float scale = Random.Range(0.6f, 1.2f);
            cloud.transform.localScale = Vector3.one * scale;
            clouds[i] = cloud.transform;
        }
    }

    GameObject CreateCloud()
    {
        var cloud = new GameObject("Cloud");

        // Build from overlapping ellipses
        for (int i = 0; i < 3; i++)
        {
            var blob = new GameObject("Blob_" + i);
            blob.transform.SetParent(cloud.transform);
            blob.transform.localPosition = new Vector3((i - 1) * 0.4f, Random.Range(-0.05f, 0.1f), 0);

            var sr = blob.AddComponent<SpriteRenderer>();
            sr.sprite = SpriteGenerator.CreateCircleSprite(16);
            float alpha = Random.Range(0.4f, 0.8f);
            sr.color = new Color(1f, 1f, 1f, alpha);
            sr.sortingOrder = -50;

            float sx = Random.Range(0.5f, 0.8f);
            float sy = Random.Range(0.3f, 0.5f);
            blob.transform.localScale = new Vector3(sx, sy, 1);
        }

        return cloud;
    }

    void BuildMountains()
    {
        mountains = new Transform[4];
        var mountainParent = new GameObject("Mountains");
        mountainParent.transform.SetParent(transform);

        for (int i = 0; i < 4; i++)
        {
            var mountain = CreateMountain();
            mountain.transform.SetParent(mountainParent.transform);
            float x = -6f + i * 5f + Random.Range(-1f, 1f);
            mountain.transform.position = new Vector3(x, GameConfig.GroundY + GameConfig.GroundHeight / 2f - 0.2f, 0);
            mountains[i] = mountain.transform;
        }
    }

    GameObject CreateMountain()
    {
        var mountain = new GameObject("Mountain");

        var sr = mountain.AddComponent<SpriteRenderer>();
        sr.sprite = SpriteGenerator.CreateTriangleSprite(32);
        sr.color = GameConfig.Colors.Mountain;
        sr.sortingOrder = -30;

        float width = Random.Range(2f, 4f);
        float height = Random.Range(1.5f, 3f);
        mountain.transform.localScale = new Vector3(width, height, 1);

        return mountain;
    }

    void BuildGround()
    {
        groundTiles = new Transform[4];
        var groundParent = new GameObject("GroundParent");
        groundParent.transform.SetParent(transform);

        for (int i = 0; i < 4; i++)
        {
            var tile = CreateGroundTile();
            tile.transform.SetParent(groundParent.transform);
            tile.transform.position = new Vector3(-8f + i * 8f, GameConfig.GroundY, 0);
            groundTiles[i] = tile.transform;
        }
    }

    GameObject CreateGroundTile()
    {
        var tile = new GameObject("GroundTile");

        // Dirt layer
        var dirt = new GameObject("Dirt");
        dirt.transform.SetParent(tile.transform);
        dirt.transform.localPosition = new Vector3(0, -0.5f, 0);
        var dirtSr = dirt.AddComponent<SpriteRenderer>();
        dirtSr.sprite = SpriteGenerator.CreateSquareSprite(8);
        dirtSr.color = GameConfig.Colors.GroundDirt;
        dirtSr.sortingOrder = 0;
        dirt.transform.localScale = new Vector3(8.1f, GameConfig.GroundHeight, 1);

        // Grass top
        var grass = new GameObject("Grass");
        grass.transform.SetParent(tile.transform);
        grass.transform.localPosition = new Vector3(0, GameConfig.GroundHeight / 2f - 0.1f, 0);
        var grassSr = grass.AddComponent<SpriteRenderer>();
        grassSr.sprite = SpriteGenerator.CreateSquareSprite(8);
        grassSr.color = GameConfig.Colors.Ground;
        grassSr.sortingOrder = 1;
        grass.transform.localScale = new Vector3(8.1f, 0.25f, 1);

        // Grass tufts
        for (int i = 0; i < 5; i++)
        {
            var tuft = new GameObject("Tuft");
            tuft.transform.SetParent(tile.transform);
            float tx = Random.Range(-3.5f, 3.5f);
            tuft.transform.localPosition = new Vector3(tx, GameConfig.GroundHeight / 2f + 0.02f, 0);
            var tuftSr = tuft.AddComponent<SpriteRenderer>();
            tuftSr.sprite = SpriteGenerator.CreateTriangleSprite(8);
            tuftSr.color = new Color(0.22f, 0.6f, 0.22f);
            tuftSr.sortingOrder = 2;
            tuft.transform.localScale = new Vector3(0.08f, 0.12f, 1);
        }

        return tile;
    }
}
