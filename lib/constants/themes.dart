class SeasonalThemes {
  SeasonalThemes._();

  static const List<Map<String, String>> all = [
    {'label': 'Christmas',       'api': 'SPECIALITY_DECOR_2', 'emoji': '🎄'},
    {'label': 'Halloween',       'api': 'SPECIALITY_DECOR_1', 'emoji': '🎃'},
    {'label': 'Thanksgiving',    'api': 'SPECIALITY_DECOR_3', 'emoji': '🦃'},
    {'label': 'Fall Season',     'api': 'SPECIALITY_DECOR_4', 'emoji': '🍂'},
    {'label': 'Spring Season',   'api': 'SPECIALITY_DECOR_5', 'emoji': '🌸'},
    {'label': 'Summer Season',   'api': 'SPECIALITY_DECOR_6', 'emoji': '☀️'},
    {'label': 'Winter Season',   'api': 'SPECIALITY_DECOR_7', 'emoji': '❄️'},
  ];

  static String? apiValue(String label) =>
      all.firstWhere(
            (t) => t['label'] == label,
        orElse: () => {},
      )['api'];

  static String? label(String apiValue) =>
      all.firstWhere(
            (t) => t['api'] == apiValue,
        orElse: () => {},
      )['label'];
}
