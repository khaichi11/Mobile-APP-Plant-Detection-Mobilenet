/// Illustrations drawn in code by `SceneView`.
enum StoryScene {
  seedSleeping,
  seedRain,
  seedSprouting,
  rootsDrinking,
  stemPipes,
  leafKitchen,
  flowerBee,
  forest,
  plantingTree,
}

/// What a story step shows above its text: a drawn scene or a plant photo.
sealed class StoryArt {
  const StoryArt();
}

class SceneArt extends StoryArt {
  const SceneArt(this.scene);
  final StoryScene scene;
}

/// A drawing made by Team Terang Bulan, bundled in assets/images/story.
class IllustrationArt extends StoryArt {
  const IllustrationArt(this.asset);
  final String asset;
}

class PhotoArt extends StoryArt {
  const PhotoArt(this.plantId);

  /// Id of a plant in the catalog.
  final String plantId;
}

class QuizQuestion {
  const QuizQuestion({
    required this.prompt,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  final String prompt;
  final List<String> options;

  /// Index of the correct option.
  final int answer;

  /// Shown after the player answers, right or wrong.
  final String explanation;
}

sealed class StoryStep {
  const StoryStep(this.art);
  final StoryArt art;
}

class NarrationStep extends StoryStep {
  const NarrationStep(super.art, this.text);
  final String text;
}

class QuestionStep extends StoryStep {
  const QuestionStep(super.art, this.question);
  final QuizQuestion question;
}

class StoryChapter {
  const StoryChapter({
    required this.title,
    required this.subtitle,
    required this.levelIds,
  });

  final String title;
  final String subtitle;
  final List<String> levelIds;
}

class StoryLevel {
  const StoryLevel({
    required this.id,
    required this.title,
    required this.summary,
    required this.steps,
  });

  final String id;
  final String title;
  final String summary;
  final List<StoryStep> steps;

  int get questionCount => steps.whereType<QuestionStep>().length;
}
