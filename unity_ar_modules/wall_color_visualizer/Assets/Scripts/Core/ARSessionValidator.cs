using System.Collections;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using TMPro;

/// <summary>
/// Monitors AR session state and displays real-time
/// status feedback during development/testing.
/// </summary>
public class ARSessionValidator : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private ARSession _arSession;
    [SerializeField] private TextMeshProUGUI _statusText;

    [Header("Settings")]
    [SerializeField] private bool _showDebugText = true;

    private void OnEnable()
    {
        ARSession.stateChanged += OnARSessionStateChanged;
    }

    private void OnDisable()
    {
        ARSession.stateChanged -= OnARSessionStateChanged;
    }

    private void Start()
    {
        StartCoroutine(CheckARSupport());
    }

    private IEnumerator CheckARSupport()
    {
        // Wait until availability check is complete
        if (ARSession.state == ARSessionState.None ||
            ARSession.state == ARSessionState.CheckingAvailability)
        {
            yield return ARSession.CheckAvailability();
        }

        switch (ARSession.state)
        {
            case ARSessionState.Unsupported:
                UpdateStatus("❌ AR is NOT supported on this device.");
                yield break;

            case ARSessionState.NeedsInstall:
                UpdateStatus("⚠️ ARCore needs to be installed. Requesting...");
                yield return ARSession.Install();

                if (ARSession.state == ARSessionState.Unsupported)
                {
                    UpdateStatus("❌ Installation failed or was rejected.");
                    yield break;
                }
                UpdateStatus("✅ ARCore installed successfully.");
                break;

            case ARSessionState.Ready:
            case ARSessionState.SessionInitializing:
            case ARSessionState.SessionTracking:
                UpdateStatus("✅ AR Ready — move device to detect walls.");
                break;

            default:
                UpdateStatus($"AR State: {ARSession.state}");
                break;
        }
    }

    private void OnARSessionStateChanged(ARSessionStateChangedEventArgs args)
    {
        UpdateStatus($"AR State → {args.state}");

        if (args.state == ARSessionState.SessionTracking)
            UpdateStatus("✅ Tracking active — move device to detect walls.");
    }

    private void UpdateStatus(string message)
    {
        Debug.Log($"[ARSessionValidator] {message}");

        if (_showDebugText && _statusText != null)
            _statusText.text = message;
    }
}