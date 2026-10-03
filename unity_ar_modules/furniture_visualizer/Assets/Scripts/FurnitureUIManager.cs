using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Collections.Generic;

public class FurnitureUIManager : MonoBehaviour
{
    public static FurnitureUIManager Instance { get; private set; }

    [SerializeField] private FurnitureCatalog catalog;
    [SerializeField] private FurnitureSpawner spawner;
    [SerializeField] private Transform collectionButtonParent;   // Scroll View's "Content"
    [SerializeField] private GameObject collectionButtonPrefab;  // FurnitureCollectionButton prefab
    [SerializeField] private GameObject selectedObjectToolbar;
    [SerializeField] private Button deleteButton;
    [SerializeField] private Button resetButton;

    private readonly List<Button> collectionButtons = new List<Button>();
    private int selectedCatalogIndex = 0;

    private void Awake()
    {
        Instance = this;
    }

    private void Start()
    {
        PopulateCollection();
        selectedObjectToolbar.SetActive(false);

        deleteButton.onClick.AddListener(OnDeleteButtonPressed);
        resetButton.onClick.AddListener(OnResetButtonPressed);

        HighlightCatalogButton(selectedCatalogIndex);
    }

private void PopulateCollection()
{
    Debug.Log($"PopulateCollection: catalog={catalog}, items={(catalog != null ? catalog.items.Length : -1)}, parent={collectionButtonParent}, prefab={collectionButtonPrefab}");

    for (int i = 0; i < catalog.items.Length; i++)
    {
        FurnitureItem item = catalog.items[i];
        int capturedIndex = i;

        var buttonGO = Instantiate(collectionButtonPrefab, collectionButtonParent);
        buttonGO.name = $"Btn_{item.displayName}";

        Debug.Log($"Instantiated button {i}: {buttonGO.name}, active={buttonGO.activeInHierarchy}, size={buttonGO.GetComponent<RectTransform>().rect.size}");

        var view = buttonGO.GetComponent<FurnitureCollectionButtonView>();
        if (view == null)
        {
            Debug.LogError($"FurnitureCollectionButton prefab is missing FurnitureCollectionButtonView (item: {item.displayName}).");
            continue;
        }

        view.ThumbnailImage.sprite = item.thumbnail;
        view.Label.text = item.displayName;
        view.Button.onClick.AddListener(() => OnFurnitureButtonPressed(item, capturedIndex));

        collectionButtons.Add(view.Button);
    }
}

    private void OnFurnitureButtonPressed(FurnitureItem item, int index)
    {
        selectedCatalogIndex = index;
        HighlightCatalogButton(index);

        if (spawner.CurrentFurnitureInstance != null)
        {
            // Furniture already placed -> swap the model in place, keeping position/rotation/scale.
            spawner.ReplaceCurrentFurniture(item);
        }
        else
        {
            // Nothing placed yet -> remember the choice; the next floor tap spawns it.
            spawner.SetSelectedItem(item);
        }
    }

    private void HighlightCatalogButton(int index)
    {
        for (int i = 0; i < collectionButtons.Count; i++)
        {
            var colors = collectionButtons[i].colors;
            // Reuse the Selected Color you set on the prefab (8.3) to show the active item;
            // Button.Select() also works if you prefer relying on the built-in selection state.
            var targetGraphic = collectionButtons[i].targetGraphic as Image;
            if (targetGraphic != null)
                targetGraphic.color = (i == index) ? colors.selectedColor : colors.normalColor;
        }
    }

    public void OnSelectionChanged(bool somethingSelected)
    {
        selectedObjectToolbar.SetActive(somethingSelected);
    }

    private void OnDeleteButtonPressed()
    {
        spawner.ClearCurrentFurniture();
    }

    private void OnResetButtonPressed()
    {
        spawner.ResetPlacement();
    }
}