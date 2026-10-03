class GardenStyles {
  GardenStyles._();

  static const List<Map<String, String>> all = [
    {'label': 'Shade Garden',                'api': 'Shade Garden',                'image': 'assets/images/garden/Shade_Garden.jpg'},
    {'label': 'Herb and Vegetable Garden',   'api': 'Herb and Vegetable garden',   'image': 'assets/images/garden/Herb_and_Vegetable_Garden.jpg'},
    {'label': 'California Style Garden',     'api': 'California Style Garden',     'image': 'assets/images/garden/California_Style_Garden.jpg'},
    {'label': 'Evergreen Garden',            'api': 'Evergreen Garden',            'image': 'assets/images/garden/Evergreen_Garden.jpg'},
    {'label': 'Aquatic Garden',              'api': 'Aquatic Garden',              'image': 'assets/images/garden/Aquatic_Garden.jpg'},
    {'label': 'Picturesque Garden',          'api': 'Picturesque Garden',          'image': 'assets/images/garden/Picturesque_Garden.jpg'},
    {'label': 'New England Style Garden',    'api': 'New England Style Garden',    'image': 'assets/images/garden/cottage.jpg'},
    {'label': 'Colonial Style Garden',       'api': 'Colonial Style Garden',       'image': 'assets/images/garden/Colonial_Style_Garden.jpg'},
    {'label': 'Terraced Garden',             'api': 'Terraced Garden',             'image': 'assets/images/garden/Terraced_Garden.jpg'},
    {'label': 'Bamboo Garden',               'api': 'Bamboo Garden',               'image': 'assets/images/garden/zen.jpg'},
    {'label': 'Patio Garden',                'api': 'Patio Garden',                'image': 'assets/images/garden/Patio_Garden.jpg'},
    {'label': 'Pollinators-Friendly Garden', 'api': 'Pollinators-Friendly Garden', 'image': 'assets/images/garden/Pollinators_Friendly_Garden.jpg'},
    {'label': 'Drought Resistant Garden',    'api': 'Drought Resistant Garden',    'image': 'assets/images/garden/desert.jpg'},
    {'label': 'Container Garden',            'api': 'Container Garden',            'image': 'assets/images/garden/Container_Garden.jpg'},
    {'label': 'Tropical Garden',             'api': 'Tropical Garden',             'image': 'assets/images/garden/tropical.jpg'},
    {'label': 'Japanese Zen Garden',         'api': 'Japanese Zen Garden',         'image': 'assets/images/garden/zen.jpg'},
    {'label': 'Mediterranean Garden',        'api': 'Mediterranean Garden',        'image': 'assets/images/garden/mediterranean.jpg'},
    {'label': 'Rock Garden',                 'api': 'Rock Garden',                 'image': 'assets/images/garden/Rock_Garden.jpg'},
    {'label': 'Private Courtyard Garden',    'api': 'Private Courtyard Garden',    'image': 'assets/images/garden/tropical.jpg'},
    {'label': 'Outdoor Staircase Garden',    'api': 'Outdoor Staircase Garden',    'image': 'assets/images/garden/Herb_and_Vegetable_Garden.jpg'},
    {'label': 'Mounds or Berms',             'api': 'Mounds or Berms',             'image': 'assets/images/garden/mediterranean.jpg'},
    {'label': 'Therapeutic Garden',          'api': 'Therapeutic Garden',          'image': 'assets/images/garden/zen.jpg'},
    {'label': 'Alpine Garden',               'api': 'Alpine Garden',               'image': 'assets/images/garden/forest.jpg'},
    {'label': 'Feng Shui Garden',            'api': 'Feng Shui Garden',            'image': 'assets/images/garden/feng-shui.jpg'},
    {'label': 'Vertical Garden',             'api': 'Vertical Garden',             'image': 'assets/images/garden/modern_garden.jpg'},
    {'label': 'Chinese Classical Garden',    'api': 'Chinese Classical Garden',    'image': 'assets/images/garden/Chinese_Classical_Garden.jpg'},
    {'label': 'Rain Garden',                 'api': 'Rain Garden',                 'image': 'assets/images/garden/forest.jpg'},
    {'label': 'English Cottage Garden',      'api': 'English Cottage Garden',      'image': 'assets/images/garden/cottage.jpg'},
    {'label': 'French Formal Garden',        'api': 'French Formal Garden',        'image': 'assets/images/garden/Colonial_Style_Garden.jpg'},
    {'label': 'Italian Renaissance Garden',  'api': 'Italian Renaissance Garden',  'image': 'assets/images/garden/mediterranean.jpg'},
    {'label': 'Xeriscaping Garden',          'api': 'Xeriscaping Garden',          'image': 'assets/images/garden/desert.jpg'},
  ];

  static const List<String> recommended = [
    'Japanese Zen Garden',
    'Tropical Garden',
    'Mediterranean Garden',
    'English Cottage Garden',
    'Aquatic Garden',
  ];

  static List<Map<String, String>> get recommendedItems =>
      all.where((g) => recommended.contains(g['label'])).toList();

  static List<Map<String, String>> get allItems =>
      all.where((g) => !recommended.contains(g['label'])).toList();

  static String? apiValue(String label) =>
      all.firstWhere(
            (g) => g['label'] == label,
        orElse: () => {},
      )['api'];

  static String? label(String apiValue) =>
      all.firstWhere(
            (g) => g['api'] == apiValue,
        orElse: () => {},
      )['label'];
}
