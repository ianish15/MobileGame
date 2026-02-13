using UnityEngine;
using System.Collections.Generic;

public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance { get; private set; }

    private AudioSource sfxSource;
    private AudioSource musicSource;
    private Dictionary<string, AudioClip> clips = new Dictionary<string, AudioClip>();

    public bool MusicEnabled
    {
        get => PlayerPrefs.GetInt(GameConfig.Keys.MusicEnabled, 1) == 1;
        set { PlayerPrefs.SetInt(GameConfig.Keys.MusicEnabled, value ? 1 : 0); PlayerPrefs.Save(); }
    }

    public bool SoundEnabled
    {
        get => PlayerPrefs.GetInt(GameConfig.Keys.SoundEnabled, 1) == 1;
        set { PlayerPrefs.SetInt(GameConfig.Keys.SoundEnabled, value ? 1 : 0); PlayerPrefs.Save(); }
    }

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);

        sfxSource = gameObject.AddComponent<AudioSource>();
        musicSource = gameObject.AddComponent<AudioSource>();
        musicSource.loop = true;
        musicSource.volume = 0.3f;

        GenerateClips();
    }

    void OnDestroy()
    {
        if (Instance == this) Instance = null;
    }

    void GenerateClips()
    {
        // Generate simple procedural sound effects
        clips["jump"] = GenerateTone(0.1f, 440f, 660f);
        clips["coin"] = GenerateTone(0.08f, 880f, 1100f);
        clips["death"] = GenerateTone(0.3f, 440f, 110f);
        clips["powerUp"] = GenerateTone(0.15f, 440f, 880f);
        clips["shieldHit"] = GenerateTone(0.12f, 330f, 220f);
    }

    AudioClip GenerateTone(float duration, float startFreq, float endFreq)
    {
        int sampleRate = 44100;
        int sampleCount = (int)(sampleRate * duration);
        float[] data = new float[sampleCount];

        for (int i = 0; i < sampleCount; i++)
        {
            float t = (float)i / sampleCount;
            float freq = Mathf.Lerp(startFreq, endFreq, t);
            float amplitude = 1f - t; // fade out
            data[i] = Mathf.Sin(2f * Mathf.PI * freq * ((float)i / sampleRate)) * amplitude * 0.4f;
        }

        var clip = AudioClip.Create("tone", sampleCount, 1, sampleRate, false);
        clip.SetData(data, 0);
        return clip;
    }

    public void PlaySound(string name)
    {
        if (!SoundEnabled) return;
        if (clips.TryGetValue(name, out var clip))
        {
            sfxSource.PlayOneShot(clip);
        }
    }

    public void PlayMusic(AudioClip clip)
    {
        if (!MusicEnabled || clip == null) return;
        musicSource.clip = clip;
        musicSource.Play();
    }

    public void StopMusic()
    {
        musicSource.Stop();
    }
}
