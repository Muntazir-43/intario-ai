using UnityEngine;
using UnityEngine.InputSystem.EnhancedTouch;
using Touch = UnityEngine.InputSystem.EnhancedTouch.Touch;

public class SelectionManager : MonoBehaviour
{
    public static SelectionManager Instance { get; private set; }

    [SerializeField] private Camera arCamera;
    [SerializeField] private LayerMask furnitureLayerMask = ~0;

    public GameObject SelectedObject { get; private set; }

    private void Awake()
    {
        if (Instance != null && Instance != this) { Destroy(gameObject); return; }
        Instance = this;
    }

    private void Update()
    {
        if (Touch.activeTouches.Count == 0) return;

        var touch = Touch.activeTouches[0];
        if (touch.phase != UnityEngine.InputSystem.TouchPhase.Began) return;

        Ray ray = arCamera.ScreenPointToRay(touch.screenPosition);
        if (Physics.Raycast(ray, out RaycastHit hit, 50f, furnitureLayerMask))
        {
            if (hit.collider.CompareTag("Furniture"))
            {
                // Selecting the collider's root furniture object (in case the collider
                // is on a child mesh rather than the root).
                Select(hit.collider.transform.root.gameObject);
            }
        }
    }

  public void Select(GameObject go)
{
    if (SelectedObject != null)
        SelectedObject.GetComponent<FurnitureController>()?.SetHighlighted(false);

    SelectedObject = go;

    if (SelectedObject != null)
        SelectedObject.GetComponent<FurnitureController>()?.SetHighlighted(true);

    FurnitureUIManager.Instance?.OnSelectionChanged(SelectedObject != null);
    FurnitureManipulationUI.Instance?.OnSelectionChanged(SelectedObject); // ← add this line
}
    public void Deselect() => Select(null);
}