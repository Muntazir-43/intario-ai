using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using TMPro;

/// <summary>
/// Handles the full AR wall-detection-and-placement pipeline:
///   - Raycasts against detected vertical planes every frame to drive the placement indicator.
///   - On a valid screen tap (not over UI), places the default decoration anchored to the wall.
///   - Exposes PlaceOrReplaceDecoration() / RemoveDecoration() for the collection UI and reset button.
///   - Exposes the currently active decoration's content Transform + its corrective base rotation
///     for DecorTransformController to manipulate (move/resize/rotate).
///
/// AR Foundation 6.2.1 notes:
///   - Anchoring uses ARAnchorManager.AttachAnchor(ARPlane, Pose) when the platform descriptor
///     supports trackable attachments (ARCore does), falling back to the async
///     ARAnchorManager.TryAddAnchorAsync(Pose) (Awaitable-based, Unity 6) otherwise.
///   - Do NOT use AddAnchor/AttachAnchor(Pose) synchronous overloads from AR Foundation 4.x/5.x —
///     they are gone in 6.x.
/// </summary>
[RequireComponent(typeof(ARRaycastManager))]
public class WallPlacementManager : MonoBehaviour
{
    [Header("AR Components (auto-fetched from this GameObject if left empty)")]
    [SerializeField] private ARRaycastManager raycastManager;
    [SerializeField] private ARPlaneManager planeManager;
    [SerializeField] private ARAnchorManager anchorManager;

    [Header("Prefabs")]
    [SerializeField] private GameObject placementIndicatorPrefab;
    [SerializeField] private GameObject defaultDecorationPrefab;

    [Header("Optional UI")]
    [SerializeField] private TMP_Text scanStatusText;

    [Header("Tuning")]
    [Tooltip("Small outward offset along the wall normal to avoid z-fighting with the wall mesh.")]
    [SerializeField] private float surfaceOffset = 0.01f;

    private GameObject indicatorInstance;
    private readonly List<ARRaycastHit> raycastHits = new List<ARRaycastHit>();

    private ARAnchor currentAnchor;
    private GameObject currentContent;
    private Quaternion currentBaseLocalRotation = Quaternion.identity;

    private bool hasPlacedDecoration;

    /// <summary>The live decoration content object's transform, or null if nothing is placed yet.</summary>
    public Transform CurrentContentTransform => currentContent != null ? currentContent.transform : null;

    /// <summary>The one-time corrective rotation computed at placement time (wall-facing + upright).</summary>
    public Quaternion CurrentBaseLocalRotation => currentBaseLocalRotation;

    public bool HasPlacedDecoration => hasPlacedDecoration;

    private void Awake()
    {
        if (raycastManager == null) raycastManager = GetComponent<ARRaycastManager>();
        if (planeManager == null) planeManager = GetComponent<ARPlaneManager>();
        if (anchorManager == null) anchorManager = GetComponent<ARAnchorManager>();
    }

    private void Start()
    {
        if (placementIndicatorPrefab != null)
        {
            indicatorInstance = Instantiate(placementIndicatorPrefab);
            indicatorInstance.SetActive(false);
        }

        UpdateScanStatusText(false);
    }

    private void Update()
    {
        if (hasPlacedDecoration)
        {
            // Keep the (now unwanted) wall-plane meshes hidden every frame, since AR Foundation
            // may keep detecting/creating new plane visuals in the background even after we've
            // already placed a decoration.
            SetPlaneVisualsVisible(false);
        }

        UpdateIndicator();
        HandleTapInput();
    }

    private void SetPlaneVisualsVisible(bool visible)
    {
        if (planeManager == null) return;
        foreach (ARPlane plane in planeManager.trackables)
        {
            if (plane != null && plane.gameObject.activeSelf != visible)
            {
                plane.gameObject.SetActive(visible);
            }
        }
    }

    // ---------------------------------------------------------------
    // Indicator: follows the touch position while dragging, otherwise
    // follows the screen center as a persistent "aim here" reticle.
    // ---------------------------------------------------------------
    private void UpdateIndicator()
    {
        if (hasPlacedDecoration)
        {
            // Once a decoration exists we don't need the placement reticle or status text anymore.
            if (indicatorInstance != null) indicatorInstance.SetActive(false);
            if (scanStatusText != null) scanStatusText.gameObject.SetActive(false);
            return;
        }

        Vector2 screenPoint = new Vector2(Screen.width * 0.5f, Screen.height * 0.5f);
        if (Input.touchCount > 0)
        {
            screenPoint = Input.GetTouch(0).position;
        }

        if (TryGetVerticalHit(screenPoint, out ARRaycastHit hit, out ARPlane plane))
        {
            Pose aligned = GetWallAlignedPose(hit.pose);
            if (indicatorInstance != null)
            {
                indicatorInstance.SetActive(true);
                indicatorInstance.transform.SetPositionAndRotation(aligned.position, aligned.rotation);
            }
            UpdateScanStatusText(true);
        }
        else
        {
            if (indicatorInstance != null) indicatorInstance.SetActive(false);
            UpdateScanStatusText(false);
        }
    }

    private void UpdateScanStatusText(bool wallFound)
    {
        if (scanStatusText == null) return;
        scanStatusText.gameObject.SetActive(!hasPlacedDecoration);
        scanStatusText.text = wallFound
            ? "Tap the wall to place your decoration"
            : "Move your phone slowly to scan for a wall…";
    }

    // ---------------------------------------------------------------
    // Tap-to-place
    // ---------------------------------------------------------------
    private void HandleTapInput()
    {
        if (hasPlacedDecoration) return; // placement only happens once; adjustments go through UI
        if (Input.touchCount == 0) return;

        Touch touch = Input.GetTouch(0);
        if (touch.phase != TouchPhase.Began) return;

        // Ignore taps that land on UI (buttons, sliders, collection panel).
        if (EventSystem.current != null && EventSystem.current.IsPointerOverGameObject(touch.fingerId))
            return;

        if (TryGetVerticalHit(touch.position, out ARRaycastHit hit, out ARPlane plane))
        {
            if (defaultDecorationPrefab != null)
            {
                PlaceOrReplaceDecoration(defaultDecorationPrefab, hit, plane);
            }
        }
    }

    /// <summary>
    /// AR Foundation only guarantees that a plane hit pose's UP axis equals the wall's outward
    /// normal — it does NOT guarantee the tangential (right/forward) axes point in any
    /// particular real-world direction, so trusting them directly can leave content upside-down
    /// or mirrored depending on scan direction. This rebuilds a corrected pose using the wall's
    /// real normal (reliable) plus true world-up (Vector3.up, always reliable via gravity) to
    /// get a consistent, correctly-oriented "up along the wall" direction every time.
    /// </summary>
    private static Pose GetWallAlignedPose(Pose rawHitPose)
    {
        Vector3 wallNormal = rawHitPose.up; // outward from the wall — this part is always reliable.
        Vector3 wallUp = Vector3.ProjectOnPlane(Vector3.up, wallNormal);

        if (wallUp.sqrMagnitude < 0.0001f)
        {
            // Extremely rare edge case (wall almost perfectly level with world up) — fall back.
            wallUp = rawHitPose.forward;
        }
        wallUp.Normalize();

        Quaternion alignedRotation = Quaternion.LookRotation(wallUp, wallNormal);
        return new Pose(rawHitPose.position, alignedRotation);
    }

    /// <summary>
    /// Raycasts against AR plane trackables at the given screen point and returns true only if
    /// the closest valid hit belongs to a VERTICAL plane (walls) — horizontal hits are ignored.
    /// </summary>
    private bool TryGetVerticalHit(Vector2 screenPoint, out ARRaycastHit hit, out ARPlane plane)
    {
        hit = default;
        plane = null;

        if (raycastManager.Raycast(screenPoint, raycastHits, TrackableType.PlaneWithinPolygon))
        {
            foreach (var candidate in raycastHits)
            {
                ARPlane candidatePlane = planeManager != null ? planeManager.GetPlane(candidate.trackableId) : null;
                if (candidatePlane != null && candidatePlane.alignment == PlaneAlignment.Vertical)
                {
                    hit = candidate;
                    plane = candidatePlane;
                    return true;
                }
            }
        }
        return false;
    }

    // ---------------------------------------------------------------
    // Placement / Replace / Remove (called from taps AND from DecorCollectionUI)
    // ---------------------------------------------------------------

    /// <summary>
    /// Places a brand-new decoration at the given wall hit, or — if a decoration is already
    /// placed and this is called from the collection panel without a fresh hit — replaces the
    /// visual content in place on the SAME anchor. See the public overload below.
    /// </summary>
    private void PlaceOrReplaceDecoration(GameObject prefab, ARRaycastHit hit, ARPlane plane)
    {
        Pose aligned = GetWallAlignedPose(hit.pose);
        CreateAnchorAndAttach(aligned, plane, anchor =>
        {
            currentAnchor = anchor;
            SpawnContent(prefab);
            hasPlacedDecoration = true;
        });
    }

    /// <summary>
    /// Public entry point used by DecorCollectionUI. If nothing is placed yet, this is a no-op
    /// visually (the user must first tap a wall) — but typically the collection panel is used
    /// AFTER initial placement to swap the decoration in place, which this handles directly by
    /// re-parenting a new prefab instance under the existing anchor (no new raycast needed).
    /// </summary>
    public void PlaceOrReplaceDecoration(GameObject prefab)
    {
        if (prefab == null) return;

        if (currentAnchor != null)
        {
            // Replace in place on the existing anchor.
            SpawnContent(prefab);
        }
        else
        {
            // Nothing placed yet — fall back to using the default prefab pipeline by asking the
            // user to tap the wall; we simply remember this as the "next placed" prefab.
            defaultDecorationPrefab = prefab;
        }
    }

    private void SpawnContent(GameObject prefab)
    {
        if (currentContent != null)
        {
            Destroy(currentContent);
            currentContent = null;
        }

        if (currentAnchor == null || prefab == null) return;

        currentContent = Instantiate(prefab, currentAnchor.transform);

        // Corrective rotation: the anchor's local Y axis is the wall's outward normal and its
        // local Z axis points vertically up the wall (see guide Part 12). We want the content's
        // forward (+Z) to face outward (anchor's +Y) and the content's up (+Y) to point up the
        // wall (anchor's +Z), so the artwork reads right-side-up and faces into the room.
        currentBaseLocalRotation = Quaternion.LookRotation(Vector3.up, Vector3.forward);
        currentContent.transform.localRotation = currentBaseLocalRotation;
        currentContent.transform.localPosition = new Vector3(0f, surfaceOffset, 0f);
        currentContent.transform.localScale = Vector3.one;
    }

    /// <summary>Removes the current decoration and its anchor, returning to placement mode.</summary>
    public void RemoveDecoration()
    {
        if (currentContent != null)
        {
            Destroy(currentContent);
            currentContent = null;
        }

        if (currentAnchor != null)
        {
            Destroy(currentAnchor.gameObject);
            currentAnchor = null;
        }

        hasPlacedDecoration = false;
        SetPlaneVisualsVisible(true);
        UpdateScanStatusText(false);
    }

    // ---------------------------------------------------------------
    // Anchoring (AR Foundation 6.2.1 API)
    // ---------------------------------------------------------------
    private async void CreateAnchorAndAttach(Pose pose, ARPlane plane, System.Action<ARAnchor> onComplete)
    {
        ARAnchor anchor = null;

        bool supportsAttachment = anchorManager != null
                                   && anchorManager.descriptor != null
                                   && anchorManager.descriptor.supportsTrackableAttachments;

        if (supportsAttachment && plane != null)
        {
            // Synchronous path: attach the anchor directly to the plane trackable.
            anchor = anchorManager.AttachAnchor(plane, pose);
        }

        if (anchor == null && anchorManager != null)
        {
            // Async fallback (Unity 6 Awaitable-based API).
            var result = await anchorManager.TryAddAnchorAsync(pose);
            if (result.status.IsSuccess())
            {
                anchor = result.value;
            }
        }

        if (anchor != null)
        {
            onComplete?.Invoke(anchor);
        }
        else
        {
            Debug.LogWarning("WallPlacementManager: failed to create an anchor for the wall hit.");
        }
    }
}
