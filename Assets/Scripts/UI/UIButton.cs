using UnityEngine;
using System;

public class UIButton : MonoBehaviour
{
    public Action OnClick;
    private Vector3 originalScale;
    private bool isPressed;

    void Start()
    {
        originalScale = transform.localScale;
    }

    void OnMouseDown()
    {
        isPressed = true;
        transform.localScale = originalScale * 0.92f;
    }

    void OnMouseUp()
    {
        if (isPressed)
        {
            transform.localScale = originalScale;
            OnClick?.Invoke();
        }
        isPressed = false;
    }

    void OnMouseExit()
    {
        if (isPressed)
        {
            transform.localScale = originalScale;
            isPressed = false;
        }
    }
}
