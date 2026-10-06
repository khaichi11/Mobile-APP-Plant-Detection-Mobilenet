import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pandai/games/quiz_builder.dart';
import 'package:pandai/models/story.dart';

void main() {
  const question = QuizQuestion(
    prompt: 'Pick B',
    options: ['A', 'B', 'C'],
    answer: 1,
    explanation: '',
  );

  test('shuffling keeps the right answer', () {
    for (var seed = 0; seed < 30; seed++) {
      final shuffled = shuffleOptions(question, Random(seed));
      expect(shuffled.options.toSet(), {'A', 'B', 'C'});
      expect(shuffled.options[shuffled.answer], 'B');
    }
  });

  test('the daily quiz is the same all day and changes every day', () {
    final today = buildDailyQuiz(20000);
    final again = buildDailyQuiz(20000);
    final tomorrow = buildDailyQuiz(20001);
    expect(today, hasLength(5));
    expect(
      today.map((q) => q.question.prompt + q.question.options.join()),
      again.map((q) => q.question.prompt + q.question.options.join()),
    );
    expect(
      today.map((q) => q.question.options.join()).join(),
      isNot(tomorrow.map((q) => q.question.options.join()).join()),
    );
  });

  test('photo questions have three different names and one answer', () {
    for (var day = 0; day < 50; day++) {
      for (final item in buildDailyQuiz(day).take(3)) {
        expect(item.art, isA<PhotoArt>());
        expect(item.question.options.toSet(), hasLength(3));
        expect(item.question.answer, inInclusiveRange(0, 2));
      }
    }
  });
}
