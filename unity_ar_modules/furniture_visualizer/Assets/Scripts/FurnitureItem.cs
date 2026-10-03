using UnityEngine;

[CreateAssetMenu(fileName = "FurnitureItem", menuName = "AR Furniture/Furniture Item")]
public class FurnitureItem : ScriptableObject
{
    public string displayName;
    public Sprite thumbnail;
    public GameObject prefab;          // the placeable 3D model prefab
    [Tooltip("Real-world height in meters, used for default scale sanity-checking.")]
    public float realWorldHeightMeters = 1.0f;
}