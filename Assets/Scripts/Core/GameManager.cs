using UnityEngine;
using UnityEngine.SceneManagement;
using System;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    public enum GameState { Menu, Playing, Paused, GameOver }
    public GameState CurrentState { get; private set; } = GameState.Menu;

    public float GameSpeed { get; private set; }
    public float Difficulty => Mathf.Clamp01((GameSpeed - GameConfig.InitialSpeed) / (GameConfig.MaxSpeed - GameConfig.InitialSpeed));

    public event Action OnGameStart;
    public event Action OnGameOver;
    public event Action<GameState> OnStateChanged;

    private int frameCount;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
    }

    void OnDestroy()
    {
        if (Instance == this) Instance = null;
    }

    public void StartGame()
    {
        CurrentState = GameState.Playing;
        GameSpeed = GameConfig.InitialSpeed;
        frameCount = 0;
        ScoreManager.Instance?.IncrementGamesPlayed();
        OnGameStart?.Invoke();
        OnStateChanged?.Invoke(CurrentState);
    }

    public void TriggerGameOver()
    {
        if (CurrentState != GameState.Playing) return;
        CurrentState = GameState.GameOver;
        OnGameOver?.Invoke();
        OnStateChanged?.Invoke(CurrentState);
    }

    void Update()
    {
        if (CurrentState != GameState.Playing) return;

        // Increase speed over time
        GameSpeed = Mathf.Min(GameSpeed + GameConfig.SpeedIncrement * Time.deltaTime * 60f, GameConfig.MaxSpeed);

        // Award score over time
        frameCount++;
        if (frameCount >= GameConfig.FramePointInterval)
        {
            frameCount = 0;
            ScoreManager.Instance?.AddScore(1);
        }
    }

    public void LoadScene(string sceneName)
    {
        SceneManager.LoadScene(sceneName);
    }
}
