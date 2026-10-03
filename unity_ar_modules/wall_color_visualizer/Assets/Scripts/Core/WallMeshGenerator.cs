using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Listens for the GO event from PointPlacementManager,
/// then generates a flat procedural mesh covering the wall
/// polygon defined by the placed points.
/// Uses ear-clipping triangulation to support any polygon shape.
/// </summary>
[RequireComponent(typeof(PointPlacementManager))]
public class WallMeshGenerator : MonoBehaviour
{
    // ── Inspector ─────────────────────────────────────────────
    [Header("Mesh Settings")]
    [SerializeField] private Material _wallMeshMat;
    [SerializeField] private float    _meshOffsetFromWall = 0.002f;

    [Header("Generated Object")]
    [SerializeField] private string _meshObjectName = "GeneratedWallMesh";

    // ── Runtime ───────────────────────────────────────────────
    private PointPlacementManager _placementManager;
    private GameObject            _meshObject;

    // Stored material instance — the single source of truth
    // TextureManager modifies this directly
    private Material     _activeMaterial;
    private MeshRenderer _meshRenderer;

    // ─────────────────────────────────────────────────────────
    private void Awake()
    {
        _placementManager = GetComponent<PointPlacementManager>();
    }

    private void Start()
    {
        _placementManager.OnGoConfirmed += HandleGoConfirmed;
    }

    private void OnDestroy()
    {
        if (_placementManager != null)
            _placementManager.OnGoConfirmed -= HandleGoConfirmed;
    }

    // ─────────────────────────────────────────────────────────
    private void HandleGoConfirmed(IReadOnlyList<Vector3> points)
    {
        if (points.Count < 3)
        {
            Debug.LogError("[WallMesh] Need at least 3 points.");
            return;
        }

        if (_meshObject != null)
            Destroy(_meshObject);

        // Reset active material so a fresh one is created
        _activeMaterial = null;

        GenerateWallMesh(points);
    }

    // ─────────────────────────────────────────────────────────
    #region Mesh Generation

    private void GenerateWallMesh(IReadOnlyList<Vector3> worldPoints)
    {
        // ── Step 1: Compute best-fit plane ───────────────────
        Vector3 centroid = ComputeCentroid(worldPoints);
        Vector3 normal   = ComputeBestFitNormal(worldPoints, centroid);

        // Ensure normal faces towards the camera (out of the wall towards viewer)
        Camera mainCam = Camera.main;
        if (mainCam != null)
        {
            Vector3 toWall = centroid - mainCam.transform.position;
            if (Vector3.Dot(normal, toWall) > 0)
                normal = -normal;
        }
        else if (Vector3.Dot(normal, Vector3.forward) > 0)
        {
            normal = -normal;
        }

        // ── Step 2: Build local axes on the wall plane ───────
        Vector3 right = Vector3.Cross(Vector3.up, normal).normalized;
        if (right.sqrMagnitude < 0.001f)
            right = Vector3.Cross(Vector3.forward, normal).normalized;

        Vector3 up = Vector3.Cross(normal, right).normalized;

        // ── Step 3: Project world points → 2D plane coords ───
        List<Vector2> poly2D = new List<Vector2>(worldPoints.Count);
        foreach (Vector3 wp in worldPoints)
        {
            Vector3 local = wp - centroid;
            poly2D.Add(new Vector2(
                Vector3.Dot(local, right),
                Vector3.Dot(local, up)
            ));
        }

        // ── Step 4: Triangulate ───────────────────────────────
        List<int> triangles = EarClipTriangulate(poly2D);

        if (triangles == null || triangles.Count == 0)
        {
            Debug.LogError("[WallMesh] Triangulation failed.");
            return;
        }

        // ── Step 5: Compute UV bounds ─────────────────────────
        Vector2 uvMin = poly2D[0];
        Vector2 uvMax = poly2D[0];
        foreach (Vector2 p in poly2D)
        {
            uvMin = Vector2.Min(uvMin, p);
            uvMax = Vector2.Max(uvMax, p);
        }

        // ── Step 6: Build vertices + UVs + normals ────────────
        Vector3[] vertices = new Vector3[poly2D.Count];
        Vector2[] uvs      = new Vector2[poly2D.Count];
        Vector3[] normals  = new Vector3[poly2D.Count];

        Vector3 offset = normal * _meshOffsetFromWall;

        for (int i = 0; i < poly2D.Count; i++)
        {
            vertices[i] = centroid
                + right * poly2D[i].x
                + up    * poly2D[i].y
                + offset;

            // Metric UV mapping: 1 UV unit = 1 real-world meter.
            // Preserves exact 1:1 physical aspect ratio regardless of wall width or height.
            uvs[i] = new Vector2(
                poly2D[i].x - uvMin.x,
                poly2D[i].y - uvMin.y
            );

            normals[i] = normal;
        }

        // ── Step 7: Assemble Unity Mesh ───────────────────────
        Mesh mesh      = new Mesh();
        mesh.name      = "WallPolygonMesh";
        mesh.vertices  = vertices;
        mesh.triangles = triangles.ToArray();
        mesh.uv        = uvs;
        mesh.normals   = normals;
        mesh.RecalculateBounds();
        mesh.RecalculateTangents();

        // ── Step 8: Create scene GameObject ──────────────────
        _meshObject = new GameObject(_meshObjectName);

        MeshFilter mf = _meshObject.AddComponent<MeshFilter>();
        _meshRenderer = _meshObject.AddComponent<MeshRenderer>();

        mf.mesh = mesh;

        // Create a NEW material instance from the source material
        // Store it in _activeMaterial — this is the ONLY reference
        // TextureManager will use.
        if (_wallMeshMat != null)
            _activeMaterial = new Material(_wallMeshMat);
        else
            _activeMaterial = CreateFallbackMaterial();

        // Ensure Cull Off so the wall mesh is never culled by winding order or viewing angle
        _activeMaterial.SetFloat("_Cull", 0f);

        // Assign to renderer
        _meshRenderer.sharedMaterial = _activeMaterial;
        Debug.Log($"[WallMesh] Mesh generated — " +
                  $"{vertices.Length} verts, " +
                  $"{triangles.Count / 3} tris. " +
                  $"Material: {_activeMaterial.name}");
    }

    #endregion

    // ─────────────────────────────────────────────────────────
    #region Geometry Helpers

    private Vector3 ComputeCentroid(IReadOnlyList<Vector3> pts)
    {
        Vector3 sum = Vector3.zero;
        foreach (Vector3 p in pts) sum += p;
        return sum / pts.Count;
    }

    private Vector3 ComputeBestFitNormal(
        IReadOnlyList<Vector3> pts, Vector3 centroid)
    {
        Vector3 normal = Vector3.zero;
        int n = pts.Count;
        for (int i = 0; i < n; i++)
        {
            Vector3 curr = pts[i]         - centroid;
            Vector3 next = pts[(i+1) % n] - centroid;
            normal += Vector3.Cross(curr, next);
        }
        return normal.normalized;
    }

    #endregion

    // ─────────────────────────────────────────────────────────
    #region Ear-Clipping Triangulation

    private List<int> EarClipTriangulate(List<Vector2> poly)
    {
        List<int> result  = new List<int>();
        List<int> indices = new List<int>();

        int n = poly.Count;
        for (int i = 0; i < n; i++) indices.Add(i);

        if (ComputeSignedArea(poly) < 0)
            indices.Reverse();

        int safety = n * n;
        int iter   = 0;

        while (indices.Count > 3 && iter++ < safety)
        {
            bool earFound = false;
            int  count    = indices.Count;

            for (int i = 0; i < count; i++)
            {
                int iPrev = indices[(i - 1 + count) % count];
                int iCurr = indices[i];
                int iNext = indices[(i + 1) % count];

                Vector2 a = poly[iPrev];
                Vector2 b = poly[iCurr];
                Vector2 c = poly[iNext];

                if (Cross2D(a, b, c) <= 0) continue;

                bool hasPointInside = false;
                for (int j = 0; j < count; j++)
                {
                    int idx = indices[j];
                    if (idx == iPrev || idx == iCurr || idx == iNext)
                        continue;
                    if (PointInTriangle(poly[idx], a, b, c))
                    {
                        hasPointInside = true;
                        break;
                    }
                }

                if (hasPointInside) continue;

                result.Add(iPrev);
                result.Add(iCurr);
                result.Add(iNext);

                indices.RemoveAt(i);
                earFound = true;
                break;
            }

            if (!earFound)
            {
                Debug.LogWarning("[WallMesh] Ear-clip stalled.");
                break;
            }
        }

        if (indices.Count == 3)
        {
            result.Add(indices[0]);
            result.Add(indices[1]);
            result.Add(indices[2]);
        }

        return result;
    }

    private float ComputeSignedArea(List<Vector2> poly)
    {
        float area = 0f;
        int   n    = poly.Count;
        for (int i = 0; i < n; i++)
        {
            Vector2 curr = poly[i];
            Vector2 next = poly[(i + 1) % n];
            area += (curr.x * next.y) - (next.x * curr.y);
        }
        return area * 0.5f;
    }

    private float Cross2D(Vector2 a, Vector2 b, Vector2 c)
    {
        return (b.x - a.x) * (c.y - a.y)
             - (b.y - a.y) * (c.x - a.x);
    }

    private bool PointInTriangle(
        Vector2 p, Vector2 a, Vector2 b, Vector2 c)
    {
        float d1 = Cross2D(p, a, b);
        float d2 = Cross2D(p, b, c);
        float d3 = Cross2D(p, c, a);

        bool hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
        bool hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);

        return !(hasNeg && hasPos);
    }

    #endregion

    // ─────────────────────────────────────────────────────────
    #region Fallback Material

    private Material CreateFallbackMaterial()
    {
        Material mat = new Material(
            Shader.Find("Universal Render Pipeline/Lit")
        );
        mat.color = new Color(0.9f, 0.9f, 0.9f, 1f);
        mat.name  = "WallMeshFallback";
        return mat;
    }

    #endregion

    // ─────────────────────────────────────────────────────────
    /// <summary>
    /// Returns the single stored material instance.
    /// This is the ONLY correct way to get the wall material.
    /// Always returns the same object — no copies created.
    /// </summary>
    public Material GetWallMaterial()
    {
        if (_activeMaterial == null)
            Debug.LogWarning("[WallMesh] _activeMaterial is null. " +
                             "Has GO been pressed?");

        return _activeMaterial;
    }

    /// <summary>
    /// Applies the specified wallpaper texture and tiling directly to the wall mesh.
    /// Re-binds to the MeshRenderer to ensure graphics drivers (Vulkan/GLES) update immediately.
    /// </summary>
    public void ApplyWallpaper(Texture2D texture, Vector2 tiling)
    {
        if (texture == null)
        {
            Debug.LogWarning("[WallMesh] ApplyWallpaper called with null texture.");
            return;
        }

        if (_meshObject == null)
        {
            Debug.LogWarning("[WallMesh] Cannot apply wallpaper — wall mesh GameObject does not exist yet.");
            return;
        }

        if (_meshRenderer == null)
            _meshRenderer = _meshObject.GetComponent<MeshRenderer>();

        if (_meshRenderer == null)
        {
            Debug.LogError("[WallMesh] No MeshRenderer found on wall mesh!");
            return;
        }

        if (_activeMaterial == null)
        {
            if (_meshRenderer.sharedMaterial != null)
                _activeMaterial = _meshRenderer.sharedMaterial;
            else if (_wallMeshMat != null)
                _activeMaterial = new Material(_wallMeshMat);
            else
                _activeMaterial = CreateFallbackMaterial();
        }

        // Apply texture and tiling to mainTexture and _BaseMap (URP Lit)
        _activeMaterial.mainTexture = texture;

        if (_activeMaterial.HasProperty("_BaseMap"))
        {
            _activeMaterial.SetTexture("_BaseMap", texture);
            _activeMaterial.SetTextureScale("_BaseMap", tiling);
            _activeMaterial.SetTextureOffset("_BaseMap", Vector2.zero);
        }

        _activeMaterial.mainTextureScale  = tiling;
        _activeMaterial.mainTextureOffset = Vector2.zero;

        // Force MeshRenderer to re-apply sharedMaterial so Vulkan pipeline refreshes
        _meshRenderer.sharedMaterial = _activeMaterial;

        Debug.Log($"[WallMesh] Applied wallpaper '{texture.name}' ({texture.width}x{texture.height}) | Tiling: {tiling}");
    }

    /// <summary>
    /// Updates texture tiling directly on the active material without reassigning
    /// the renderer material, preventing Vulkan/GLES batch recreation during slider drags.
    /// </summary>
    public void SetTiling(Vector2 tiling)
    {
        if (_activeMaterial == null) return;

        _activeMaterial.mainTextureScale = tiling;
        if (_activeMaterial.HasProperty("_BaseMap"))
        {
            _activeMaterial.SetTextureScale("_BaseMap", tiling);
        }
    }

    /// <summary>
    /// Destroys the mesh and clears the material reference.
    /// </summary>
    public void DestroyMesh()
    {
        if (_meshObject != null)
        {
            Destroy(_meshObject);
            _meshObject = null;
        }

        _meshRenderer   = null;
        _activeMaterial = null;
        Debug.Log("[WallMesh] Mesh and material cleared.");
    }
}