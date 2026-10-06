import '../models/mission.dart';

/// Outdoor missions. One of them is part of every day's mission set, so
/// players always have a reason to go outside.
const outdoorMissions = <Mission>[
  Mission(
    id: 'scan-1',
    title: 'Go plant spotting',
    description: 'Scan any plant outside your classroom or home.',
    event: GameEvent.scan,
    target: 1,
  ),
  Mission(
    id: 'scan-3',
    title: 'Garden explorer',
    description: 'Scan 3 plants today. Try plants that look different.',
    event: GameEvent.scan,
    target: 3,
    reward: 25,
  ),
  Mission(
    id: 'new-species',
    title: 'New discovery',
    description: 'Add a plant you have never found before to your herbarium.',
    event: GameEvent.newSpecies,
    target: 1,
    reward: 20,
  ),
];

const playMissions = <Mission>[
  Mission(
    id: 'story',
    title: 'Adventure time',
    description: 'Finish a level of the PETA adventure.',
    event: GameEvent.storyLevel,
    target: 1,
  ),
  Mission(
    id: 'puzzle',
    title: 'Puzzle solver',
    description: 'Solve a plant puzzle.',
    event: GameEvent.puzzle,
    target: 1,
  ),
  Mission(
    id: 'memory',
    title: 'Sharp eyes',
    description: 'Finish a Memory Match game.',
    event: GameEvent.memory,
    target: 1,
  ),
  Mission(
    id: 'quiz',
    title: 'Daily quiz',
    description: 'Answer today\'s plant quiz.',
    event: GameEvent.dailyQuiz,
    target: 1,
  ),
  Mission(
    id: 'lesson',
    title: 'Curious mind',
    description: 'Read a lesson in the Learn corner.',
    event: GameEvent.lesson,
    target: 1,
  ),
  Mission(
    id: 'parts',
    title: 'Plant builder',
    description: 'Play Build a Plant.',
    event: GameEvent.plantParts,
    target: 1,
  ),
];

final allMissions = [...outdoorMissions, ...playMissions];

/// The three missions for the day with number [dayIndex] (days since epoch).
/// The same day always gives the same missions.
List<Mission> missionsForDay(int dayIndex) {
  final outdoor = outdoorMissions[dayIndex % outdoorMissions.length];
  final first = playMissions[(dayIndex * 2) % playMissions.length];
  final second = playMissions[(dayIndex * 2 + 1) % playMissions.length];
  return [outdoor, first, second];
}

const badges = <Badge>[
  Badge(
    id: 'first-scan',
    title: 'First Discovery',
    description: 'Scan your first plant.',
  ),
  Badge(
    id: 'botanist-5',
    title: 'Junior Botanist',
    description: 'Collect 5 different plants.',
  ),
  Badge(
    id: 'botanist-15',
    title: 'Plant Expert',
    description: 'Collect 15 different plants.',
  ),
  Badge(
    id: 'adventurer',
    title: 'Adventurer',
    description: 'Finish 3 adventure levels.',
  ),
  Badge(
    id: 'earth-guardian',
    title: 'Earth Guardian',
    description: 'Finish every level of the PETA adventure.',
  ),
  Badge(
    id: 'puzzle-pro',
    title: 'Puzzle Pro',
    description: 'Solve 5 plant puzzles.',
  ),
  Badge(
    id: 'sharp-memory',
    title: 'Sharp Memory',
    description: 'Finish every Memory Match level.',
  ),
  Badge(
    id: 'plant-builder',
    title: 'Plant Builder',
    description: 'Get 3 stars in Build a Plant.',
  ),
  Badge(
    id: 'quiz-whiz',
    title: 'Quiz Whiz',
    description: 'Answer every daily quiz question correctly.',
  ),
  Badge(
    id: 'streak-3',
    title: 'On a Roll',
    description: 'Learn with Pandai 3 days in a row.',
  ),
  Badge(
    id: 'streak-7',
    title: 'Nature Habit',
    description: 'Learn with Pandai 7 days in a row.',
  ),
  Badge(
    id: 'bookworm',
    title: 'Bookworm',
    description: 'Read every lesson in the Learn corner.',
  ),
];

Badge badgeById(String id) => badges.firstWhere((badge) => badge.id == id);
