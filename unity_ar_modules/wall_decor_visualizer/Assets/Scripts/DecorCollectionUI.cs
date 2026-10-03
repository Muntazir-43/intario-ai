using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

/// <summary>
/// Populates the bottom scrollable "Decor Collection" panel at runtime from the Items list,
/// and calls into WallPlacementManager to place (if nothing is on the wall yet) or replace
/// (if a decoration already exists) whichever item the user taps.
/// </summary>
public class DecorCollectionUI : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private Transform contentParent;      // The Scroll View's "Content" object.
    [SerializeField] private Button buttonTemplate;         // Prefab/template button (kept inactive as a template if left in scene, or assign a prefab asset).
    [SerializeField] private WallPlacementManager wallPlacementManager;

    [Header("Decoration Catalog")]
    [SerializeField] private List<DecorItem> items = new List<DecorItem>();

    private void Start()
    {
        BuildButtons();
    }

    private void BuildButtons()
    {
        if (contentParent == null || buttonTemplate == null)
        {
            Debug.LogWarning("DecorCollectionUI: contentParent or buttonTemplate not assigned.");
            return;
        }

        foreach (DecorItem item in items)
        {
            Button buttonInstance = Instantiate(buttonTemplate, contentParent);
            buttonInstance.gameObject.SetActive(true);
            buttonInstance.gameObject.name = $"Btn_{item.displayName}";

            // NOTE: GetComponentInChildren<Image>() would incorrectly return the Button's OWN
            // background Image first (it "contains itself" in the search). We need the separate
            // icon Image you added as a child, so we explicitly skip the root's own component.
            Image iconImage = null;
            foreach (Image candidate in buttonInstance.GetComponentsInChildren<Image>(true))
            {
                if (candidate.gameObject != buttonInstance.gameObject)
                {
                    iconImage = candidate;
                    break;
                }
            }

            if (iconImage != null && item.icon != null)
            {
                iconImage.sprite = item.icon;
                iconImage.preserveAspect = true;
            }

            TMP_Text labelText = buttonInstance.GetComponentInChildren<TMP_Text>();
            if (labelText != null)
            {
                labelText.text = item.displayName;
            }

            DecorItem capturedItem = item; // local copy for the closure
            buttonInstance.onClick.AddListener(() => OnDecorItemSelected(capturedItem));
        }
    }

    private void OnDecorItemSelected(DecorItem item)
    {
        if (wallPlacementManager == null || item.prefab == null) return;
        wallPlacementManager.PlaceOrReplaceDecoration(item.prefab);
    }
}
