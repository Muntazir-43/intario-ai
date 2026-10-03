using UnityEngine;
using UnityEngine.XR.ARFoundation;

public class PlaneVisibilityManager : MonoBehaviour
{
    [SerializeField] private ARPlaneManager planeManager;
    private bool planesVisible = true;

    private void OnEnable()
    {
        planeManager.trackablesChanged.AddListener(OnPlanesChanged);
    }

    private void OnDisable()
    {
        planeManager.trackablesChanged.RemoveListener(OnPlanesChanged);
    }

    private void OnPlanesChanged(ARTrackablesChangedEventArgs<ARPlane> args)
    {
        // Any newly detected plane inherits the current visibility state,
        // so planes discovered after placement don't pop back in.
        foreach (var plane in args.added)
            SetPlaneVisible(plane, planesVisible);
    }

    public void SetPlanesVisible(bool visible)
    {
        planesVisible = visible;
        foreach (var plane in planeManager.trackables)
            SetPlaneVisible(plane, visible);
    }

    private void SetPlaneVisible(ARPlane plane, bool visible)
   {
       // ARPlaneMeshVisualizer.Update() re-enables MeshRenderer/LineRenderer every
       // frame on its own — disabling those renderers directly gets silently
       // overridden a frame later. Disabling the whole plane GameObject stops
       // that Update() from running at all, so nothing fights us back.
       plane.gameObject.SetActive(visible);
   }
}