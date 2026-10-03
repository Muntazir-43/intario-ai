using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class FurnitureCollectionButtonView : MonoBehaviour
{
    [SerializeField] private Image thumbnailImage;
    [SerializeField] private TMP_Text label;
    [SerializeField] private Button button;

    public Image ThumbnailImage => thumbnailImage;
    public TMP_Text Label => label;
    public Button Button => button;
}