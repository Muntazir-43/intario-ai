using UnityEngine;
using UnityEngine.UI;

public class FurnitureManipulationUI : MonoBehaviour
{
    public static FurnitureManipulationUI Instance { get; private set; }

    [SerializeField] private GameObject manipulationPanel;
    [SerializeField] private Slider rotationSlider; // 0–360 degrees
    [SerializeField] private Slider scaleSlider;    // FurnitureController.MinScale–MaxScale

    private GameObject currentTarget;
    private bool suppressCallbacks; // prevents SetValueWithoutNotify from re-triggering itself

    private void Awake()
    {
        Instance = this;
    }

    private void Start()
    {
        rotationSlider.minValue = 0f;
        rotationSlider.maxValue = 360f;
        scaleSlider.minValue = FurnitureController.MinScale;
        scaleSlider.maxValue = FurnitureController.MaxScale;

        rotationSlider.onValueChanged.AddListener(OnRotationSliderChanged);
        scaleSlider.onValueChanged.AddListener(OnScaleSliderChanged);

        manipulationPanel.SetActive(false);
    }

    // Called from SelectionManager whenever the selected furniture changes (or is cleared).
    public void OnSelectionChanged(GameObject selected)
    {
        currentTarget = selected;

        if (selected == null)
        {
            manipulationPanel.SetActive(false);
            return;
        }

        manipulationPanel.SetActive(true);

        // Reflect the newly-selected object's actual current rotation/scale on the
        // sliders WITHOUT firing OnRotationSliderChanged/OnScaleSliderChanged — otherwise
        // setting the slider's value would immediately overwrite the object's transform
        // with whatever the slider happened to show a moment ago.
        suppressCallbacks = true;
        rotationSlider.SetValueWithoutNotify(selected.transform.eulerAngles.y);
        scaleSlider.SetValueWithoutNotify(selected.transform.localScale.x);
        suppressCallbacks = false;
    }

    private void OnRotationSliderChanged(float value)
    {
        if (suppressCallbacks || currentTarget == null) return;

        Vector3 euler = currentTarget.transform.eulerAngles;
        currentTarget.transform.eulerAngles = new Vector3(euler.x, value, euler.z);
    }

    private void OnScaleSliderChanged(float value)
    {
        if (suppressCallbacks || currentTarget == null) return;

        currentTarget.transform.localScale = Vector3.one * value;
        ReGroundToFloor(currentTarget);
    }

    // Forces the object's lowest rendered point back down to the anchor's floor height,
    // regardless of exactly where the model's own pivot sits. Compensates for imperfect
    // per-model pivot alignment instead of relying on it being pixel-perfect.
    private void ReGroundToFloor(GameObject target)
    {
        var renderers = target.GetComponentsInChildren<Renderer>();
        if (renderers.Length == 0) return;

        Bounds bounds = renderers[0].bounds;
        foreach (var r in renderers) bounds.Encapsulate(r.bounds);

        float floorWorldY = target.transform.parent != null
            ? target.transform.parent.position.y  // the anchor's Y == floor height
            : target.transform.position.y;

        float correction = floorWorldY - bounds.min.y;
        target.transform.position += new Vector3(0f, correction, 0f);
    }
}