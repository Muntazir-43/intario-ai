using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using TMPro;

/// <summary>
/// Manages the central aiming reticle.
/// Continuously raycasts from screen center onto AR planes
/// and feature points, moving the 3D marker to the hit position.
/// </summary>
public class AimpointerController : MonoBehaviour
{
    [Header("AR References")]
    [SerializeField] private ARRaycastManager _raycastManager;
    [SerializeField] private ARPlaneManager _planeManager;

    [Header("Aimpointer Visuals")]
    [SerializeField] private GameObject _aimMarkerPrefab;
    [SerializeField] private GameObject _crosshairUI;

    [Header("Debug")]
    [SerializeField] private TextMeshProUGUI _statusText;

    // ── Public State ──────────────────────────────────────────
    public bool       IsHitting          { get; private set; }
    public bool       IsHittingWall      { get; private set; }
    public Vector3    HitPosition        { get; private set; }
    public Vector3    HitNormal          { get; private set; }
    public Pose       HitPose            { get; private set; }
    public Vector3    SmoothedPosition   => _smoothedPosition;
    public Quaternion SmoothedRotation   => _aimMarkerInstance != null ? _aimMarkerInstance.transform.rotation : HitPose.rotation;

    // ── Private ───────────────────────────────────────────────
    private GameObject              _aimMarkerInstance;
    private List<ARRaycastHit>      _hits = new List<ARRaycastHit>();
    private Camera                  _arCamera;
    private UnityEngine.UI.Image[]  _crosshairImages;

    // Raycast against vertical planes AND feature points for
    // better accuracy near wall edges where planes are thin
    private const TrackableType _raycastMask =
        TrackableType.PlaneWithinPolygon |
        TrackableType.FeaturePoint;

    // ── Smoothing ─────────────────────────────────────────────
    [Header("Smoothing")]
    [SerializeField, Range(1f, 20f)]
    private float _positionSmoothing = 12f;

    private Vector3 _smoothedPosition;
    private bool    _markerInitialized;

    // ─────────────────────────────────────────────────────────
    private void Awake()
    {
        // Grab the AR camera from XR Origin
        _arCamera = Camera.main;

        // Cache crosshair images once to eliminate per-frame GC allocations
        if (_crosshairUI != null)
            _crosshairImages = _crosshairUI.GetComponentsInChildren<UnityEngine.UI.Image>(true);

        // Instantiate the aim marker but hide it until first hit
        if (_aimMarkerPrefab != null)
        {
            _aimMarkerInstance = Instantiate(_aimMarkerPrefab);
            _aimMarkerInstance.SetActive(false);
        }
    }

    private void Update()
    {
        PerformScreenCenterRaycast();
        UpdateMarkerTransform();
        UpdateCrosshairFeedback();
    }

    // ─────────────────────────────────────────────────────────
    /// <summary>
    /// Shoots a raycast from the exact screen center.
    /// Screen center is always (screenW/2, screenH/2).
    /// </summary>
    private void PerformScreenCenterRaycast()
    {
        Vector2 screenCenter = new Vector2(
            Screen.width  / 2f,
            Screen.height / 2f
        );

        IsHitting = _raycastManager.Raycast(
            screenCenter,
            _hits,
            _raycastMask
        );

        if (IsHitting)
        {
            // AR Foundation sorts hits by distance — closest first
            ARRaycastHit bestHit = _hits[0];

            HitPose     = bestHit.pose;
            HitPosition = bestHit.pose.position;

            // Validate that the hit surface is vertical (a wall)
            // A vertical plane has its normal perpendicular to Vector3.up (dot product near 0).
            // Floors and ceilings have dot product near 1 or -1.
            bool isVertical = false;
            if (bestHit.trackable is ARPlane plane)
            {
                isVertical = (plane.alignment == PlaneAlignment.Vertical);
                HitNormal = plane.normal;
            }
            else
            {
                isVertical = Mathf.Abs(Vector3.Dot(bestHit.pose.up, Vector3.up)) < 0.35f;
                HitNormal = bestHit.pose.up;
            }

            IsHittingWall = isVertical;

            // Smooth the position on first frame vs subsequent frames
            if (!_markerInitialized)
            {
                _smoothedPosition  = HitPosition;
                _markerInitialized = true;
            }
            else
            {
                _smoothedPosition = Vector3.Lerp(
                    _smoothedPosition,
                    HitPosition,
                    Time.deltaTime * _positionSmoothing
                );
            }
        }
        else
        {
            IsHittingWall = false;
        }
    }

    // ─────────────────────────────────────────────────────────
    /// <summary>
    /// Moves and orients the 3D aim marker to the smoothed hit position.
    /// The marker is rotated to align with the plane normal so it
    /// sits flush against the wall surface.
    /// </summary>
    private void UpdateMarkerTransform()
    {
        if (_aimMarkerInstance == null) return;

        if (IsHitting)
        {
            _aimMarkerInstance.SetActive(true);

            // Position: smoothed world position
            _aimMarkerInstance.transform.position = _smoothedPosition;

            // Rotation: face the camera while staying on the wall plane
            // HitPose.rotation already encodes the plane orientation
            _aimMarkerInstance.transform.rotation = Quaternion.Lerp(
                _aimMarkerInstance.transform.rotation,
                HitPose.rotation,
                Time.deltaTime * _positionSmoothing
            );
        }
        else
        {
            _aimMarkerInstance.SetActive(false);
        }
    }

    // ─────────────────────────────────────────────────────────
    /// <summary>
    /// Pulses the crosshair color based on hit state:
    ///   Green  → hitting a vertical wall plane (ready for wall points)
    ///   Yellow → hitting horizontal surface or feature point
    ///   White  → no hit
    /// </summary>
    private void UpdateCrosshairFeedback()
    {
        if (_crosshairImages == null || _crosshairImages.Length == 0) return;

        Color targetColor;
        string statusMsg;

        if (!IsHitting)
        {
            targetColor = new Color(1f, 1f, 1f, 0.6f); // white, dimmed
            statusMsg   = "Searching for walls...";
        }
        else if (IsHittingWall)
        {
            targetColor = new Color(0.2f, 1f, 0.4f, 0.9f); // green
            statusMsg   = "Wall detected ✓";
        }
        else
        {
            targetColor = new Color(1f, 0.85f, 0.2f, 0.9f); // yellow
            statusMsg   = "Surface detected (aim at a wall)";
        }

        // Apply color using cached array — zero heap allocation
        float lerpFactor = Time.deltaTime * 8f;
        for (int i = 0; i < _crosshairImages.Length; i++)
        {
            if (_crosshairImages[i] != null)
                _crosshairImages[i].color = Color.Lerp(_crosshairImages[i].color, targetColor, lerpFactor);
        }

        if (_statusText != null)
            _statusText.text = statusMsg;
    }

    // ─────────────────────────────────────────────────────────
    // Public cleanup — called when a point is confirmed placed
    public void PulseConfirm()
    {
        StartCoroutine(PulseRoutine());
    }

    private System.Collections.IEnumerator PulseRoutine()
    {
        if (_aimMarkerInstance == null) yield break;

        Vector3 original = _aimMarkerInstance.transform.localScale;
        Vector3 big      = original * 1.8f;

        float t = 0f;
        while (t < 1f)
        {
            t += Time.deltaTime * 10f;
            _aimMarkerInstance.transform.localScale =
                Vector3.Lerp(original, big, Mathf.Sin(t * Mathf.PI));
            yield return null;
        }

        _aimMarkerInstance.transform.localScale = original;
    }

    // ─────────────────────────────────────────────────────────
    private void OnDestroy()
    {
        if (_aimMarkerInstance != null)
            Destroy(_aimMarkerInstance);
    }
}
