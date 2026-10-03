using UnityEngine;
using UnityEngine.XR.ARFoundation;

public class FurnitureSpawner : MonoBehaviour
{
    [SerializeField] private ARAnchorManager anchorManager;
    [SerializeField] private FurnitureCatalog catalog;
    [SerializeField] private PlaneVisibilityManager planeVisibilityManager;

    public FurnitureItem CurrentItem { get; private set; }
    public GameObject CurrentFurnitureInstance { get; private set; }
    private ARAnchor currentAnchor;

    private void Start()
    {
        // Default furniture instantiated the first time the user places = first catalog item,
        // unless the user has already picked something from the collection panel.
        if (catalog != null && catalog.items.Length > 0)
            CurrentItem = catalog.items[0];
    }

    public void SetSelectedItem(FurnitureItem item)
    {
        CurrentItem = item;
    }

    public async void SpawnAtPose(Pose pose)
{
    if (CurrentItem == null || CurrentItem.prefab == null) return;

    ClearCurrentFurniture();

    var result = await anchorManager.TryAddAnchorAsync(pose);
    Transform parentTransform = null;

    if (result.status.IsSuccess())
    {
        currentAnchor = result.value;
        parentTransform = currentAnchor.transform;
    }
    else
    {
        Debug.LogWarning($"Anchor creation failed ({result.status}); placing without an anchor as a fallback.");
        currentAnchor = null;
    }

    // Instantiate with NO explicit position/rotation args — this preserves the
    // prefab's own authored local rotation (including any per-prefab correction
    // like the Sofa's Y=180 fix). We then combine that authored rotation with the
    // anchor/pose's alignment ourselves, instead of letting Instantiate silently
    // overwrite it.
    CurrentFurnitureInstance = Instantiate(CurrentItem.prefab);
    Quaternion combinedRotation = pose.rotation * CurrentFurnitureInstance.transform.rotation;

    Transform targetParent = parentTransform != null ? parentTransform : null;
    Vector3 targetPosition = parentTransform != null ? parentTransform.position : pose.position;

    CurrentFurnitureInstance.transform.SetPositionAndRotation(targetPosition, combinedRotation);
    if (targetParent != null)
        CurrentFurnitureInstance.transform.SetParent(targetParent, worldPositionStays: true);

    var controller = CurrentFurnitureInstance.AddComponent<FurnitureController>();
    controller.Initialize(this);

    SelectionManager.Instance.Select(CurrentFurnitureInstance);
    planeVisibilityManager?.SetPlanesVisible(false);
}
    public void ReplaceCurrentFurniture(FurnitureItem newItem)
    {
        if (currentAnchor == null || CurrentFurnitureInstance == null) return;

        CurrentItem = newItem;

        Transform anchorTransform = currentAnchor.transform;
        Transform oldTransform = CurrentFurnitureInstance.transform;
        Vector3 localScale = oldTransform.localScale;
        Quaternion localRotation = oldTransform.localRotation;

        Destroy(CurrentFurnitureInstance);

        CurrentFurnitureInstance = Instantiate(newItem.prefab, anchorTransform);
        CurrentFurnitureInstance.transform.localPosition = Vector3.zero;
        CurrentFurnitureInstance.transform.localRotation = localRotation;
        CurrentFurnitureInstance.transform.localScale = localScale;

        var controller = CurrentFurnitureInstance.AddComponent<FurnitureController>();
        controller.Initialize(this);

        SelectionManager.Instance.Select(CurrentFurnitureInstance);
    }

    public void ClearCurrentFurniture()
    {
        if (CurrentFurnitureInstance != null)
            Destroy(CurrentFurnitureInstance);

        if (currentAnchor != null)
            Destroy(currentAnchor.gameObject); // destroying the ARAnchor component's GameObject removes the anchor

        CurrentFurnitureInstance = null;
        currentAnchor = null;
        SelectionManager.Instance.Deselect();
    }

    public void ResetPlacement()
    {
        ClearCurrentFurniture();
        planeVisibilityManager.SetPlanesVisible(true); // let the user re-scan and place elsewhere

    }
}