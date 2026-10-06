import 'dart:math';

import '../data/plant_catalog.dart';
import '../data/story_levels.dart';
import '../models/story.dart';

/// A question together with the picture shown above it.
class QuizItem {
  const QuizItem(this.art, this.question);
  final StoryArt art;
  final QuizQuestion question;
}

/// Returns [question] with its options in random order, so the right answer
/// is not always in the same place.
QuizQuestion shuffleOptions(QuizQuestion question, Random random) {
  final order = List<int>.generate(question.options.length, (i) => i)
    ..shuffle(random);
  return QuizQuestion(
    prompt: question.prompt,
    options: [for (final i in order) question.options[i]],
    answer: order.indexOf(question.answer),
    explanation: question.explanation,
  );
}

/// Today's quiz: photo questions that train players to recognise plants,
/// plus knowledge questions from the adventure. The same [dayIndex] always
/// gives the same quiz.
List<QuizItem> buildDailyQuiz(int dayIndex, {int photoQuestions = 3}) {
  final random = Random(dayIndex);
  final plants = [...plantCatalog]..shuffle(random);
  final items = <QuizItem>[];

  for (final plant in plants.take(photoQuestions)) {
    final wrong =
        plantCatalog.where((p) => p.id != plant.id).toList()..shuffle(random);
    final question = QuizQuestion(
      prompt: 'Which plant is this?',
      options: [plant.commonName, wrong[0].commonName, wrong[1].commonName],
      answer: 0,
      explanation:
          'This is the ${plant.commonName} (${plant.localName}). '
          '${plant.funFact}',
    );
    items.add(QuizItem(PhotoArt(plant.id), shuffleOptions(question, random)));
  }

  final knowledge = [
    for (final level in storyLevels)
      for (final step in level.steps.whereType<QuestionStep>())
        QuizItem(step.art, step.question),
  ]..shuffle(random);
  for (final item in knowledge.take(2)) {
    items.add(QuizItem(item.art, shuffleOptions(item.question, random)));
  }
  return items;
}
