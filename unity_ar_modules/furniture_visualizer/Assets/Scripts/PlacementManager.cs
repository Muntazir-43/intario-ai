using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.EnhancedTouch;
using Touch = UnityEngine.InputSystem.EnhancedTouch.Touch;

[RequireComponent(typeof(ARRaycastManager))]
public class PlacementManager : MonoBehaviour
{
    [SerializeField] private ARPlaneManager planeManager;
    [SerializeField] private ARAnchorManager anchorManager;
    [SerializeField] private GameObject placementIndicator;
    [SerializeField] private FurnitureSpawner furnitureSpawner;
    [SerializeField] private Camera arCamera;

    private ARRaycastManager raycastManager;
    private static readonly List<ARRaycastHit> hits = new List<ARRaycastHit>();

    private Pose currentIndicatorPose;
    private bool indicatorIsValid;

    private void Awake()
    {
        raycastManager = GetComponent<ARRaycastManager>();
    }

    private void OnEnable()
    {
        EnhancedTouchSupport.Enable();
    }

    private void OnDisable()
    {
        EnhancedTouchSupport.Disable();
    }

private void Update()
{
    UpdateIndicatorAndHandleTap();
}

private void UpdateIndicatorAndHandleTap()
{
    if (Touch.activeTouches.Count == 0)
    {
        placementIndicator.SetActive(false);
        return;
    }

    var touch = Touch.activeTouches[0];

    if (IsPointerOverUI(touch.screenPosition))
    {
        placementIndicator.SetActive(false);
        return;
    }

    if (raycastManager.Raycast(touch.screenPosition, hits, TrackableType.PlaneWithinPolygon))
    {
        Pose hitPose = hits[0].pose;
        placementIndicator.SetActive(true);
        placementIndicator.transform.SetPositionAndRotation(hitPose.position, hitPose.rotation);

        if (touch.phase == UnityEngine.InputSystem.TouchPhase.Began)
        {
            furnitureSpawner.SpawnAtPose(hitPose);
        }
    }
    else
    {
        placementIndicator.SetActive(false);
    }
}

    private void HandleTap()
    {
        if (!indicatorIsValid) return;
        if (Touch.activeTouches.Count == 0) return;

        var touch = Touch.activeTouches[0];
        if (touch.phase != UnityEngine.InputSystem.TouchPhase.Began) return;

        // Ignore taps that land on UI (furniture collection panel, buttons, etc.)
        if (IsPointerOverUI(touch.screenPosition)) return;

        furnitureSpawner.SpawnAtPose(currentIndicatorPose);
    }

    private bool IsPointerOverUI(Vector2 screenPosition)
    {
        var eventSystem = UnityEngine.EventSystems.EventSystem.current;
        if (eventSystem == null) return false;

        var pointerData = new UnityEngine.EventSystems.PointerEventData(eventSystem)
        {
            position = screenPosition
        };
        var results = new List<UnityEngine.EventSystems.RaycastResult>();
        eventSystem.RaycastAll(pointerData, results);
        return results.Count > 0;
    }
}