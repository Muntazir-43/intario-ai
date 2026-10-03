using System;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

/// <summary>
/// Provides exit / return navigation from the Unity AR Wall Decor experience back to Intario AI.
/// - Adds a clean, minimalist back button at the top-left of the Canvas.
/// - Handles Android hardware / gesture Back button (KeyCode.Escape).
/// - Gracefully finishes the Android Activity to restore Intario AI's Premium AR screen.
/// </summary>
public class ARExitController : MonoBehaviour
{
    private static ARExitController _instance;

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    private static void AutoInitialize()
    {
        if (_instance == null)
        {
            GameObject managerObj = new GameObject("[ARExitManager]");
            _instance = managerObj.AddComponent<ARExitController>();
            DontDestroyOnLoad(managerObj);
        }
    }

    private void Awake()
    {
        if (_instance != null && _instance != this)
        {
            Destroy(gameObject);
            return;
        }
        _instance = this;
    }

    private void Start()
    {
        EnsureBackButtonExists();
    }

    private void Update()
    {
        // Android Back button or gesture sends KeyCode.Escape
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            ExitAR();
        }
    }

    /// <summary>
    /// Checks for or creates a minimalist, elegant back button in the UI Canvas.
    /// </summary>
    public void EnsureBackButtonExists()
    {
        Canvas canvas = FindAnyObjectByType<Canvas>();
        if (canvas == null)
        {
            Debug.LogWarning("[ARExitController] No Canvas found in scene.");
            return;
        }

        Transform existingBtn = canvas.transform.Find("ARBackButton");
        if (existingBtn != null)
        {
            Button btn = existingBtn.GetComponent<Button>();
            if (btn != null)
            {
                btn.onClick.RemoveListener(ExitAR);
                btn.onClick.AddListener(ExitAR);
            }
            return;
        }

        // Create Button GameObject
        GameObject btnObj = new GameObject("ARBackButton", typeof(RectTransform), typeof(CanvasRenderer), typeof(Image), typeof(Button));
        btnObj.transform.SetParent(canvas.transform, false);

        RectTransform rt = btnObj.GetComponent<RectTransform>();
        rt.anchorMin = new Vector2(0f, 1f);
        rt.anchorMax = new Vector2(0f, 1f);
        rt.pivot     = new Vector2(0f, 1f);
        rt.anchoredPosition = new Vector2(32f, -115f);
        rt.sizeDelta        = new Vector2(84f, 84f);

        // Styling: Sleek dark glass rounded circle
        Image img = btnObj.GetComponent<Image>();
        img.color = new Color(0.12f, 0.12f, 0.12f, 0.88f);
        
        // Borrow existing UI sprite if available
        Image[] existingImages = canvas.GetComponentsInChildren<Image>(true);
        foreach (var exImg in existingImages)
        {
            if (exImg.sprite != null && exImg.gameObject != btnObj)
            {
                img.sprite = exImg.sprite;
                img.type = Image.Type.Sliced;
                break;
            }
        }

        Button button = btnObj.GetComponent<Button>();
        ColorBlock colors = button.colors;
        colors.normalColor      = Color.white;
        colors.highlightedColor = new Color(0.9f, 0.9f, 0.9f, 1f);
        colors.pressedColor     = new Color(0.7f, 0.7f, 0.7f, 1f);
        button.colors = colors;
        button.onClick.AddListener(ExitAR);

        // Child Arrow Icon
        GameObject textObj = new GameObject("ArrowText", typeof(RectTransform), typeof(CanvasRenderer), typeof(TextMeshProUGUI));
        textObj.transform.SetParent(btnObj.transform, false);

        RectTransform textRt = textObj.GetComponent<RectTransform>();
        textRt.anchorMin = Vector2.zero;
        textRt.anchorMax = Vector2.one;
        textRt.sizeDelta = Vector2.zero;
        textRt.anchoredPosition = new Vector2(0f, 2f);

        TextMeshProUGUI tmp = textObj.GetComponent<TextMeshProUGUI>();
        tmp.text = "←";
        tmp.fontSize = 46f;
        tmp.alignment = TextAlignmentOptions.Center;
        tmp.color = Color.white;
        tmp.raycastTarget = false;

        // Borrow TMP font asset from existing scene TMP text
        TextMeshProUGUI existingTmp = canvas.GetComponentInChildren<TextMeshProUGUI>(true);
        if (existingTmp != null && existingTmp.font != null)
        {
            tmp.font = existingTmp.font;
            tmp.fontSharedMaterial = existingTmp.fontSharedMaterial;
        }

        Debug.Log("[ARExitController] Created ARBackButton in Canvas.");
    }

    /// <summary>
    /// Exits the Unity AR experience and returns to Intario AI.
    /// </summary>
    public void ExitAR()
    {
        Debug.Log("[ARExitController] Exiting AR experience, returning to Intario AI...");

#if UNITY_ANDROID && !UNITY_EDITOR
        try
        {
            using (AndroidJavaClass unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
            {
                AndroidJavaObject activity = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity");
                if (activity != null)
                {
                    activity.Call("finish");
                    return;
                }
            }
        }
        catch (Exception ex)
        {
            Debug.LogWarning("[ARExitController] Exception calling finish() on Android activity: " + ex.Message);
        }
#endif

        Application.Quit();
    }
}
