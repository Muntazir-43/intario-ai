class RoomTypes {
  RoomTypes._();

  static const List<Map<String, String>> all = [
    {'label': 'Living Room',    'api': 'livingroom',     'emoji': '🛋️'},
    {'label': 'Bedroom',        'api': 'bedroom',        'emoji': '🛏️'},
    {'label': 'Kitchen',        'api': 'kitchen',        'emoji': '🍳'},
    {'label': 'Bathroom',       'api': 'bathroom',       'emoji': '🚿'},
    {'label': 'Office',         'api': 'office',         'emoji': '💼'},
    {'label': 'Dining Room',    'api': 'diningroom',     'emoji': '🍽️'},
    {'label': 'Kids Room',      'api': 'kidsroom',       'emoji': '🧸'},
    {'label': 'Family Room',    'api': 'familyroom',     'emoji': '👨‍👩‍👧'},
    {'label': 'Reading Nook',   'api': 'readingnook',    'emoji': '📚'},
    {'label': 'Sun Room',       'api': 'sunroom',        'emoji': '☀️'},
    {'label': 'Walk In Closet', 'api': 'walkincloset',   'emoji': '👗'},
    {'label': 'Mud Room',       'api': 'mudroom',        'emoji': '👢'},
    {'label': 'Toy Room',       'api': 'toyroom',        'emoji': '🧩'},
    {'label': 'Foyer',          'api': 'foyer',          'emoji': '🚪'},
    {'label': 'Powder Room',    'api': 'powderroom',     'emoji': '🪞'},
    {'label': 'Laundry Room',   'api': 'laundryroom',    'emoji': '🧺'},
    {'label': 'Gym',            'api': 'gym',            'emoji': '🏋️'},
    {'label': 'Basement',       'api': 'basement',       'emoji': '🏠'},
    {'label': 'Garage',         'api': 'garage',         'emoji': '🚗'},
    {'label': 'Balcony',        'api': 'balcony',        'emoji': '🌿'},
    {'label': 'Cafe',           'api': 'cafe',           'emoji': '☕'},
    {'label': 'Home Bar',       'api': 'homebar',        'emoji': '🍹'},
    {'label': 'Study Room',     'api': 'study_room',     'emoji': '📖'},
    {'label': 'Front Porch',    'api': 'front_porch',    'emoji': '🏡'},
    {'label': 'Back Porch',     'api': 'back_porch',     'emoji': '🌳'},
    {'label': 'Back Patio',     'api': 'back_patio',     'emoji': '🪴'},
    {'label': 'Open Plan',      'api': 'openplan',       'emoji': '🏢'},
    {'label': 'Boardroom',      'api': 'boardroom',      'emoji': '🗃️'},
    {'label': 'Meeting Room',   'api': 'meetingroom',    'emoji': '📋'},
    {'label': 'Open Workspace', 'api': 'openworkspace',  'emoji': '🖥️'},
    {'label': 'Private Office', 'api': 'privateoffice',  'emoji': '🗂️'},
  ];

  static const List<String> recommended = [
    'Living Room',
    'Bedroom',
    'Kitchen',
    'Bathroom',
    'Office',
  ];

  static List<Map<String, String>> get recommendedItems =>
      all.where((r) => recommended.contains(r['label'])).toList();

  static List<Map<String, String>> get allItems =>
      all.where((r) => !recommended.contains(r['label'])).toList();

  static String? apiValue(String label) =>
      all.firstWhere(
            (r) => r['label'] == label,
        orElse: () => {},
      )['api'];

  static String? label(String apiValue) =>
      all.firstWhere(
            (r) => r['api'] == apiValue,
        orElse: () => {},
      )['label'];
}
