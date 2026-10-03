using UnityEngine;

/// <summary>
/// Defines a single wallpaper/texture entry.
/// Supports preloading to eliminate first-tap delay.
/// </summary>
[System.Serializable]
public class WallpaperDefinition
{
    [Tooltip("Display name shown in the UI gallery")]
    public string displayName;

    [Tooltip("Path relative to a Resources folder, no extension")]
    public string resourcePath;

    [Tooltip("How many times the texture tiles across the mesh")]
    public Vector2 tiling = new Vector2(2f, 2f);

    [Tooltip("Optional thumbnail sprite for the gallery UI")]
    public Sprite thumbnail;

    // Cached texture — loaded once, reused forever
    private Texture2D _cachedTexture;

    /// <summary>
    /// Returns cached texture instantly if already loaded.
    /// Otherwise loads from Resources (may cause a brief hitch).
    /// Use PreloadTexture() at startup to avoid this.
    /// </summary>
    public Texture2D LoadTexture()
    {
        if (_cachedTexture != null) return _cachedTexture;

        // 1. Instant fallback: reuse the assigned thumbnail sprite's texture if available
        if (thumbnail != null && thumbnail.texture != null)
        {
            _cachedTexture = thumbnail.texture;
            return _cachedTexture;
        }

        // 2. Load from Resources as Texture2D
        if (!string.IsNullOrEmpty(resourcePath))
        {
            _cachedTexture = Resources.Load<Texture2D>(resourcePath);

            // 3. Fallback: load as Sprite (since imported as Sprite (2D and UI)) and get texture
            if (_cachedTexture == null)
            {
                Sprite spr = Resources.Load<Sprite>(resourcePath);
                if (spr != null)
                    _cachedTexture = spr.texture;
            }
        }

        if (_cachedTexture != null)
        {
            if (_cachedTexture.wrapMode != TextureWrapMode.Repeat)
                _cachedTexture.wrapMode = TextureWrapMode.Repeat;
        }
        else
        {
            Debug.LogWarning($"[Wallpaper] Could not load: {resourcePath}");
        }

        return _cachedTexture;
    }

    /// <summary>
    /// Call this at app startup to preload texture into memory.
    /// Eliminates the first-tap loading hitch completely.
    /// </summary>
    public void PreloadTexture()
    {
        if (_cachedTexture != null) return; // already loaded

        if (thumbnail != null && thumbnail.texture != null)
        {
            _cachedTexture = thumbnail.texture;
        }
        else if (!string.IsNullOrEmpty(resourcePath))
        {
            _cachedTexture = Resources.Load<Texture2D>(resourcePath);
            if (_cachedTexture == null)
            {
                Sprite spr = Resources.Load<Sprite>(resourcePath);
                if (spr != null)
                    _cachedTexture = spr.texture;
            }
        }

        if (_cachedTexture != null)
        {
            if (_cachedTexture.wrapMode != TextureWrapMode.Repeat)
                _cachedTexture.wrapMode = TextureWrapMode.Repeat;

            Debug.Log($"[Wallpaper] Preloaded: {displayName}");
        }
        else
        {
            Debug.LogWarning($"[Wallpaper] Preload failed: {resourcePath}");
        }
    }

    /// <summary>
    /// Returns true if texture is already in memory.
    /// </summary>
    public bool IsPreloaded => _cachedTexture != null;

    public void ReleaseCache()
    {
        _cachedTexture = null;
    }
}