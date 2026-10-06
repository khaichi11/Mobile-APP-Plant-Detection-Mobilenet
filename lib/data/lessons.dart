import '../models/lesson.dart';
import '../models/story.dart';

const lessons = <Lesson>[
  Lesson(
    id: 'notice-plants',
    title: 'Do You Notice Plants?',
    summary: 'Train your eyes to see the green world around you.',
    art: SceneArt(StoryScene.forest),
    minutes: 2,
    sections: [
      LessonSection(
        'Plants are everywhere',
        'Many people walk past plants every day without seeing them. '
            'Scientists call this "plant blindness". Plants feed us, give us air '
            'and shade, and are home to animals.',
      ),
      LessonSection(
        'Become a plant detective',
        'On your way to school, count how many different leaves you can find. '
            'Look at their shapes, edges and colors. Are they round, long, or '
            'shaped like a hand?',
      ),
      LessonSection(
        'Try it with Pandai',
        'Take Pandai outside and scan a plant you have never noticed before. '
            'Every new plant you find goes into your herbarium.',
      ),
    ],
  ),
  Lesson(
    id: 'plant-parts',
    title: 'Parts of a Plant',
    summary: 'Roots, stem, leaves, flowers and fruits.',
    art: SceneArt(StoryScene.flowerBee),
    minutes: 3,
    sections: [
      LessonSection(
        'Roots',
        'Roots hold the plant in the ground and drink water and minerals from '
            'the soil.',
      ),
      LessonSection(
        'Stem',
        'The stem holds the plant up. Thin pipes inside it carry water up and '
            'food down.',
      ),
      LessonSection(
        'Leaves',
        'Leaves catch sunlight and make food for the plant. They also give '
            'off the oxygen we breathe.',
      ),
      LessonSection(
        'Flowers, fruits and seeds',
        'Flowers attract bees and butterflies. After pollination, a flower '
            'turns into a fruit that protects the seeds.',
      ),
    ],
  ),
  Lesson(
    id: 'photosynthesis',
    title: 'How Plants Make Food',
    summary: 'The amazing kitchen inside every leaf.',
    art: SceneArt(StoryScene.leafKitchen),
    minutes: 2,
    sections: [
      LessonSection(
        'The ingredients',
        'Plants need sunlight, water and carbon dioxide, a gas in the air.',
      ),
      LessonSection(
        'The recipe',
        'Green chlorophyll in the leaves catches sunlight. The plant uses that '
            'energy to turn water and carbon dioxide into sugar. This is '
            'photosynthesis.',
      ),
      LessonSection(
        'A gift for us',
        'Photosynthesis also makes oxygen. Every breath you take is thanks to '
            'plants and algae.',
      ),
    ],
  ),
  Lesson(
    id: 'seeds-travel',
    title: 'How Seeds Travel',
    summary: 'Wind, water, animals and explosions!',
    art: PhotoArt('dandelion'),
    minutes: 2,
    sections: [
      LessonSection(
        'By wind',
        'Light seeds with parachutes or wings, like dandelion seeds, float on '
            'the wind.',
      ),
      LessonSection(
        'By water',
        'Coconuts float on the sea and can land on a faraway beach.',
      ),
      LessonSection(
        'By animals',
        'Birds eat fruits and drop the seeds somewhere else. Hooked seeds, '
            'like ketul, stick to fur and socks.',
      ),
      LessonSection(
        'By bursting',
        'Some seed pods, like those of calincing, burst open and shoot their '
            'seeds away.',
      ),
    ],
  ),
  Lesson(
    id: 'indonesia-plants',
    title: 'Plants of Indonesia',
    summary: 'One of the richest plant countries on Earth.',
    art: PhotoArt('mangrove'),
    minutes: 3,
    sections: [
      LessonSection(
        'A mega-diverse country',
        'Indonesia has rainforests, mountains, mangroves and coral islands. '
            'Tens of thousands of plant species grow here, and many grow nowhere '
            'else.',
      ),
      LessonSection(
        'Record breakers',
        'Rafflesia arnoldii from Sumatra has the biggest single flower in the '
            'world. The titan arum, also from Sumatra, has one of the tallest '
            'flower spikes.',
      ),
      LessonSection(
        'Mangrove champion',
        'Indonesia has more mangrove forest than any other country. Mangroves '
            'protect coasts and are nurseries for fish.',
      ),
    ],
  ),
  Lesson(
    id: 'sdg-15',
    title: 'Life on Land (SDG 15)',
    summary: 'A world goal to protect forests and nature.',
    art: SceneArt(StoryScene.plantingTree),
    minutes: 2,
    sections: [
      LessonSection(
        'A goal for the whole world',
        'In 2015, the countries of the United Nations agreed on 17 Sustainable '
            'Development Goals. Goal 15, Life on Land, is about protecting '
            'forests, plants and animals.',
      ),
      LessonSection(
        'Why it matters',
        'Forests clean the air, keep water in the soil and are home to most '
            'land animals. When forests disappear, we all lose.',
      ),
      LessonSection(
        'What you can do',
        'Learn the names of plants around you, plant trees, save paper and '
            'never litter. Caring starts with knowing.',
      ),
    ],
  ),
];

Lesson lessonById(String id) => lessons.firstWhere((lesson) => lesson.id == id);
