using UnityEngine;
using System;
using System.Collections;

[RequireComponent(typeof(Rigidbody2D), typeof(BoxCollider2D))]
public class PlayerController : MonoBehaviour
{
    public static PlayerController Instance { get; private set; }

    [Header("Components")]
    private Rigidbody2D rb;
    private BoxCollider2D col;

    [Header("Visual")]
    private Transform bodyTransform;
    private Transform eyeLeft;
    private Transform eyeRight;
    private Transform mouth;
    private SpriteRenderer bodyRenderer;

    [Header("State")]
    private int jumpsRemaining;
    private bool isGrounded;
    private bool isSliding;
    private bool isDead;
    private Vector2 touchStartPos;
    private bool hasShield;
    private bool hasMagnet;

    private Vector2 normalColliderSize;
    private Vector2 normalColliderOffset;
    private Vector3 normalScale;

    // Power-up visuals
    private GameObject shieldVisual;
    private GameObject magnetVisual;
    private GameObject multiplierVisual;

    public bool HasShield => hasShield;
    public bool HasMagnet => hasMagnet;

    public event Action OnJump;
    public event Action OnLand;
    public event Action OnDeath;

    void Awake()
    {
        Instance = this;
        rb = GetComponent<Rigidbody2D>();
        col = GetComponent<BoxCollider2D>();
    }

    void OnDestroy()
    {
        if (Instance == this) Instance = null;
    }

    public void Initialize()
    {
        // Setup rigidbody
        rb.gravityScale = 0;
        rb.freezeRotation = true;
        rb.interpolation = RigidbodyInterpolation2D.Interpolate;

        // Store normal collider
        normalColliderSize = col.size;
        normalColliderOffset = col.offset;
        normalScale = transform.localScale;

        isDead = false;
        isGrounded = true;
        isSliding = false;
        jumpsRemaining = GameConfig.MaxJumps;

        // Apply selected skin color
        ApplySkin();
    }

    public void Activate()
    {
        rb.gravityScale = GameConfig.Gravity / Physics2D.gravity.y;
        jumpsRemaining = GameConfig.MaxJumps;
    }

    void Update()
    {
        if (isDead) return;
        if (GameManager.Instance == null || GameManager.Instance.CurrentState != GameManager.GameState.Playing) return;

        HandleInput();
        HandleMagnet();
        AnimateRunning();
    }

    void HandleInput()
    {
        // Keyboard input for PC
        if (Input.GetKeyDown(KeyCode.Space) || Input.GetKeyDown(KeyCode.UpArrow) || Input.GetKeyDown(KeyCode.W))
        {
            TryJump();
        }

        if (Input.GetKeyDown(KeyCode.DownArrow) || Input.GetKeyDown(KeyCode.S))
        {
            TrySlide();
        }

        // Mouse/touch input
        if (Input.GetMouseButtonDown(0))
        {
            touchStartPos = Input.mousePosition;
        }
        if (Input.GetMouseButtonUp(0))
        {
            Vector2 delta = (Vector2)Input.mousePosition - touchStartPos;
            if (delta.y < -30f && Mathf.Abs(delta.y) > Mathf.Abs(delta.x))
            {
                TrySlide();
            }
            else if (delta.magnitude < 30f)
            {
                TryJump();
            }
        }
    }

    void TryJump()
    {
        if (jumpsRemaining <= 0) return;

        jumpsRemaining--;
        isGrounded = false;

        // Reset vertical velocity for consistent jump height
        rb.linearVelocity = new Vector2(rb.linearVelocity.x, 0);
        rb.AddForce(Vector2.up * GameConfig.JumpForce, ForceMode2D.Impulse);

        // Jump squash/stretch
        StartCoroutine(JumpSquash());

        OnJump?.Invoke();
        AudioManager.Instance?.PlaySound("jump");
    }

    void TrySlide()
    {
        if (isSliding || !isGrounded) return;
        StartCoroutine(SlideRoutine());
    }

    IEnumerator SlideRoutine()
    {
        isSliding = true;

        // Squash character
        transform.localScale = new Vector3(normalScale.x * 1.3f, normalScale.y * 0.5f, normalScale.z);
        col.size = new Vector2(normalColliderSize.x * 1.3f, normalColliderSize.y * 0.5f);
        col.offset = new Vector2(normalColliderOffset.x, normalColliderOffset.y - normalColliderSize.y * 0.25f);

        yield return new WaitForSeconds(GameConfig.SlideDuration);

        // Restore
        transform.localScale = normalScale;
        col.size = normalColliderSize;
        col.offset = normalColliderOffset;
        isSliding = false;
    }

    IEnumerator JumpSquash()
    {
        // Stretch on jump
        Vector3 stretched = new Vector3(normalScale.x * 0.85f, normalScale.y * 1.15f, normalScale.z);
        transform.localScale = stretched;
        yield return new WaitForSeconds(0.1f);
        if (!isSliding)
            transform.localScale = normalScale;
    }

    void AnimateRunning()
    {
        if (!isGrounded || isSliding) return;

        float t = Mathf.PingPong(Time.time * 8f, 1f);
        float scaleY = Mathf.Lerp(0.92f, 1.05f, t);
        float scaleX = Mathf.Lerp(1.05f, 0.95f, t);
        transform.localScale = new Vector3(normalScale.x * scaleX, normalScale.y * scaleY, normalScale.z);
    }

    void HandleMagnet()
    {
        if (!hasMagnet) return;

        Coin[] coins = FindObjectsByType<Coin>(FindObjectsSortMode.None);
        foreach (var coin in coins)
        {
            float dist = Vector2.Distance(transform.position, coin.transform.position);
            if (dist < GameConfig.MagnetRange)
            {
                Vector3 dir = (transform.position - coin.transform.position).normalized;
                coin.transform.position += dir * GameConfig.MagnetPullStrength * Time.deltaTime;
            }
        }
    }

    void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.gameObject.CompareTag("Ground"))
        {
            isGrounded = true;
            jumpsRemaining = GameConfig.MaxJumps;

            if (!isSliding)
                transform.localScale = normalScale;

            // Landing squash
            StartCoroutine(LandSquash());
            OnLand?.Invoke();
        }
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (isDead) return;

        if (other.CompareTag("Obstacle"))
        {
            if (hasShield)
            {
                ConsumeShield();
                Destroy(other.gameObject);
                AudioManager.Instance?.PlaySound("shieldHit");
            }
            else
            {
                Die();
            }
        }
        else if (other.CompareTag("Coin"))
        {
            CollectCoin(other.gameObject);
        }
        else if (other.CompareTag("PowerUp"))
        {
            CollectPowerUp(other.gameObject);
        }
    }

    void CollectCoin(GameObject coinObj)
    {
        ScoreManager.Instance?.CollectCoin();
        SpawnCoinParticles(coinObj.transform.position);
        SpawnFloatingText(coinObj.transform.position, "+" + (GameConfig.CoinPointValue * (ScoreManager.Instance?.ScoreMultiplier ?? 1)));
        AudioManager.Instance?.PlaySound("coin");
        Destroy(coinObj);
    }

    void CollectPowerUp(GameObject powerUpObj)
    {
        var powerUp = powerUpObj.GetComponent<PowerUp>();
        if (powerUp == null) { Destroy(powerUpObj); return; }

        switch (powerUp.Type)
        {
            case PowerUp.PowerUpType.Shield:
                ActivateShield();
                break;
            case PowerUp.PowerUpType.Magnet:
                ActivateMagnet();
                break;
            case PowerUp.PowerUpType.Multiplier:
                ActivateMultiplier();
                break;
        }

        AudioManager.Instance?.PlaySound("powerUp");
        Destroy(powerUpObj);
    }

    void ActivateShield()
    {
        hasShield = true;
        if (shieldVisual != null) Destroy(shieldVisual);
        shieldVisual = CreatePowerUpVisual(GameConfig.Colors.Shield, 0.8f);
        StartCoroutine(PowerUpTimer(GameConfig.ShieldDuration, () => {
            hasShield = false;
            if (shieldVisual != null) Destroy(shieldVisual);
        }, shieldVisual));
    }

    void ActivateMagnet()
    {
        hasMagnet = true;
        if (magnetVisual != null) Destroy(magnetVisual);
        magnetVisual = CreatePowerUpVisual(GameConfig.Colors.Magnet, 1f);
        StartCoroutine(PowerUpTimer(GameConfig.MagnetDuration, () => {
            hasMagnet = false;
            if (magnetVisual != null) Destroy(magnetVisual);
        }, magnetVisual));
    }

    void ActivateMultiplier()
    {
        if (ScoreManager.Instance != null) ScoreManager.Instance.ScoreMultiplier = 2;
        if (multiplierVisual != null) Destroy(multiplierVisual);
        multiplierVisual = CreateMultiplierVisual();
        StartCoroutine(PowerUpTimer(GameConfig.MultiplierDuration, () => {
            if (ScoreManager.Instance != null) ScoreManager.Instance.ScoreMultiplier = 1;
            if (multiplierVisual != null) Destroy(multiplierVisual);
        }, multiplierVisual));
    }

    IEnumerator PowerUpTimer(float duration, Action onExpire, GameObject visual)
    {
        float elapsed = 0;
        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;

            // Flash warning near end
            if (elapsed > duration - 1.5f && visual != null)
            {
                var sr = visual.GetComponent<SpriteRenderer>();
                if (sr != null)
                    sr.color = new Color(sr.color.r, sr.color.g, sr.color.b, Mathf.PingPong(Time.time * 6f, 0.6f) + 0.2f);
            }

            yield return null;
        }
        onExpire?.Invoke();
    }

    void ConsumeShield()
    {
        hasShield = false;
        if (shieldVisual != null) Destroy(shieldVisual);

        // Flash effect
        StartCoroutine(FlashEffect());
    }

    IEnumerator FlashEffect()
    {
        var sr = GetComponentInChildren<SpriteRenderer>();
        if (sr == null) yield break;
        Color orig = sr.color;
        for (int i = 0; i < 3; i++)
        {
            sr.color = Color.white;
            yield return new WaitForSeconds(0.05f);
            sr.color = orig;
            yield return new WaitForSeconds(0.05f);
        }
    }

    void Die()
    {
        isDead = true;
        AudioManager.Instance?.PlaySound("death");
        OnDeath?.Invoke();

        // Death animation
        StartCoroutine(DeathAnimation());
    }

    IEnumerator DeathAnimation()
    {
        rb.linearVelocity = Vector2.zero;
        rb.AddForce(new Vector2(-2f, 8f), ForceMode2D.Impulse);
        rb.freezeRotation = false;
        rb.angularVelocity = 720f;

        var sr = GetComponentInChildren<SpriteRenderer>();
        float t = 0;
        while (t < 1f)
        {
            t += Time.deltaTime;
            if (sr != null)
                sr.color = new Color(sr.color.r, sr.color.g, sr.color.b, 1f - t);
            yield return null;
        }

        yield return new WaitForSeconds(0.3f);
        GameManager.Instance?.TriggerGameOver();
    }

    IEnumerator LandSquash()
    {
        transform.localScale = new Vector3(normalScale.x * 1.15f, normalScale.y * 0.85f, normalScale.z);
        yield return new WaitForSeconds(0.08f);
        if (!isSliding)
            transform.localScale = normalScale;
    }

    GameObject CreatePowerUpVisual(Color color, float size)
    {
        var go = new GameObject("PowerUpVisual");
        go.transform.SetParent(transform);
        go.transform.localPosition = Vector3.zero;

        var sr = go.AddComponent<SpriteRenderer>();
        sr.sprite = SpriteGenerator.CreateCircleSprite(32);
        sr.color = new Color(color.r, color.g, color.b, 0.3f);
        sr.sortingOrder = 9;
        go.transform.localScale = Vector3.one * size;

        return go;
    }

    GameObject CreateMultiplierVisual()
    {
        var go = new GameObject("MultiplierVisual");
        go.transform.SetParent(transform);
        go.transform.localPosition = new Vector3(0, 0.5f, 0);

        var textObj = new GameObject("x2Text");
        textObj.transform.SetParent(go.transform);
        textObj.transform.localPosition = Vector3.zero;

        var tm = textObj.AddComponent<TextMesh>();
        tm.text = "x2";
        tm.fontSize = 32;
        tm.characterSize = 0.1f;
        tm.anchor = TextAnchor.MiddleCenter;
        tm.alignment = TextAlignment.Center;
        tm.color = GameConfig.Colors.Multiplier;

        var mr = textObj.GetComponent<MeshRenderer>();
        mr.sortingOrder = 15;

        return go;
    }

    void SpawnCoinParticles(Vector3 pos)
    {
        for (int i = 0; i < 6; i++)
        {
            var particle = new GameObject("CoinParticle");
            particle.transform.position = pos;
            var sr = particle.AddComponent<SpriteRenderer>();
            sr.sprite = SpriteGenerator.CreateSquareSprite(4);
            sr.color = GameConfig.Colors.CoinGold;
            sr.sortingOrder = 15;
            particle.transform.localScale = Vector3.one * 0.1f;

            var rb2 = particle.AddComponent<Rigidbody2D>();
            rb2.gravityScale = 2f;
            Vector2 dir = new Vector2(Random.Range(-2f, 2f), Random.Range(2f, 5f));
            rb2.AddForce(dir, ForceMode2D.Impulse);

            Destroy(particle, 0.5f);
        }
    }

    void SpawnFloatingText(Vector3 pos, string text)
    {
        var go = new GameObject("FloatingText");
        go.transform.position = pos + Vector3.up * 0.3f;
        var tm = go.AddComponent<TextMesh>();
        tm.text = text;
        tm.fontSize = 28;
        tm.characterSize = 0.08f;
        tm.anchor = TextAnchor.MiddleCenter;
        tm.color = GameConfig.Colors.CoinGold;

        var mr = go.GetComponent<MeshRenderer>();
        mr.sortingOrder = 20;

        go.AddComponent<FloatingText>();
        Destroy(go, 0.8f);
    }

    void ApplySkin()
    {
        string selected = ScoreManager.Instance?.SelectedSkin ?? "Classic";
        Color skinColor = GameConfig.Colors.Player;
        foreach (var skin in GameConfig.Skins)
        {
            if (skin.name == selected)
            {
                skinColor = skin.color;
                break;
            }
        }

        var sr = GetComponentInChildren<SpriteRenderer>();
        if (sr != null) sr.color = skinColor;
    }
}
