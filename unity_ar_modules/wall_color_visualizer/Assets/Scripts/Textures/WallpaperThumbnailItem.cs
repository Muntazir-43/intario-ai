using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using TMPro;

/// <summary>
/// Controls a single thumbnail button in the wallpaper gallery.
/// Highlights when selected and notifies the TextureManager on click.
/// Implements IPointerDownHandler, IPointerUpHandler, and IPointerClickHandler
/// to trigger selection instantly on the very first touch down.
/// </summary>
public class WallpaperThumbnailItem : MonoBehaviour, IPointerClickHandler
{
    [Header("UI References")]
    [SerializeField] private Button          _button;
    [SerializeField] private Image           _thumbnailImage;
    [SerializeField] private Image           _selectionBorder;
    [SerializeField] private Image           _backgroundPanel;
    [SerializeField] private TextMeshProUGUI _nameLabel;

    [Header("Colors")]
    [SerializeField] private Color _selectedColor   = new Color(0.22f, 0.78f, 0.42f, 1f);
    [SerializeField] private Color _deselectedColor = new Color(0.15f, 0.15f, 0.15f, 0.85f);

    private System.Action<WallpaperThumbnailItem> _onSelected;
    private WallpaperDefinition _definition;
    private bool   _isSelected;
    private int    _lastClickFrame = -1;
    private Sprite _generatedSprite;

    public WallpaperDefinition Definition => _definition;

    // ─────────────────────────────────────────────────────────
    public void Initialize(
        WallpaperDefinition def,
        System.Action<WallpaperThumbnailItem> onSelected)
    {
        _definition = def;
        _onSelected = onSelected;

        // Auto-hook Button if not assigned
        if (_button == null)
            _button = GetComponent<Button>();

        // Set label
        if (_nameLabel != null)
            _nameLabel.text = def.displayName;

        // Destroy any previously generated runtime sprite to prevent native memory leak
        if (_generatedSprite != null)
        {
            Destroy(_generatedSprite);
            _generatedSprite = null;
        }

        // Set thumbnail image
        if (_thumbnailImage != null)
        {
            if (def.thumbnail != null)
            {
                // Use assigned sprite directly
                _thumbnailImage.sprite         = def.thumbnail;
                _thumbnailImage.color          = Color.white;
                _thumbnailImage.preserveAspect = true;
            }
            else
            {
                // No sprite assigned — load texture and convert to sprite
                Texture2D tex = def.LoadTexture();
                if (tex != null)
                {
                    _generatedSprite = Sprite.Create(
                        tex,
                        new Rect(0, 0, tex.width, tex.height),
                        new Vector2(0.5f, 0.5f)
                    );
                    _thumbnailImage.sprite         = _generatedSprite;
                    _thumbnailImage.color          = Color.white;
                    _thumbnailImage.preserveAspect = true;
                }
                else if (_backgroundPanel != null)
                {
                    _backgroundPanel.color = GeneratePlaceholderColor(def.displayName);
                }
            }
        }

        // Disable automatic keyboard navigation focus lock
        if (_button != null)
        {
            var nav = _button.navigation;
            nav.mode = Navigation.Mode.None;
            _button.navigation = nav;

            _button.onClick.RemoveListener(TriggerSelection);
            _button.onClick.AddListener(TriggerSelection);
        }

        SetSelected(false);
    }

    /// <summary>
    /// Click handler that permits normal ScrollRect dragging without accidental trigger on touch down.
    /// </summary>
    public void OnPointerClick(PointerEventData eventData)
    {
        if (eventData.dragging) return;
        TriggerSelection();
    }

    private void TriggerSelection()
    {
        // Debounce so same-frame pointer events don't duplicate
        if (Time.frameCount == _lastClickFrame) return;
        _lastClickFrame = Time.frameCount;

        Debug.Log($"[WallpaperThumbnailItem] Selected: {_definition?.displayName}");
        _onSelected?.Invoke(this);
    }

    public void SetSelected(bool selected)
    {
        _isSelected = selected;

        if (_selectionBorder != null)
            _selectionBorder.gameObject.SetActive(selected);

        if (_backgroundPanel != null)
        {
            _backgroundPanel.color = selected
                ? _selectedColor
                : _deselectedColor;
        }
    }

    // Generates a deterministic color from a string
    // so each wallpaper always gets the same placeholder tint
    private Color GeneratePlaceholderColor(string seed)
    {
        Random.State prevState = Random.state;
        Random.InitState(seed.GetHashCode());
        Color c = Color.HSVToRGB(Random.value, 0.4f, 0.75f);
        Random.state = prevState;
        return new Color(c.r, c.g, c.b, 0.85f);
    }

    private void OnDestroy()
    {
        if (_button != null)
            _button.onClick.RemoveListener(TriggerSelection);

        if (_generatedSprite != null)
        {
            Destroy(_generatedSprite);
            _generatedSprite = null;
        }
    }
}