class ProjectModel {
  final String id;
  final String title;
  final String feature;           // FeatureType.name string
  final String originalImageUrl;
  final String generatedImageUrl;
  final Map<String, dynamic> metadata; // design style, room type, etc.
  final DateTime createdAt;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.feature,
    required this.originalImageUrl,
    required this.generatedImageUrl,
    required this.metadata,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id':                 id,
    'title':              title,
    'feature':            feature,
    'originalImageUrl':   originalImageUrl,
    'generatedImageUrl':  generatedImageUrl,
    'metadata':           metadata,
    'createdAt':          createdAt.toIso8601String(),
  };

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    id:                json['id']               as String,
    title:             json['title']            as String,
    feature:           json['feature']          as String,
    originalImageUrl:  json['originalImageUrl'] as String,
    generatedImageUrl: json['generatedImageUrl'] as String,
    metadata:          Map<String, dynamic>.from(json['metadata'] as Map),
    createdAt:         DateTime.parse(json['createdAt'] as String),
  );

  ProjectModel copyWith({
    String? id,
    String? title,
    String? feature,
    String? originalImageUrl,
    String? generatedImageUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return ProjectModel(
      id:                id                ?? this.id,
      title:             title             ?? this.title,
      feature:           feature           ?? this.feature,
      originalImageUrl:  originalImageUrl  ?? this.originalImageUrl,
      generatedImageUrl: generatedImageUrl ?? this.generatedImageUrl,
      metadata:          metadata          ?? this.metadata,
      createdAt:         createdAt         ?? this.createdAt,
    );
  }

  // Convenience getters for display
  String? get displayStyle    => metadata['designStyle']    as String?;
  String? get displayRoom     => metadata['roomType']       as String?;
  String? get displayColor    => metadata['colorScheme']    as String?;
  String? get displayHex      => metadata['hexColor']       as String?;
  String? get displayTheme    => metadata['specialityDecor'] as String?;
  String? get displayGarden   => metadata['gardenStyle']    as String?;
  String? get displayPrompt   => metadata['prompt']         as String?;

  @override
  bool operator ==(Object other) =>
      other is ProjectModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}