class DesignStyles {
  DesignStyles._();

  static const List<Map<String, String>> all = [
    {'label': 'Modern',               'api': 'modern',            'image': 'assets/images/styles/modern.jpg'},
    {'label': 'Minimalist',           'api': 'minimalist',        'image': 'assets/images/styles/minimalist.jpg'},
    {'label': 'Scandinavian',         'api': 'scandinavian',      'image': 'assets/images/styles/scandinavian.jpg'},
    {'label': 'Industrial',           'api': 'industrial',        'image': 'assets/images/styles/industrial.jpg'},
    {'label': 'Contemporary',         'api': 'contemporary',      'image': 'assets/images/styles/contemporary.jpg'},
    {'label': 'Rustic',               'api': 'rustic',            'image': 'assets/images/styles/rustic.jpg'},
    {'label': 'Boho',                 'api': 'boho',              'image': 'assets/images/styles/bohemian.jpg'},
    {'label': 'Traditional',          'api': 'traditional',       'image': 'assets/images/styles/traditional.jpg'},
    {'label': 'Art Deco',             'api': 'artdeco',           'image': 'assets/images/styles/luxury.jpg'},
    {'label': 'Mid-Century Modern',   'api': 'midcenturymodern',  'image': 'assets/images/styles/Mid-Century.jpg'},
    {'label': 'Coastal',              'api': 'coastal',           'image': 'assets/images/styles/scandinavian.jpg'},
    {'label': 'Tropical',             'api': 'tropical',          'image': 'assets/images/styles/Tropical.jpg'},
    {'label': 'Eclectic',             'api': 'eclectic',          'image': 'assets/images/styles/bohemian.jpg'},
    {'label': 'French Country',       'api': 'frenchcountry',     'image': 'assets/images/styles/rustic.jpg'},
    {'label': 'Shabby Chic',          'api': 'shabbychic',        'image': 'assets/images/styles/minimalist.jpg'},
    {'label': 'Vintage',              'api': 'vintage',           'image': 'assets/images/styles/Vintage.jpg'},
    {'label': 'Country',              'api': 'country',           'image': 'assets/images/styles/Country.jpg'},
    {'label': 'Asian Zen',            'api': 'asian_zen',         'image': 'assets/images/styles/japandi.jpg'},
    {'label': 'Hollywood Regency',    'api': 'hollywoodregency',  'image': 'assets/images/styles/luxury.jpg'},
    {'label': 'Bauhaus',              'api': 'bauhaus',           'image': 'assets/images/styles/Bauhaus.jpg'},
    {'label': 'Mediterranean',        'api': 'mediterranean',     'image': 'assets/images/styles/Mediterranean.jpg'},
    {'label': 'Farmhouse',            'api': 'farmhouse',         'image': 'assets/images/styles/rustic.jpg'},
    {'label': 'Victorian',            'api': 'victorian',         'image': 'assets/images/styles/Victorian.jpg'},
    {'label': 'Gothic',               'api': 'gothic',            'image': 'assets/images/styles/Gothic.jpg'},
    {'label': 'Moroccan',             'api': 'moroccan',          'image': 'assets/images/styles/Moroccan.jpg'},
    {'label': 'Southwestern',         'api': 'southwestern',      'image': 'assets/images/styles/Southwestern.jpg'},
    {'label': 'Transitional',         'api': 'transitional',      'image': 'assets/images/styles/contemporary.jpg'},
    {'label': 'Maximalist',           'api': 'maximalist',        'image': 'assets/images/styles/Maximalist.jpg'},
    {'label': 'Arabic',               'api': 'arabic',            'image': 'assets/images/styles/arabic.jpg'},
    {'label': 'Japandi',              'api': 'japandi',           'image': 'assets/images/styles/japandi.jpg'},
    {'label': 'Retro Futurism',       'api': 'retrofuturism',     'image': 'assets/images/styles/industrial.jpg'},
    {'label': 'Art Nouveau',          'api': 'artnouveau',        'image': 'assets/images/styles/Art_Nouveau.jpg'},
    {'label': 'Urban Modern',         'api': 'urbanmodern',       'image': 'assets/images/styles/modern.jpg'},
    {'label': 'Wabi-Sabi',            'api': 'wabi_sabi',         'image': 'assets/images/styles/japandi.jpg'},
    {'label': 'Grandmillennial',      'api': 'grandmillennial',   'image': 'assets/images/styles/traditional.jpg'},
    {'label': 'Coastal Grandmother',  'api': 'coastalgrandmother', 'image': 'assets/images/styles/scandinavian.jpg'},
    {'label': 'New Traditional',      'api': 'newtraditional',    'image': 'assets/images/styles/traditional.jpg'},
    {'label': 'Cottagecore',          'api': 'cottagecore',       'image': 'assets/images/styles/rustic.jpg'},
    {'label': 'Luxe Modern',          'api': 'luxemodern',        'image': 'assets/images/styles/Art_Nouveau.jpg'},
    {'label': 'High Tech',            'api': 'high_tech',         'image': 'assets/images/styles/High_Tech.jpg'},
    {'label': 'Tuscan',               'api': 'tuscan',            'image': 'assets/images/styles/Tuscan.jpg'},
    {'label': 'Cabin',                'api': 'cabin',             'image': 'assets/images/styles/cabin.jpg'},
    {'label': 'Global',               'api': 'global',            'image': 'assets/images/styles/bohemian.jpg'},
    {'label': 'European Classic',     'api': 'europeanclassic',   'image': 'assets/images/styles/European_Classic.jpg'},
    {'label': 'Neo Traditional',      'api': 'neotraditional',    'image': 'assets/images/styles/traditional.jpg'},
    {'label': 'Desert Modern',        'api': 'desertmodern',      'image': 'assets/images/styles/modern.jpg'},
    {'label': 'Warm Minimalist',      'api': 'warmminimalist',    'image': 'assets/images/styles/Warm_Minimalist.jpg'},
    {'label': 'Organic Modern',       'api': 'organicmodern',     'image': 'assets/images/styles/minimalist.jpg'},
    {'label': 'Industrial Chic',      'api': 'industrialchic',    'image': 'assets/images/styles/industrial.jpg'},
    {'label': 'Modern Farmhouse',     'api': 'modernfarmhouse',   'image': 'assets/images/styles/modern.jpg'},
  ];

  static const List<String> recommended = [
    'Modern',
    'Minimalist',
    'Scandinavian',
    'Industrial',
    'Contemporary',
    'Rustic',
  ];

  static List<Map<String, String>> get recommendedItems =>
      all.where((s) => recommended.contains(s['label'])).toList();

  static List<Map<String, String>> get allItems =>
      all.where((s) => !recommended.contains(s['label'])).toList();

  static String? apiValue(String label) =>
      all.firstWhere(
            (s) => s['label'] == label,
        orElse: () => {},
      )['api'];

  static String? label(String apiValue) =>
      all.firstWhere(
            (s) => s['api'] == apiValue,
        orElse: () => {},
      )['label'];
}
