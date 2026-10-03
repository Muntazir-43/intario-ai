using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

/// <summary>
/// Handles all UI animations:
/// - Panel slide in/out transitions
/// - Button scale bounce on press
/// - Fade in/out for overlays
/// - Go button pulse animation
/// </summary>
public class UIAnimationManager : MonoBehaviour
{
    // ── Inspector ─────────────────────────────────────────────
    [Header("Panels")]
    [SerializeField] private RectTransform _texturePanelRect;
    [SerializeField] private RectTransform _buttonPanelRect;
    [SerializeField] private CanvasGroup   _texturePanelGroup;
    [SerializeField] private CanvasGroup   _buttonPanelGroup;

    [Header("Buttons")]
    [SerializeField] private Button          _goButton;
    [SerializeField] private Button          _placeButton;
    [SerializeField] private CanvasGroup     _goButtonGroup;

    [Header("Animation Settings")]
    [SerializeField] private float _panelSlideDuration  = 0.35f;
    [SerializeField] private float _fadeDuration        = 0.25f;
    [SerializeField] private float _bounceDuration      = 0.15f;
    [SerializeField] private float _pulseDuration       = 1.20f;

    // ── Private ───────────────────────────────────────────────
    private Vector2 _texturePanelShownPos;
    private Vector2 _texturePanelHiddenPos;
    private Coroutine _pulseCoroutine;
    private Coroutine _slideCoroutine;

    // ── Easing Curves ─────────────────────────────────────────
    private static readonly AnimationCurve _easeOut = new AnimationCurve(
        new Keyframe(0f, 0f, 0f, 2f),
        new Keyframe(1f, 1f, 0f, 0f)
    );

    private static readonly AnimationCurve _bounce = new AnimationCurve(
        new Keyframe(0.0f, 1.0f),
        new Keyframe(0.3f, 0.85f),
        new Keyframe(0.6f, 1.08f),
        new Keyframe(1.0f, 1.0f)
    );

    // ─────────────────────────────────────────────────────────
    private void Awake()
    {
        // Cache panel positions
        if (_texturePanelRect != null)
        {
            _texturePanelShownPos  = _texturePanelRect.anchoredPosition;
            _texturePanelHiddenPos = _texturePanelShownPos
                - new Vector2(0, _texturePanelRect.rect.height + 50f);
        }

        // Ensure CanvasGroups exist
        EnsureCanvasGroup(ref _texturePanelGroup, _texturePanelRect);
        EnsureCanvasGroup(ref _goButtonGroup,
            _goButton?.GetComponent<RectTransform>());
    }

    private void Start()
    {
        // Wire button press animations
        if (_placeButton != null)
            _placeButton.onClick.AddListener(
                () => StartCoroutine(BounceButton(_placeButton)));

        if (_goButton != null)
            _goButton.onClick.AddListener(
                () => StartCoroutine(BounceButton(_goButton)));
    }

    // ─────────────────────────────────────────────────────────
    #region Panel Slide Animations

    /// <summary>
    /// Slides the texture panel up from bottom with ease-out.
    /// </summary>
    public void ShowTexturePanel()
    {
        if (_slideCoroutine != null)
            StopCoroutine(_slideCoroutine);

        _slideCoroutine = StartCoroutine(
            SlidePanel(_texturePanelRect,
                       _texturePanelGroup,
                       _texturePanelHiddenPos,
                       _texturePanelShownPos,
                       true)
        );
    }

    /// <summary>
    /// Slides the texture panel down off screen.
    /// </summary>
    public void HideTexturePanel()
    {
        if (_slideCoroutine != null)
            StopCoroutine(_slideCoroutine);

        _slideCoroutine = StartCoroutine(
            SlidePanel(_texturePanelRect,
                       _texturePanelGroup,
                       _texturePanelShownPos,
                       _texturePanelHiddenPos,
                       false)
        );
    }

    private IEnumerator SlidePanel(
        RectTransform rect,
        CanvasGroup   group,
        Vector2       from,
        Vector2       to,
        bool          fadingIn)
    {
        if (rect == null) yield break;

        rect.gameObject.SetActive(true);
        float elapsed = 0f;

        float startAlpha = fadingIn ? 0f : 1f;
        float endAlpha   = fadingIn ? 1f : 0f;

        while (elapsed < _panelSlideDuration)
        {
            elapsed += Time.deltaTime;
            float t = Mathf.Clamp01(elapsed / _panelSlideDuration);
            float e = _easeOut.Evaluate(t);

            rect.anchoredPosition = Vector2.Lerp(from, to, e);

            if (group != null)
                group.alpha = Mathf.Lerp(startAlpha, endAlpha, t);

            yield return null;
        }

        rect.anchoredPosition = to;

        if (group != null) group.alpha = endAlpha;
        if (!fadingIn) rect.gameObject.SetActive(false);
    }

    #endregion

    // ─────────────────────────────────────────────────────────
    #region Button Animations

    /// <summary>
    /// Plays a satisfying bounce scale when a button is pressed.
    /// </summary>
    public IEnumerator BounceButton(Button btn)
    {
        if (btn == null) yield break;

        RectTransform rt     = btn.GetComponent<RectTransform>();
        Vector3       origin = rt.localScale;
        float         elapsed = 0f;

        while (elapsed < _bounceDuration)
        {
            elapsed += Time.deltaTime;
            float t = Mathf.Clamp01(elapsed / _bounceDuration);
            rt.localScale = origin * _bounce.Evaluate(t);
            yield return null;
        }

        rt.localScale = origin;
    }

    /// <summary>
    /// Continuously pulses the GO button scale to draw attention.
    /// Stops automatically when GO is pressed.
    /// </summary>
    private IEnumerator PulseGoButton()
    {
        if (_goButton == null) yield break;

        RectTransform rt     = _goButton.GetComponent<RectTransform>();
        Vector3       origin = rt.localScale;

        while (true)
        {
            // Pulse out
            yield return ScaleTo(rt, origin, origin * 1.08f,
                                 _pulseDuration * 0.5f);
            // Pulse in
            yield return ScaleTo(rt, origin * 1.08f, origin,
                                 _pulseDuration * 0.5f);

            // Brief pause between pulses
            yield return new WaitForSeconds(0.8f);
        }
    }

    private IEnumerator ScaleTo(
        RectTransform rt,
        Vector3 from,
        Vector3 to,
        float duration)
    {
        float elapsed = 0f;
        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = Mathf.Clamp01(elapsed / duration);
            rt.localScale = Vector3.Lerp(from, to, _easeOut.Evaluate(t));
            yield return null;
        }
        rt.localScale = to;
    }

    /// <summary>
    /// Starts pulsing the GO button when it becomes active.
    /// </summary>
    public void StartGoButtonPulse()
    {
        if (_pulseCoroutine != null) return;
        if (_goButton != null && _goButton.gameObject.activeInHierarchy)
            _pulseCoroutine = StartCoroutine(PulseGoButton());
    }

    /// <summary>
    /// Call this when GO is pressed or reset to stop the pulse.
    /// </summary>
    public void StopGoButtonPulse()
    {
        if (_pulseCoroutine != null)
        {
            StopCoroutine(_pulseCoroutine);
            _pulseCoroutine = null;
        }

        if (_goButton != null)
            _goButton.GetComponent<RectTransform>().localScale
                = Vector3.one;
    }

    #endregion

    // ─────────────────────────────────────────────────────────
    #region Fade Helpers

    public IEnumerator FadeCanvasGroup(
        CanvasGroup group,
        float from,
        float to,
        float duration)
    {
        if (group == null) yield break;

        float elapsed = 0f;
        group.alpha = from;

        while (elapsed < duration)
        {
            elapsed  += Time.deltaTime;
            group.alpha = Mathf.Lerp(from, to,
                          Mathf.Clamp01(elapsed / duration));
            yield return null;
        }

        group.alpha = to;
    }

    #endregion

    // ─────────────────────────────────────────────────────────
    #region Utility

    private void EnsureCanvasGroup(
        ref CanvasGroup group,
        RectTransform   target)
    {
        if (group != null || target == null) return;
        group = target.gameObject.GetComponent<CanvasGroup>()
             ?? target.gameObject.AddComponent<CanvasGroup>();
    }

    #endregion

    private void OnDestroy()
    {
        StopGoButtonPulse();
    }
}