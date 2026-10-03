using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

/// <summary>
/// Manages the wallpaper selection gallery UI and applies
/// chosen textures with tiling to the generated wall mesh.
/// Preloads all textures at startup to eliminate tap delay.
/// </summary>
public class TextureManager : MonoBehaviour
{
    // ── Inspector ─────────────────────────────────────────────
    [Header("Dependencies")]
    [SerializeField] private WallMeshGenerator     _meshGenerator;
    [SerializeField] private PointPlacementManager _placementManager;

    [Header("Animation")]
    [SerializeField] private UIAnimationManager _uiAnimator;

    [Header("Wallpaper Definitions")]
    [SerializeField] private List<WallpaperDefinition> _wallpapers
        = new List<WallpaperDefinition>();

    [Header("UI Panel")]
    [SerializeField] private GameObject      _texturePanel;
    [SerializeField] private Transform       _thumbnailContainer;
    [SerializeField] private GameObject      _thumbnailPrefab;
    [SerializeField] private Button          _closePanelButton;
    [SerializeField] private Button          _openPanelButton;
    [SerializeField] private TextMeshProUGUI _selectedNameText;

    [Header("Tiling Controls")]
    [SerializeField] private Slider          _tilingSlider;
    [SerializeField] private TextMeshProUGUI _tilingValueText;
    [SerializeField] private float           _tilingMin = 0.5f;
    [SerializeField] private float           _tilingMax = 8f;

    // ── Runtime State ─────────────────────────────────────────
    private List<WallpaperThumbnailItem> _thumbnailItems
        = new List<WallpaperThumbnailItem>();

    private WallpaperThumbnailItem _selectedItem;
    private Material               _wallMeshMaterial;
    private Vector2                _currentTiling   = new Vector2(2f, 2f);
    private bool                   _preloadComplete = false;

    // ─────────────────────────────────────────────────────────
    private void Start()
    {
        _texturePanel.SetActive(false);
        _openPanelButton.gameObject.SetActive(false);

        _placementManager.OnGoConfirmed += OnMeshReady;
        _closePanelButton.onClick.AddListener(ClosePanel);
        _openPanelButton.onClick.AddListener(OpenPanel);

        if (_tilingSlider != null)
        {
            _tilingSlider.minValue = _tilingMin;
            _tilingSlider.maxValue = _tilingMax;
            _tilingSlider.value    = 2f;
            _tilingSlider.onValueChanged.AddListener(OnTilingChanged);
        }

        // Adjust EventSystem drag threshold for high-DPI touchscreens (Pixel 7, etc.)
        // so gentle finger taps in ScrollRect are never mistaken for drags
        if (UnityEngine.EventSystems.EventSystem.current != null)
        {
            int adaptiveThreshold = Mathf.Max(30, (int)(Screen.dpi * 0.12f));
            UnityEngine.EventSystems.EventSystem.current.pixelDragThreshold = adaptiveThreshold;
            Debug.Log($"[TextureManager] EventSystem pixelDragThreshold set to: {adaptiveThreshold}");
        }

        BuildThumbnailGallery();

        // Preload all textures in background immediately at startup
        // so every thumbnail tap is instant with zero delay
        StartCoroutine(PreloadAllTexturesAsync());
    }

    private void OnDestroy()
    {
        if (_placementManager != null)
            _placementManager.OnGoConfirmed -= OnMeshReady;

        if (_closePanelButton != null)
            _closePanelButton.onClick.RemoveListener(ClosePanel);

        if (_openPanelButton != null)
            _openPanelButton.onClick.RemoveListener(OpenPanel);
    }

    // ─────────────────────────────────────────────────────────
    #region Preloading

    /// <summary>
    /// Loads one texture per frame in the background.
    /// Spreads the load so startup feels instant — no single
    /// frame does all the disk IO at once.
    /// </summary>
    private IEnumerator PreloadAllTexturesAsync()
    {
        _preloadComplete = false;

        Debug.Log("[TextureManager] Starting texture preload...");

        foreach (WallpaperDefinition def in _wallpapers)
        {
            if (!def.IsPreloaded)
            {
                // Load one texture this frame
                def.PreloadTexture();

                // Yield to next frame so app stays responsive
                yield return null;
            }
        }

        _preloadComplete = true;
        Debug.Log("[TextureManager] All textures preloaded. " +
                  "Thumbnail switching will be instant.");
    }

    #endregion

    // ─────────────────────────────────────────────────────────
    #region Panel Open / Close

    private void OnMeshReady(IReadOnlyList<Vector3> _)
    {
        RefreshMaterialReference();
        _openPanelButton.gameObject.SetActive(true);
        OpenPanel();
    }

    private void RefreshMaterialReference()
    {
        _wallMeshMaterial = _meshGenerator.GetWallMaterial();

        if (_wallMeshMaterial == null)
            Debug.LogWarning("[TextureManager] Material is null " +
                             "after refresh.");
        else
            Debug.Log("[TextureManager] Material refreshed: "
                      + _wallMeshMaterial.name);
    }

    private void OpenPanel()
    {
        if (_uiAnimator != null)
            _uiAnimator.ShowTexturePanel();
        else
            _texturePanel.SetActive(true);

        if (_selectedItem != null)
            ApplyTexture(_selectedItem.Definition);
        else if (_thumbnailItems.Count > 0)
            SelectThumbnail(_thumbnailItems[0]);
    }

    private void ClosePanel()
    {
        if (_uiAnimator != null)
            _uiAnimator.HideTexturePanel();
        else
            _texturePanel.SetActive(false);
    }

    public void OnReset()
    {
        _wallMeshMaterial = null;
        _selectedItem     = null;

        foreach (var item in _thumbnailItems)
            item.SetSelected(false);

        _texturePanel.SetActive(false);
        _openPanelButton.gameObject.SetActive(false);

        if (_tilingSlider != null)
            _tilingSlider.value = 2f;

        if (_selectedNameText != null)
            _selectedNameText.text = "Select a Wallpaper";

        Debug.Log("[TextureManager] Reset complete.");
    }

    #endregion

    // ─────────────────────────────────────────────────────────
    #region Gallery Building

    private void BuildThumbnailGallery()
    {
        foreach (Transform child in _thumbnailContainer)
            Destroy(child.gameObject);

        _thumbnailItems.Clear();

        foreach (WallpaperDefinition def in _wallpapers)
        {
            GameObject go = Instantiate(
                _thumbnailPrefab, _thumbnailContainer);

            WallpaperThumbnailItem item =
                go.GetComponent<WallpaperThumbnailItem>();

            if (item == null)
            {
                Debug.LogError("[TextureManager] Thumbnail prefab " +
                               "missing WallpaperThumbnailItem.");
                continue;
            }

            item.Initialize(def, SelectThumbnail);
            _thumbnailItems.Add(item);
        }
    }

    #endregion

    // ─────────────────────────────────────────────────────────
    #region Texture Application

    private void SelectThumbnail(WallpaperThumbnailItem item)
    {
        if (item == null || item.Definition == null)
        {
            Debug.LogWarning("[TextureManager] SelectThumbnail called with null item or definition.");
            return;
        }

        Debug.Log($"[TextureManager] SelectThumbnail: {item.Definition.displayName}");

        // Deselect previous
        if (_selectedItem != null)
            _selectedItem.SetSelected(false);

        _selectedItem = item;
        _selectedItem.SetSelected(true);

        if (_selectedNameText != null)
            _selectedNameText.text = item.Definition.displayName;

        // Sync tiling slider without firing onValueChanged callback recursively
        _currentTiling = item.Definition.tiling;
        if (_tilingSlider != null)
            _tilingSlider.SetValueWithoutNotify(_currentTiling.x);

        if (_tilingValueText != null)
            _tilingValueText.text = $"{_currentTiling.x:F1}x";

        ApplyTexture(item.Definition);
    }

    private void ApplyTexture(WallpaperDefinition def)
    {
        if (def == null) return;

        // LoadTexture() returns cached version instantly
        // if PreloadTexture() was already called at startup
        Texture2D tex = def.LoadTexture();
        if (tex == null)
        {
            Debug.LogWarning("[TextureManager] Texture not found: " + def.resourcePath);
            return;
        }

        if (_meshGenerator != null)
        {
            _meshGenerator.ApplyWallpaper(tex, _currentTiling);
            _wallMeshMaterial = _meshGenerator.GetWallMaterial();
        }
        else
        {
            Debug.LogWarning("[TextureManager] Cannot apply — _meshGenerator reference is null.");
        }

        Debug.Log($"[TextureManager] Applied '{def.displayName}' ({tex.name}) " +
                  $"| Tiling: {_currentTiling} " +
                  $"| Preloaded: {def.IsPreloaded}");
    }

    /// <summary>
    /// Returns true if the texture gallery panel is currently visible.
    /// </summary>
    public bool IsPanelOpen => _texturePanel != null && _texturePanel.activeSelf;

    public void RequestClosePanel() => ClosePanel();

    private void OnTilingChanged(float value)
    {
        _currentTiling = new Vector2(value, value);

        if (_tilingValueText != null)
            _tilingValueText.text = $"{value:F1}x";

        // Update tiling directly on shader without reassigning sharedMaterial every frame
        if (_meshGenerator != null)
        {
            _meshGenerator.SetTiling(_currentTiling);
        }
        else if (_wallMeshMaterial != null)
        {
            _wallMeshMaterial.mainTextureScale = _currentTiling;
            if (_wallMeshMaterial.HasProperty("_BaseMap"))
                _wallMeshMaterial.SetTextureScale("_BaseMap", _currentTiling);
        }
    }

    #endregion
}