using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

/// <summary>
/// Handles placing wall anchor points at the Aimpointer's
/// current hit position, connecting them with a LineRenderer,
/// and managing the "Go" button visibility threshold.
/// </summary>
public class PointPlacementManager : MonoBehaviour
{
    // ── Inspector References ──────────────────────────────────
    [Header("Dependencies")]
    [SerializeField] private AimpointerController _aimpointer;
    [SerializeField] private WallMeshGenerator    _meshGenerator;
    [SerializeField] private TextureManager       _textureManager;
    [SerializeField] private MeasurementDisplay   _measurementDisplay;
    [SerializeField] private UIAnimationManager   _uiAnimator;

    [Header("Prefabs & Scene Objects")]
    [SerializeField] private GameObject   _pointMarkerPrefab;
    [SerializeField] private LineRenderer _lineRenderer;

    [Header("UI")]
    [SerializeField] private Button          _placeButton;
    [SerializeField] private Button          _undoButton;
    [SerializeField] private Button          _goButton;
    [SerializeField] private Button          _resetButton;
    [SerializeField] private TextMeshProUGUI _pointCountText;

    [Header("Settings")]
    [SerializeField] private int   _minPointsForGo    = 3;
    [SerializeField] private int   _maxPoints         = 12;
    [SerializeField] private float _minDistanceBetweenPoints = 0.05f;

    // ── Runtime State ─────────────────────────────────────────
    private List<Vector3>     _placedPositions = new List<Vector3>();
    private List<GameObject>  _placedMarkers   = new List<GameObject>();
    private bool              _meshGenerated   = false;

    // ── Public Read ───────────────────────────────────────────
    public IReadOnlyList<Vector3> PlacedPositions => _placedPositions;
    public bool MeshGenerated => _meshGenerated;

    // ─────────────────────────────────────────────────────────
    private void Awake()
    {
        if (_measurementDisplay == null)
            _measurementDisplay = GetComponent<MeasurementDisplay>() ?? FindAnyObjectByType<MeasurementDisplay>();

        if (_uiAnimator == null)
            _uiAnimator = GetComponent<UIAnimationManager>() ?? FindAnyObjectByType<UIAnimationManager>();

        ValidateReferences();
    }

    private void Start()
    {
        // Wire up button listeners
        _placeButton.onClick.AddListener(TryPlacePoint);
        _undoButton .onClick.AddListener(UndoLastPoint);
        _goButton   .onClick.AddListener(OnGoPressed);
        _resetButton.onClick.AddListener(ResetAll);

        RefreshUI();
    }

    private void Update()
    {
        // Place button is only interactable when aiming at a detected wall surface
        _placeButton.interactable =
            _aimpointer != null && _aimpointer.IsHittingWall && !_meshGenerated;

        UpdateLineRenderer();
    }

    // ─────────────────────────────────────────────────────────
    #region Point Placement

    /// <summary>
    /// Attempts to place a point at the current aimpointer position.
    /// Enforces minimum distance from the previous point to avoid
    /// accidental duplicate placements.
    /// </summary>
    private void TryPlacePoint()
    {
        if (_aimpointer == null || !_aimpointer.IsHittingWall)
        {
            Debug.Log("[PointPlacement] No wall hit — cannot place.");
            return;
        }

        if (_placedPositions.Count >= _maxPoints)
        {
            Debug.Log("[PointPlacement] Maximum points reached.");
            return;
        }

        // Use smoothed position and rotation for stable, accurate point placement
        Vector3 newPos = _aimpointer.SmoothedPosition;
        Quaternion newRot = _aimpointer.SmoothedRotation;

        // Distance check against last placed point
        if (_placedPositions.Count > 0)
        {
            float dist = Vector3.Distance(
                newPos,
                _placedPositions[_placedPositions.Count - 1]
            );

            if (dist < _minDistanceBetweenPoints)
            {
                Debug.Log("[PointPlacement] Too close to previous point.");
                return;
            }
        }

        PlacePoint(newPos, newRot);
    }

    private void PlacePoint(Vector3 position, Quaternion rotation)
    {
        // Spawn the marker prefab
        GameObject marker = Instantiate(
            _pointMarkerPrefab,
            position,
            rotation
        );

        // Label the marker with its index for easy debugging
        marker.name = $"WallPoint_{_placedPositions.Count}";

        _placedPositions.Add(position);
        _placedMarkers  .Add(marker);

        // Visual confirm pulse on the aimpointer
        _aimpointer.PulseConfirm();

        RefreshUI();

        Debug.Log($"[PointPlacement] Point {_placedPositions.Count} " +
                  $"placed at {position}");
    }

    #endregion

    // ─────────────────────────────────────────────────────────
    #region Undo & Reset

    private void UndoLastPoint()
    {
        if (_placedPositions.Count == 0) return;

        int last = _placedPositions.Count - 1;

        if (_placedMarkers[last] != null)
            Destroy(_placedMarkers[last]);

        _placedMarkers  .RemoveAt(last);
        _placedPositions.RemoveAt(last);

        _meshGenerated = false;
        RefreshUI();

        Debug.Log("[PointPlacement] Last point removed.");
    }

    private void ResetAll()
    {
        foreach (var marker in _placedMarkers)
            if (marker != null) Destroy(marker);

        _placedMarkers  .Clear();
        _placedPositions.Clear();
        _meshGenerated = false;

        if (_lineRenderer != null)
            _lineRenderer.positionCount = 0;

        // Destroy the generated mesh
        if (_meshGenerator != null)
            _meshGenerator.DestroyMesh();

        // Reset texture UI and clear stale material reference
        if (_textureManager != null)
            _textureManager.OnReset();

        // Reset measurement panel
        if (_measurementDisplay != null)
            _measurementDisplay.OnReset();

        // Stop GO pulse
        if (_uiAnimator != null)
            _uiAnimator.StopGoButtonPulse();

        RefreshUI();
        Debug.Log("[PointPlacement] All points cleared.");
    }

    #endregion

    // ─────────────────────────────────────────────────────────
    #region LineRenderer

    /// <summary>
    /// Updates the LineRenderer every frame to connect all placed
    /// points in a closed loop, plus a live preview to the aimpointer.
    /// </summary>
    private void UpdateLineRenderer()
    {
        if (_meshGenerated || _lineRenderer == null)
        {
            if (_lineRenderer != null) _lineRenderer.positionCount = 0;
            return;
        }

        int count = _placedPositions.Count;
        bool showPreview = _aimpointer != null && _aimpointer.IsHittingWall && count > 0;

        if (count == 0)
        {
            _lineRenderer.positionCount = 0;
            return;
        }

        if (count == 1 && !showPreview)
        {
            _lineRenderer.positionCount = 0;
            return;
        }

        if (showPreview)
        {
            // When previewing:
            // If >= 2 points placed, preview closes back to start:
            // pt0 -> pt1 -> ... -> ptN -> aimCursor -> pt0 (complete closed polygon outline)
            if (count >= 2)
            {
                _lineRenderer.positionCount = count + 2;
                for (int i = 0; i < count; i++)
                    _lineRenderer.SetPosition(i, _placedPositions[i]);

                _lineRenderer.SetPosition(count, _aimpointer.SmoothedPosition);
                _lineRenderer.SetPosition(count + 1, _placedPositions[0]);
            }
            else // count == 1
            {
                _lineRenderer.positionCount = 2;
                _lineRenderer.SetPosition(0, _placedPositions[0]);
                _lineRenderer.SetPosition(1, _aimpointer.SmoothedPosition);
            }
        }
        else
        {
            // No preview: draw closed loop if >= 3 points, or single segment if 2 points
            if (count >= 3)
            {
                _lineRenderer.positionCount = count + 1;
                for (int i = 0; i < count; i++)
                    _lineRenderer.SetPosition(i, _placedPositions[i]);
                _lineRenderer.SetPosition(count, _placedPositions[0]); // close back to start
            }
            else if (count == 2)
            {
                _lineRenderer.positionCount = 2;
                _lineRenderer.SetPosition(0, _placedPositions[0]);
                _lineRenderer.SetPosition(1, _placedPositions[1]);
            }
            else
            {
                _lineRenderer.positionCount = 0;
            }
        }
    }

    #endregion

    // ─────────────────────────────────────────────────────────
    #region UI State

    /// <summary>
    /// Refreshes all UI elements based on current placement state.
    /// Called after every state change.
    /// </summary>
    private void RefreshUI()
    {
        int count = _placedPositions.Count;

        // Point counter label
        if (_pointCountText != null)
        {
            if (count == 0)
            {
                _pointCountText.text = "Aim at a wall and tap +";
            }
            else
            {
                int remaining = _minPointsForGo - count;
                string suffix = remaining > 0
                    ? $"({remaining} more for Go)"
                    : "Ready!";
                _pointCountText.text = $"Points: {count}  {suffix}";
            }
        }

        // Go button: only visible once minimum points placed
        bool canGo = count >= _minPointsForGo && !_meshGenerated;
        _goButton.gameObject.SetActive(canGo);

        if (_uiAnimator != null)
        {
            if (canGo) _uiAnimator.StartGoButtonPulse();
            else _uiAnimator.StopGoButtonPulse();
        }

        // Undo button: only useful if points exist
        _undoButton.interactable = count > 0 && !_meshGenerated;

        // Reset button: always available if anything exists
        _resetButton.interactable = count > 0;

        // Place button: disabled after mesh generated
        _placeButton.interactable = !_meshGenerated;
    }

    private void OnGoPressed()
    {
        if (_placedPositions.Count < _minPointsForGo) return;

        _meshGenerated = true;

        // Hide marker spheres so they don't float over the wall texture
        foreach (var marker in _placedMarkers)
        {
            if (marker != null)
                marker.SetActive(false);
        }

        if (_uiAnimator != null)
            _uiAnimator.StopGoButtonPulse();

        RefreshUI();

        // Broadcast to mesh generator
        Debug.Log("[PointPlacement] GO pressed — " +
                  $"{_placedPositions.Count} points confirmed.");

        OnGoConfirmed?.Invoke(_placedPositions);
    }

    // Event that MeshGenerator will subscribe to
    public event System.Action<IReadOnlyList<Vector3>> OnGoConfirmed;

    #endregion

    // ─────────────────────────────────────────────────────────
    #region Validation

    private void ValidateReferences()
    {
        if (_aimpointer      == null) Debug.LogError("[PointPlacement] Missing AimpointerController!");
        if (_pointMarkerPrefab == null) Debug.LogError("[PointPlacement] Missing point marker prefab!");
        if (_lineRenderer    == null) Debug.LogError("[PointPlacement] Missing LineRenderer!");
        if (_placeButton     == null) Debug.LogError("[PointPlacement] Missing Place button!");
        if (_goButton        == null) Debug.LogError("[PointPlacement] Missing Go button!");
    }

    #endregion

    private void OnDestroy()
    {
        _placeButton.onClick.RemoveListener(TryPlacePoint);
        _undoButton .onClick.RemoveListener(UndoLastPoint);
        _goButton   .onClick.RemoveListener(OnGoPressed);
        _resetButton.onClick.RemoveListener(ResetAll);
    }
}
