using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using System.Collections.Generic;
using UnityEngine.InputSystem.EnhancedTouch;
using Touch = UnityEngine.InputSystem.EnhancedTouch.Touch;

public class FurnitureController : MonoBehaviour
{
    private FurnitureSpawner spawner;
    private ARRaycastManager raycastManager;

    public const float MinScale = 0.3f;
    public const float MaxScale = 2.5f;

    private static readonly List<ARRaycastHit> hits = new List<ARRaycastHit>();

    public void Initialize(FurnitureSpawner owner)
    {
        spawner = owner;
        raycastManager = FindAnyObjectByType<ARRaycastManager>();
    }

    public void SetHighlighted(bool on)
    {
        foreach (var renderer in GetComponentsInChildren<Renderer>())
        {
            var color = renderer.material.color;
            color.a = on ? 1f : 0.9f;
            renderer.material.color = color;
        }
    }

    private void Update()
{
    if (SelectionManager.Instance.SelectedObject != gameObject) return;

    var touches = Touch.activeTouches;
    if (touches.Count == 1 && !IsPointerOverUI(touches[0].screenPosition))
    {
        HandleMove(touches[0]);
    }
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

    private void HandleMove(Touch touch)
    {
        if (touch.phase != UnityEngine.InputSystem.TouchPhase.Moved &&
            touch.phase != UnityEngine.InputSystem.TouchPhase.Stationary) return;

        if (raycastManager.Raycast(touch.screenPosition, hits, TrackableType.PlaneWithinPolygon))
        {
            Pose hitPose = hits[0].pose;
            transform.position = hitPose.position;
        }
    }

    public void DeleteSelf()
    {
        spawner.ClearCurrentFurniture();
    }
}