class ColorSchemes {
  ColorSchemes._();

  static const List<Map<String, dynamic>> all = [
    {
      'label': 'White, Pops of Color',
      'api':   'COLOR_SCHEME_4',
      'colors': [0xFFFF6B6B, 0xFF00C9A7, 0xFFFFD93D, 0xFFFFFFFF],
    },
    {
      'label': 'Gray, Sand, Blue',
      'api':   'COLOR_SCHEME_2',
      'colors': [0xFF9CA3AF, 0xFFD4B896, 0xFF3B82F6, 0xFFFFFFFF],
    },
    {
      'label': 'Blue, Beige',
      'api':   'COLOR_SCHEME_8',
      'colors': [0xFF3B82F6, 0xFF93C5FD, 0xFFD4B896, 0xFFF5F0E8],
    },
    {
      'label': 'Black, White',
      'api':   'COLOR_SCHEME_19',
      'colors': [0xFF000000, 0xFF333333, 0xFFFFFFFF, 0xFFF5F5F5],
    },
    {
      'label': 'Moss Green, Tan, White',
      'api':   'COLOR_SCHEME_1',
      'colors': [0xFF6B8E5E, 0xFF8B7355, 0xFFFFFFFF, 0xFFF0EBE0],
    },
    {
      'label': 'Hunter Green, Red',
      'api':   'COLOR_SCHEME_3',
      'colors': [0xFF2D5016, 0xFF3D6B1F, 0xFFDC2626, 0xFFEF4444],
    },
    {
      'label': 'Blue, Neon',
      'api':   'COLOR_SCHEME_5',
      'colors': [0xFF1D4ED8, 0xFF3B82F6, 0xFF00FF88, 0xFF39FF14],
    },
    {
      'label': 'Light Blue, Emerald',
      'api':   'COLOR_SCHEME_6',
      'colors': [0xFF7DD3FC, 0xFFBAE6FD, 0xFF10B981, 0xFF34D399],
    },
    {
      'label': 'Blue, Grass Green',
      'api':   'COLOR_SCHEME_7',
      'colors': [0xFF2563EB, 0xFF3B82F6, 0xFF16A34A, 0xFF22C55E],
    },
    {
      'label': 'Gray, Brown',
      'api':   'COLOR_SCHEME_9',
      'colors': [0xFF6B7280, 0xFF9CA3AF, 0xFF92400E, 0xFFB45309],
    },
    {
      'label': 'Black, Red',
      'api':   'COLOR_SCHEME_10',
      'colors': [0xFF000000, 0xFF1F1F1F, 0xFFDC2626, 0xFFEF4444],
    },
    {
      'label': 'Gray-Green, White, Black',
      'api':   'COLOR_SCHEME_11',
      'colors': [0xFF6B8E6E, 0xFF9DB89E, 0xFFFFFFFF, 0xFF000000],
    },
    {
      'label': 'Blue, Gray, Taupe',
      'api':   'COLOR_SCHEME_12',
      'colors': [0xFF2563EB, 0xFF6B7280, 0xFF9C8B7A, 0xFFD4C5B0],
    },
    {
      'label': 'Black, Navy',
      'api':   'COLOR_SCHEME_13',
      'colors': [0xFF000000, 0xFF0F172A, 0xFF1E3A5F, 0xFF1D4ED8],
    },
    {
      'label': 'Emerald, Tan',
      'api':   'COLOR_SCHEME_14',
      'colors': [0xFF059669, 0xFF10B981, 0xFFD4B896, 0xFFF5E6D3],
    },
    {
      'label': 'Forest Green, Light Gray',
      'api':   'COLOR_SCHEME_15',
      'colors': [0xFF14532D, 0xFF166534, 0xFFD1D5DB, 0xFFF3F4F6],
    },
    {
      'label': 'Yellow, Gray',
      'api':   'COLOR_SCHEME_16',
      'colors': [0xFFEAB308, 0xFFFBBF24, 0xFF6B7280, 0xFF9CA3AF],
    },
    {
      'label': 'Pink, Green',
      'api':   'COLOR_SCHEME_17',
      'colors': [0xFFEC4899, 0xFFF9A8D4, 0xFF16A34A, 0xFF86EFAC],
    },
    {
      'label': 'Blush Pink, Black',
      'api':   'COLOR_SCHEME_18',
      'colors': [0xFFFBCFE8, 0xFFF9A8D4, 0xFF000000, 0xFF1F1F1F],
    },
    {
      'label': 'Blue, White',
      'api':   'COLOR_SCHEME_20',
      'colors': [0xFF1D4ED8, 0xFF3B82F6, 0xFFFFFFFF, 0xFFF0F9FF],
    },
  ];

  static const List<String> recommended = [
    'White, Pops of Color',
    'Gray, Sand, Blue',
    'Blue, Beige',
    'Black, White',
  ];

  static List<Map<String, dynamic>> get recommendedItems =>
      all.where((c) => recommended.contains(c['label'])).toList();

  static List<Map<String, dynamic>> get allItems =>
      all.where((c) => !recommended.contains(c['label'])).toList();

  static String? apiValue(String label) =>
      all.firstWhere(
            (c) => c['label'] == label,
        orElse: () => {},
      )['api'] as String?;

  static String? label(String apiValue) =>
      all.firstWhere(
            (c) => c['api'] == apiValue,
        orElse: () => {},
      )['label'] as String?;
}
