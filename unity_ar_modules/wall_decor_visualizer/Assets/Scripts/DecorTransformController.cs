using UnityEngine;

/// <summary>
/// Wires the D-pad move buttons, resize slider, rotate slider, and reset button to the
/// currently placed decoration's content transform (exposed by WallPlacementManager).
///
/// Movement is expressed in the anchor's LOCAL space: localPosition.x = along the wall
/// (horizontal), localPosition.z = up the wall (vertical) — see guide Part 12 for why.
/// Resize and Rotate are both absolute (derived fresh from the slider value each call),
/// so there is no drift from repeated incremental multiplication/rotation.
/// </summary>
public class DecorTransformController : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private WallPlacementManager wallPlacementManager;

    [Header("Move")]
    [SerializeField] private float moveStep = 0.02f;
    [SerializeField] private float maxOffsetFromCenter = 0.5f;

    [Header("Resize (maps slider 0..1 -> min..max scale)")]
    [SerializeField] private float minScale = 0.5f;
    [SerializeField] private float maxScale = 2.5f;

    public void MoveUp() => Move(0f, moveStep);
    public void MoveDown() => Move(0f, -moveStep);
    public void MoveLeft() => Move(-moveStep, 0f);
    public void MoveRight() => Move(moveStep, 0f);

    private void Move(float dx, float dz)
    {
        Transform content = wallPlacementManager != null ? wallPlacementManager.CurrentContentTransform : null;
        if (content == null) return;

        Vector3 local = content.localPosition;
        local.x = Mathf.Clamp(local.x + dx, -maxOffsetFromCenter, maxOffsetFromCenter);
        local.z = Mathf.Clamp(local.z + dz, -maxOffsetFromCenter, maxOffsetFromCenter);
        content.localPosition = local;
    }

    /// <summary>Hook to a Slider's OnValueChanged(float), range 0..1.</summary>
    public void SetScale(float sliderValue01)
    {
        Transform content = wallPlacementManager != null ? wallPlacementManager.CurrentContentTransform : null;
        if (content == null) return;

        float scale = Mathf.Lerp(minScale, maxScale, Mathf.Clamp01(sliderValue01));
        content.localScale = Vector3.one * scale;
    }

    /// <summary>Hook to a Slider's OnValueChanged(float), range 0..360 (degrees).</summary>
    public void SetRotation(float degrees)
    {
        Transform content = wallPlacementManager != null ? wallPlacementManager.CurrentContentTransform : null;
        if (content == null) return;

        Quaternion baseRotation = wallPlacementManager.CurrentBaseLocalRotation;
        // Spin around the content's local Z axis, which — after the corrective base rotation —
        // points along the wall's outward normal, i.e. this spins the artwork in the wall plane.
        content.localRotation = baseRotation * Quaternion.AngleAxis(degrees, Vector3.forward);
    }

    /// <summary>Hook to the Reset/Remove button's OnClick().</summary>
    public void RemoveDecoration()
    {
        if (wallPlacementManager != null)
        {
            wallPlacementManager.RemoveDecoration();
        }
    }
}
