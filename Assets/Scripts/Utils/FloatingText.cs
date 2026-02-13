using UnityEngine;

public class FloatingText : MonoBehaviour
{
    private float speed = 1.5f;
    private float fadeSpeed = 1.5f;

    void Update()
    {
        transform.position += Vector3.up * speed * Time.deltaTime;

        var tm = GetComponent<TextMesh>();
        if (tm != null)
        {
            Color c = tm.color;
            c.a -= fadeSpeed * Time.deltaTime;
            tm.color = c;
        }
    }
}
