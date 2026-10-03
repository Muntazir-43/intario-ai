using UnityEngine;
using UnityEngine.XR.ARFoundation;

/// <summary>
/// Configures runtime performance settings for smooth AR.
/// Targets 60fps with battery-conscious settings.
/// </summary>
public class ARPerformanceManager : MonoBehaviour
{
    [Header("Frame Rate")]
    [SerializeField] private int _targetFrameRate = 60;

    [Header("AR Settings")]
    [SerializeField] private ARSession      _arSession;
    [SerializeField] private ARCameraManager _cameraManager;

    [Header("Screen")]
    [SerializeField] private bool _preventScreenSleep = true;

    private void Awake()
    {
        // Frame rate
        Application.targetFrameRate = _targetFrameRate;
        QualitySettings.vSyncCount  = 0;

        // Screen
        if (_preventScreenSleep)
            Screen.sleepTimeout = SleepTimeout.NeverSleep;

        // Lock to portrait for consistent AR plane detection
        Screen.orientation = ScreenOrientation.Portrait;
    }

    private void Start()
    {
        ConfigureCameraSettings();
    }

    private void ConfigureCameraSettings()
    {
        if (_cameraManager == null) return;

#if UNITY_ANDROID
        // Request 60fps camera on Android
        _cameraManager.requestedFacingDirection =
            CameraFacingDirection.World;
#endif
    }

    private void OnApplicationPause(bool paused)
    {
        // Release camera when app is backgrounded
        if (_cameraManager != null)
            _cameraManager.enabled = !paused;
    }
}