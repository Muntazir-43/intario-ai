using UnityEngine;

[CreateAssetMenu(fileName = "FurnitureCatalog", menuName = "AR Furniture/Furniture Catalog")]
public class FurnitureCatalog : ScriptableObject
{
    public FurnitureItem[] items;
}