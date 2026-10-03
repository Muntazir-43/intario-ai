using UnityEngine;

/// <summary>
/// Plain data container describing one selectable wall decoration.
/// One of these is authored per entry in DecorCollectionUI's "Items" list
/// (Unity Inspector: expand the list and fill in DisplayName / Icon / Prefab).
/// </summary>
[System.Serializable]
public class DecorItem
{
    [Tooltip("Shown as a tooltip/label under the collection button (optional to display).")]
    public string displayName;

    [Tooltip("Square icon sprite shown on the bottom collection panel button.")]
    public Sprite icon;

    [Tooltip("The 3D decoration prefab instantiated on the wall. Author it unrotated, " +
             "facing local +Z, with 'up' as local +Y (see guide Part 9).")]
    public GameObject prefab;
}
