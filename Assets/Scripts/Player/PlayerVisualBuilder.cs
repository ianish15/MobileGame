using UnityEngine;

public static class PlayerVisualBuilder
{
    public static GameObject Build(Transform parent, Color bodyColor)
    {
        // Body
        var body = new GameObject("Body");
        body.transform.SetParent(parent);
        body.transform.localPosition = Vector3.zero;
        var bodySr = body.AddComponent<SpriteRenderer>();
        bodySr.sprite = SpriteGenerator.CreateRoundedSquareSprite(32, 6);
        bodySr.color = bodyColor;
        bodySr.sortingOrder = 10;
        body.transform.localScale = Vector3.one * GameConfig.PlayerSize;

        // Left eye
        var leftEye = new GameObject("LeftEye");
        leftEye.transform.SetParent(body.transform);
        leftEye.transform.localPosition = new Vector3(-0.15f, 0.12f, 0);
        var leftSr = leftEye.AddComponent<SpriteRenderer>();
        leftSr.sprite = SpriteGenerator.CreateCircleSprite(16);
        leftSr.color = Color.white;
        leftSr.sortingOrder = 11;
        leftEye.transform.localScale = Vector3.one * 0.22f;

        // Left pupil
        var leftPupil = new GameObject("LeftPupil");
        leftPupil.transform.SetParent(leftEye.transform);
        leftPupil.transform.localPosition = new Vector3(0.15f, 0, 0);
        var lpSr = leftPupil.AddComponent<SpriteRenderer>();
        lpSr.sprite = SpriteGenerator.CreateCircleSprite(8);
        lpSr.color = Color.black;
        lpSr.sortingOrder = 12;
        leftPupil.transform.localScale = Vector3.one * 0.5f;

        // Right eye
        var rightEye = new GameObject("RightEye");
        rightEye.transform.SetParent(body.transform);
        rightEye.transform.localPosition = new Vector3(0.15f, 0.12f, 0);
        var rightSr = rightEye.AddComponent<SpriteRenderer>();
        rightSr.sprite = SpriteGenerator.CreateCircleSprite(16);
        rightSr.color = Color.white;
        rightSr.sortingOrder = 11;
        rightEye.transform.localScale = Vector3.one * 0.22f;

        // Right pupil
        var rightPupil = new GameObject("RightPupil");
        rightPupil.transform.SetParent(rightEye.transform);
        rightPupil.transform.localPosition = new Vector3(0.15f, 0, 0);
        var rpSr = rightPupil.AddComponent<SpriteRenderer>();
        rpSr.sprite = SpriteGenerator.CreateCircleSprite(8);
        rpSr.color = Color.black;
        rpSr.sortingOrder = 12;
        rightPupil.transform.localScale = Vector3.one * 0.5f;

        // Smile
        var smile = new GameObject("Smile");
        smile.transform.SetParent(body.transform);
        smile.transform.localPosition = new Vector3(0.05f, -0.1f, 0);
        var smileSr = smile.AddComponent<SpriteRenderer>();
        smileSr.sprite = SpriteGenerator.CreateArcSprite(12, 180f, 360f);
        smileSr.color = new Color(0.3f, 0.15f, 0.1f);
        smileSr.sortingOrder = 11;
        smile.transform.localScale = Vector3.one * 0.15f;

        return body;
    }
}
