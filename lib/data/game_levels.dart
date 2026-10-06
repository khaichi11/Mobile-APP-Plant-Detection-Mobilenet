import '../models/game_levels.dart';
import 'plant_catalog.dart';

PuzzleLevel _plantPuzzle(int number, String plantId, int gridSize) {
  final plant = plantById(plantId);
  return PuzzleLevel(
    number: number,
    gridSize: gridSize,
    imageAsset: plant.photoAsset,
    title: plant.commonName,
    fact: plant.funFact,
  );
}

final puzzleLevels = <PuzzleLevel>[
  const PuzzleLevel(
    number: 1,
    gridSize: 3,
    imageAsset: 'assets/images/story/carrot.jpg',
    title: 'Carrot',
    fact:
        'The orange part of a carrot is its root. It stores food so the '
        'plant can grow flowers and seeds later.',
  ),
  _plantPuzzle(2, 'sunflower', 3),
  _plantPuzzle(3, 'hibiscus', 3),
  _plantPuzzle(4, 'tomato', 3),
  _plantPuzzle(5, 'cosmos', 3),
  _plantPuzzle(6, 'water_lily', 3),
  _plantPuzzle(7, 'bird_of_paradise', 4),
  _plantPuzzle(8, 'periwinkle', 4),
  _plantPuzzle(9, 'lantana', 4),
  _plantPuzzle(10, 'water_hyacinth', 4),
  _plantPuzzle(11, 'frangipani', 4),
  _plantPuzzle(12, 'flame_tree', 4),
];

const memoryLevels = <MemoryLevel>[
  MemoryLevel(
    number: 1,
    pairs: 3,
    mode: MemoryMode.photoPairs,
    plantIds: ['sunflower', 'tomato', 'coconut'],
  ),
  MemoryLevel(
    number: 2,
    pairs: 4,
    mode: MemoryMode.photoPairs,
    plantIds: ['hibiscus', 'aloe_vera', 'chili', 'water_lily'],
  ),
  MemoryLevel(
    number: 3,
    pairs: 6,
    mode: MemoryMode.photoPairs,
    plantIds: [
      'mimosa',
      'papaya',
      'cosmos',
      'taro',
      'mangrove',
      'bird_of_paradise',
    ],
  ),
  MemoryLevel(
    number: 4,
    pairs: 4,
    mode: MemoryMode.photoToName,
    plantIds: ['sunflower', 'coconut', 'aloe_vera', 'tomato'],
  ),
  MemoryLevel(
    number: 5,
    pairs: 6,
    mode: MemoryMode.photoToName,
    plantIds: [
      'hibiscus',
      'mango',
      'mimosa',
      'water_hyacinth',
      'dandelion',
      'prickly_pear',
    ],
  ),
  MemoryLevel(
    number: 6,
    pairs: 8,
    mode: MemoryMode.photoToName,
    plantIds: [
      'guava',
      'frangipani',
      'canna',
      'chili',
      'mangrove',
      'flame_tree',
      'taro',
      'periwinkle',
    ],
  ),
];
