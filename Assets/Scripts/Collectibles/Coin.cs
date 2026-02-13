using UnityEngine;

public class Coin : MonoBehaviour
{
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

        // Move left with game speed
        basePosition += Vector3.left * GameManager.Instance.GameSpeed * Time.deltaTime;

        // Bob up and down
        float bob = Mathf.Sin(Time.time * 4f + bobOffset) * 0.1f;
        transform.position = basePosition + Vector3.up * bob;

        // Spin the star inside
        Transform star = transform.Find("Star");
        if (star != null)
            star.Rotate(0, 0, 180f * Time.deltaTime);

        if (basePosition.x < GameConfig.DespawnX)
        {
            Destroy(gameObject);
        }
    }
}
