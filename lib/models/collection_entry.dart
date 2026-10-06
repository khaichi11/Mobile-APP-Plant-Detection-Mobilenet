/// A plant the player photographed and saved to their herbarium.
class CollectionEntry {
  const CollectionEntry({
    required this.id,
    required this.scientificName,
    required this.imagePath,
    required this.confidence,
    required this.foundAt,
  });

  factory CollectionEntry.fromJson(Map<String, dynamic> json) {
    return CollectionEntry(
      id: json['id'] as String,
      scientificName: json['scientificName'] as String,
      imagePath: json['imagePath'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      foundAt: DateTime.parse(json['foundAt'] as String),
    );
  }

  final String id;
  final String scientificName;
  final String imagePath;

  /// Classifier confidence between 0 and 1.
  final double confidence;
  final DateTime foundAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'scientificName': scientificName,
    'imagePath': imagePath,
    'confidence': confidence,
    'foundAt': foundAt.toIso8601String(),
  };
}
