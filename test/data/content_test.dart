import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pandai/data/game_levels.dart';
import 'package:pandai/data/lessons.dart';
import 'package:pandai/data/missions.dart';
import 'package:pandai/data/plant_catalog.dart';
import 'package:pandai/data/story_levels.dart';
import 'package:pandai/models/story.dart';
import 'package:pandai/services/classifier/classifier_math.dart';

void main() {
  final labels =
      parseLabelMap(
        File('assets/models/plant_labels.csv').readAsStringSync(),
      ).toSet();
  final credits =
      jsonDecode(File('assets/images/plants/credits.json').readAsStringSync())
          as Map<String, dynamic>;
  final catalogIds = plantCatalog.map((p) => p.id).toSet();

  void expectKnownArt(StoryArt art, String where) {
    if (art is PhotoArt) {
      expect(catalogIds, contains(art.plantId), reason: where);
    }
    if (art is IllustrationArt) {
      expect(File(art.asset).existsSync(), isTrue, reason: where);
    }
  }

  group('plant catalog', () {
    test('ids and scientific names are unique', () {
      expect(catalogIds, hasLength(plantCatalog.length));
      expect(
        plantCatalog.map((p) => p.scientificName).toSet(),
        hasLength(plantCatalog.length),
      );
    });

    test('every plant is known by the classifier', () {
      for (final plant in plantCatalog) {
        expect(labels, contains(plant.scientificName), reason: plant.id);
      }
    });

    test('every plant has a photo with license credits', () {
      for (final plant in plantCatalog) {
        expect(File(plant.photoAsset).existsSync(), isTrue, reason: plant.id);
        final credit = credits[plant.id] as Map<String, dynamic>?;
        expect(credit, isNotNull, reason: plant.id);
        expect(credit!['author'], isNotEmpty);
        expect(credit['license'], isNotEmpty);
        expect(credit['source'], startsWith('https://'));
      }
    });

    test('lookups work both ways', () {
      expect(plantById('mango').scientificName, 'Mangifera indica');
      expect(plantByScientificName('Mangifera indica')!.id, 'mango');
      expect(plantByScientificName('Nope'), isNull);
      expect(() => plantById('nope'), throwsArgumentError);
    });
  });

  group('adventure', () {
    test('chapters list every level exactly once, in order', () {
      final fromChapters = [for (final c in storyChapters) ...c.levelIds];
      expect(fromChapters, storyLevels.map((l) => l.id).toList());
    });

    test('every level has questions with valid answers and known art', () {
      for (final level in storyLevels) {
        expect(level.questionCount, greaterThanOrEqualTo(2), reason: level.id);
        expect(level.steps.first, isA<NarrationStep>(), reason: level.id);
        for (final step in level.steps) {
          expectKnownArt(step.art, level.id);
          if (step is QuestionStep) {
            final q = step.question;
            expect(q.options.toSet(), hasLength(q.options.length));
            expect(q.answer, inInclusiveRange(0, q.options.length - 1));
            expect(q.explanation, isNotEmpty);
          }
        }
      }
    });
  });

  group('games', () {
    test('puzzle levels are numbered from 1 and their images exist', () {
      for (var i = 0; i < puzzleLevels.length; i++) {
        expect(puzzleLevels[i].number, i + 1);
        expect(File(puzzleLevels[i].imageAsset).existsSync(), isTrue);
        expect(puzzleLevels[i].fact, isNotEmpty);
      }
    });

    test('memory levels use distinct catalog plants', () {
      for (var i = 0; i < memoryLevels.length; i++) {
        final level = memoryLevels[i];
        expect(level.number, i + 1);
        expect(level.plantIds.toSet(), hasLength(level.pairs));
        for (final id in level.plantIds) {
          expect(catalogIds, contains(id));
        }
      }
    });
  });

  test('lessons, missions and badges have unique ids', () {
    expect(lessons.map((l) => l.id).toSet(), hasLength(lessons.length));
    for (final lesson in lessons) {
      expectKnownArt(lesson.art, lesson.id);
      expect(lesson.sections, isNotEmpty);
    }
    expect(allMissions.map((m) => m.id).toSet(), hasLength(allMissions.length));
    expect(badges.map((b) => b.id).toSet(), hasLength(badges.length));
  });

  test('every day has one outdoor mission and two different play missions', () {
    for (var day = 0; day < 30; day++) {
      final missions = missionsForDay(day);
      expect(missions, hasLength(3));
      expect(missions.first.isOutdoor, isTrue);
      expect(missions.map((m) => m.id).toSet(), hasLength(3));
    }
  });
}
