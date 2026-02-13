using UnityEngine;
using System;

public class ScoreManager : MonoBehaviour
{
    public static ScoreManager Instance { get; private set; }

    public int CurrentScore { get; private set; }
    public int CoinsCollectedThisRun { get; private set; }
    public int ScoreMultiplier { get; set; } = 1;

    public int HighScore
    {
        get => PlayerPrefs.GetInt(GameConfig.Keys.HighScore, 0);
        private set => PlayerPrefs.SetInt(GameConfig.Keys.HighScore, value);
    }

    public int TotalCoins
    {
        get => PlayerPrefs.GetInt(GameConfig.Keys.TotalCoins, 0);
        private set { PlayerPrefs.SetInt(GameConfig.Keys.TotalCoins, value); PlayerPrefs.Save(); }
    }

    public int GamesPlayed
    {
        get => PlayerPrefs.GetInt(GameConfig.Keys.GamesPlayed, 0);
        private set => PlayerPrefs.SetInt(GameConfig.Keys.GamesPlayed, value);
    }

    public string SelectedSkin
    {
        get => PlayerPrefs.GetString(GameConfig.Keys.SelectedSkin, "Classic");
        set { PlayerPrefs.SetString(GameConfig.Keys.SelectedSkin, value); PlayerPrefs.Save(); }
    }

    public event Action<int> OnScoreChanged;
    public event Action<int> OnCoinsChanged;

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

    public void ResetRun()
    {
        CurrentScore = 0;
        CoinsCollectedThisRun = 0;
        ScoreMultiplier = 1;
        OnScoreChanged?.Invoke(CurrentScore);
        OnCoinsChanged?.Invoke(TotalCoins);
    }

    public void AddScore(int points)
    {
        CurrentScore += points * ScoreMultiplier;
        OnScoreChanged?.Invoke(CurrentScore);
    }

    public void CollectCoin()
    {
        AddScore(GameConfig.CoinPointValue);
        CoinsCollectedThisRun += GameConfig.CoinCurrencyValue;
        TotalCoins += GameConfig.CoinCurrencyValue;
        OnCoinsChanged?.Invoke(TotalCoins);
    }

    public bool SubmitScore()
    {
        bool isNewBest = CurrentScore > HighScore;
        if (isNewBest)
        {
            HighScore = CurrentScore;
            PlayerPrefs.Save();
        }
        return isNewBest;
    }

    public bool SpendCoins(int amount)
    {
        if (TotalCoins < amount) return false;
        TotalCoins -= amount;
        OnCoinsChanged?.Invoke(TotalCoins);
        return true;
    }

    public void AddCoins(int amount)
    {
        TotalCoins += amount;
        OnCoinsChanged?.Invoke(TotalCoins);
    }

    public void IncrementGamesPlayed()
    {
        GamesPlayed++;
        PlayerPrefs.Save();
    }

    public bool IsSkinUnlocked(string skinName)
    {
        if (skinName == "Classic") return true;
        string unlocked = PlayerPrefs.GetString(GameConfig.Keys.UnlockedSkins, "Classic");
        return unlocked.Contains(skinName);
    }

    public void UnlockSkin(string skinName)
    {
        string unlocked = PlayerPrefs.GetString(GameConfig.Keys.UnlockedSkins, "Classic");
        if (!unlocked.Contains(skinName))
        {
            unlocked += "," + skinName;
            PlayerPrefs.SetString(GameConfig.Keys.UnlockedSkins, unlocked);
            PlayerPrefs.Save();
        }
    }

    public string FormatScore(int score)
    {
        return score.ToString("N0");
    }
}
