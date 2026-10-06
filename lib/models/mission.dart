/// Things the player does that count toward missions.
enum GameEvent {
  scan,
  newSpecies,
  storyLevel,
  puzzle,
  memory,
  plantParts,
  dailyQuiz,
  lesson,
}

class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.event,
    required this.target,
    this.reward = 15,
  });

  final String id;
  final String title;
  final String description;
  final GameEvent event;
  final int target;
  final int reward;

  bool get isOutdoor =>
      event == GameEvent.scan || event == GameEvent.newSpecies;
}

class Badge {
  const Badge({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}
