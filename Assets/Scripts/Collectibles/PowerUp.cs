using UnityEngine;

public class PowerUp : MonoBehaviour
{
    public enum PowerUpType { Shield, Magnet, Multiplier }
    public PowerUpType Type { get; set; }

    private float bobOffset;
    private Vector3 basePosition;

    void Start()
    {
        bobOffset = Random.Range(0f, Mathf.PI * 2f);
        basePosition = transform.position;
    }

    void Update()
    {
        if (GameManager.Instance == null || GameManager.Instance.CurrentState != GameManager.GameState.Playing) return;

        basePosition += Vector3.left * GameManager.Instance.GameSpeed * Time.deltaTime;

        float bob = Mathf.Sin(Time.time * 3f + bobOffset) * 0.15f;
        transform.position = basePosition + Vector3.up * bob;

        // Pulsing scale
        float pulse = 1f + Mathf.Sin(Time.time * 4f) * 0.1f;
        transform.localScale = Vector3.one * 0.3f * pulse;

        if (basePosition.x < GameConfig.DespawnX)
        {
            Destroy(gameObject);
        }
    }
}
