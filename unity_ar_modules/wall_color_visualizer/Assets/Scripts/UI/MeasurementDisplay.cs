using System.Collections.Generic;
using UnityEngine;
using TMPro;

/// <summary>
/// Calculates and displays real-world measurements between
/// placed wall points using AR world-space distances.
/// Shows perimeter and area of the defined wall polygon.
/// </summary>
public class MeasurementDisplay : MonoBehaviour
{
    // ── Inspector ─────────────────────────────────────────────
    [Header("Dependencies")]
    [SerializeField] private PointPlacementManager _placementManager;

    [Header("UI")]
    [SerializeField] private GameObject      _measurementPanel;
    [SerializeField] private TextMeshProUGUI _perimeterText;
    [SerializeField] private TextMeshProUGUI _areaText;
    [SerializeField] private TextMeshProUGUI _pointCountText;

    [Header("Settings")]
    [SerializeField] private bool _useMetric = true;

    // ── Runtime ───────────────────────────────────────────────
    private List<Vector3> _lastKnownPoints = new List<Vector3>();

    // ─────────────────────────────────────────────────────────
    private void Start()
    {
        if (_measurementPanel != null)
            _measurementPanel.SetActive(false);

        _placementManager.OnGoConfirmed += OnGoConfirmed;
    }

    private void OnDestroy()
    {
        if (_placementManager != null)
            _placementManager.OnGoConfirmed -= OnGoConfirmed;
    }

    /// <summary>
    /// Resets and hides the measurement panel when all points are cleared.
    /// </summary>
    public void OnReset()
    {
        _lastKnownPoints.Clear();
        if (_measurementPanel != null)
            _measurementPanel.SetActive(false);
    }

    // ─────────────────────────────────────────────────────────
    private void OnGoConfirmed(IReadOnlyList<Vector3> points)
    {
        _lastKnownPoints.Clear();
        foreach (var p in points) _lastKnownPoints.Add(p);

        UpdateMeasurements();

        if (_measurementPanel != null)
            _measurementPanel.SetActive(true);
    }

    // ─────────────────────────────────────────────────────────
    private void UpdateMeasurements()
    {
        if (_lastKnownPoints.Count < 2) return;

        float perimeter = CalculatePerimeter(_lastKnownPoints);
        float area      = CalculatePolygonArea(_lastKnownPoints);

        // Format based on unit preference
        string perimeterStr = FormatLength(perimeter);
        string areaStr      = FormatArea(area);

        if (_perimeterText != null)
            _perimeterText.text = $"Perimeter: {perimeterStr}";

        if (_areaText != null)
            _areaText.text = $"Area: {areaStr}";

        if (_pointCountText != null)
            _pointCountText.text = $"Points: {_lastKnownPoints.Count}";

        Debug.Log($"[Measurement] Perimeter: {perimeterStr} " +
                  $"| Area: {areaStr}");
    }

    // ─────────────────────────────────────────────────────────
    #region Calculations

    private float CalculatePerimeter(List<Vector3> pts)
    {
        float total = 0f;
        int   n     = pts.Count;

        for (int i = 0; i < n; i++)
        {
            total += Vector3.Distance(pts[i], pts[(i + 1) % n]);
        }

        return total;
    }

    /// <summary>
    /// Calculates 3D polygon area using the cross product method.
    /// Centers points at centroid to eliminate origin offset and precision loss.
    /// </summary>
    private float CalculatePolygonArea(List<Vector3> pts)
    {
        if (pts.Count < 3) return 0f;

        Vector3 centroid = Vector3.zero;
        for (int i = 0; i < pts.Count; i++) centroid += pts[i];
        centroid /= pts.Count;

        Vector3 normal = Vector3.zero;
        int     n      = pts.Count;

        for (int i = 0; i < n; i++)
        {
            Vector3 curr = pts[i]           - centroid;
            Vector3 next = pts[(i + 1) % n] - centroid;
            normal += Vector3.Cross(curr, next);
        }

        return normal.magnitude * 0.5f;
    }

    #endregion

    // ─────────────────────────────────────────────────────────
    #region Formatting

    private string FormatLength(float meters)
    {
        if (_useMetric)
        {
            return meters >= 1f
                ? $"{meters:F2} m"
                : $"{meters * 100f:F1} cm";
        }
        else
        {
            float feet   = meters * 3.28084f;
            float inches = (feet - Mathf.Floor(feet)) * 12f;
            return $"{Mathf.Floor(feet):F0}' {inches:F1}\"";
        }
    }

    private string FormatArea(float squareMeters)
    {
        if (_useMetric)
        {
            return squareMeters >= 1f
                ? $"{squareMeters:F2} m²"
                : $"{squareMeters * 10000f:F1} cm²";
        }
        else
        {
            float sqFeet = squareMeters * 10.7639f;
            return $"{sqFeet:F2} ft²";
        }
    }

    #endregion

    // ─────────────────────────────────────────────────────────
    public void ToggleUnits()
    {
        _useMetric = !_useMetric;
        UpdateMeasurements();
    }
}