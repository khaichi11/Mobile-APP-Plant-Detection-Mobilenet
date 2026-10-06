enum PlantCategory {
  flower('Flower'),
  tree('Tree'),
  fruit('Fruit plant'),
  vegetable('Vegetable'),
  herb('Herb'),
  aquatic('Water plant'),
  succulent('Succulent'),
  shrub('Shrub'),
  vine('Vine');

  const PlantCategory(this.label);
  final String label;
}

/// A plant that Pandai has hand-written, kid-friendly content for.
class PlantProfile {
  const PlantProfile({
    required this.id,
    required this.scientificName,
    required this.commonName,
    required this.localName,
    required this.category,
    required this.habitat,
    required this.description,
    required this.funFact,
    required this.uses,
    this.caution,
  });

  /// Asset id, also the photo file name.
  final String id;

  /// Must match the label used by the classifier exactly.
  final String scientificName;
  final String commonName;

  /// Name used in Indonesia.
  final String localName;
  final PlantCategory category;
  final String habitat;
  final String description;
  final String funFact;
  final String uses;

  /// Safety note shown in a warning box, for plants that sting, are
  /// poisonous or irritate the skin.
  final String? caution;

  String get photoAsset => 'assets/images/plants/$id.jpg';
}
