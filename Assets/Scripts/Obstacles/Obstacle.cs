using UnityEngine;

public class Obstacle : MonoBehaviour
{
    public enum ObstacleType { Spike, DoubleTallSpike, Barrier }
    public ObstacleType Type { get; set; }

    void Update()
    {
        if (GameManager.Instance == null || GameManager.Instance.CurrentState != GameManager.GameState.Playing) return;

        transform.position += Vector3.left * GameManager.Instance.GameSpeed * Time.deltaTime;

        if (transform.position.x < GameConfig.DespawnX)
        {
            Destroy(gameObject);
        }
    }
}
