import '../models/story.dart';

const _seedInSoil = 'assets/images/story/seed_in_soil.jpg';
const _seedThirsty = 'assets/images/story/seed_thirsty.jpg';
const _seedSprouting = 'assets/images/story/seed_sprouting.jpg';
const _carrot = 'assets/images/story/carrot.jpg';

/// PETA (Petualangan Tanaman): the story adventure, grouped into chapters.
const storyChapters = <StoryChapter>[
  StoryChapter(
    title: 'The Little Seed',
    subtitle: 'How a plant starts its life',
    levelIds: ['seed-wakes-up', 'roots-and-stem', 'leaf-kitchen'],
  ),
  StoryChapter(
    title: 'Flowers and Fruits',
    subtitle: 'How plants make new plants',
    levelIds: ['flower-friends', 'flower-to-fruit', 'seed-travelers'],
  ),
  StoryChapter(
    title: 'Amazing Adaptations',
    subtitle: 'Plants that live in tricky places',
    levelIds: ['water-plants', 'desert-survivors', 'moving-plants'],
  ),
  StoryChapter(
    title: 'Guardians of the Earth',
    subtitle: 'Why we protect plants (SDG 15)',
    levelIds: ['mangrove-heroes', 'plants-we-use', 'protect-forests'],
  ),
];

const storyLevels = <StoryLevel>[
  StoryLevel(
    id: 'seed-wakes-up',
    title: 'The Seed Wakes Up',
    summary: 'Help Biji the seed find what it needs to grow.',
    steps: [
      NarrationStep(
        IllustrationArt(_seedInSoil),
        'Hi friends! I am Biji, a little seed. Today I start a fun adventure '
        'to become a plant. I am already in the warm, soft soil. It feels so '
        'cozy!',
      ),
      NarrationStep(
        IllustrationArt(_seedThirsty),
        'I am thirsty... I need to find water. When a seed drinks water, it '
        'swells up and starts to wake up. This is called germination.',
      ),
      QuestionStep(
        IllustrationArt(_seedThirsty),
        QuizQuestion(
          prompt: 'What does Biji need to wake up and start growing?',
          options: ['Water', 'Candy', 'Darkness only'],
          answer: 0,
          explanation:
              'Seeds need water, air and the right warmth to start growing.',
        ),
      ),
      QuestionStep(
        IllustrationArt(_seedThirsty),
        QuizQuestion(
          prompt: 'Which way should my roots grow so I can drink?',
          options: [
            'Up, toward the sun',
            'Down, into the soil',
            'Sideways, out of the pot',
          ],
          answer: 1,
          explanation:
              'Roots grow down into the soil to find water and to hold the '
              'plant in place.',
        ),
      ),
      NarrationStep(
        IllustrationArt(_seedSprouting),
        'Ahhh... so fresh! Water makes me strong, my stem stands tall and my '
        'leaves turn bright green. With water and sunlight I can grow taller '
        'and healthier, and one day I will become a big tree that keeps '
        'everyone cool.',
      ),
    ],
  ),
  StoryLevel(
    id: 'roots-and-stem',
    title: 'Roots and Stem',
    summary: 'Discover the hidden pipes inside a plant.',
    steps: [
      NarrationStep(
        SceneArt(StoryScene.rootsDrinking),
        'Under the ground, my roots spread out like tiny straws. They drink '
        'water and minerals from the soil.',
      ),
      NarrationStep(
        SceneArt(StoryScene.stemPipes),
        'My stem is like an elevator. Thin pipes inside it carry the water all '
        'the way up to my leaves.',
      ),
      QuestionStep(
        SceneArt(StoryScene.stemPipes),
        QuizQuestion(
          prompt: 'What is the job of the stem?',
          options: [
            'To carry water up and hold the plant up',
            'To make the plant smell nice',
            'To catch insects',
          ],
          answer: 0,
          explanation:
              'The stem holds the plant up and moves water and food between '
              'the roots and leaves.',
        ),
      ),
      NarrationStep(
        IllustrationArt(_carrot),
        'Some roots store food for the plant. The carrot we eat is a root '
        'that grows deep in the soil!',
      ),
      NarrationStep(
        PhotoArt('mangrove'),
        'Some plants have very special roots. Mangrove trees stand on tall '
        'stilt roots so they can live in muddy seawater.',
      ),
      QuestionStep(
        SceneArt(StoryScene.rootsDrinking),
        QuizQuestion(
          prompt: 'What do roots take from the soil?',
          options: ['Sunlight', 'Water and minerals', 'Air bubbles only'],
          answer: 1,
          explanation:
              'Roots soak up water and minerals. Sunlight is caught by the '
              'leaves.',
        ),
      ),
    ],
  ),
  StoryLevel(
    id: 'leaf-kitchen',
    title: 'The Leaf Kitchen',
    summary: 'Find out how leaves cook food from sunlight.',
    steps: [
      NarrationStep(
        SceneArt(StoryScene.leafKitchen),
        'My leaves are my kitchen. They are green because they are full of '
        'chlorophyll, which catches sunlight.',
      ),
      NarrationStep(
        SceneArt(StoryScene.leafKitchen),
        'With sunlight, water from my roots and carbon dioxide from the air, '
        'my leaves make sugar for food. This is called photosynthesis.',
      ),
      QuestionStep(
        SceneArt(StoryScene.leafKitchen),
        QuizQuestion(
          prompt: 'What do leaves need to make food?',
          options: [
            'Sunlight, water and air',
            'Soil and stones',
            'Rain and darkness',
          ],
          answer: 0,
          explanation:
              'Leaves use sunlight, water and carbon dioxide from the air to '
              'make sugar.',
        ),
      ),
      NarrationStep(
        SceneArt(StoryScene.forest),
        'While cooking, my leaves give off oxygen. That is the air people and '
        'animals breathe. Thank you, plants!',
      ),
      QuestionStep(
        SceneArt(StoryScene.forest),
        QuizQuestion(
          prompt: 'Which gas do plants give us to breathe?',
          options: ['Smoke', 'Oxygen', 'Steam'],
          answer: 1,
          explanation:
              'Plants release oxygen during photosynthesis. We need it to '
              'breathe.',
        ),
      ),
    ],
  ),
  StoryLevel(
    id: 'flower-friends',
    title: 'Flower Friends',
    summary: 'Meet the helpers that carry pollen.',
    steps: [
      NarrationStep(
        SceneArt(StoryScene.flowerBee),
        'Flowers are colorful and sweet-smelling for a reason. They invite '
        'bees, butterflies and birds to visit.',
      ),
      NarrationStep(
        PhotoArt('sunflower'),
        'When a bee drinks nectar, yellow pollen sticks to its body. At the '
        'next flower, some pollen rubs off. This is called pollination.',
      ),
      QuestionStep(
        PhotoArt('sunflower'),
        QuizQuestion(
          prompt: 'Why do bees visit flowers?',
          options: [
            'To sleep in them',
            'To drink nectar and collect pollen',
            'To eat the leaves',
          ],
          answer: 1,
          explanation:
              'Bees drink nectar and collect pollen, and they help flowers by '
              'carrying pollen between them.',
        ),
      ),
      NarrationStep(
        PhotoArt('bird_of_paradise'),
        'The bird of paradise flower even has a perch! When a bird stands on '
        'it, the flower dusts the bird\'s feet with pollen.',
      ),
      QuestionStep(
        PhotoArt('hibiscus'),
        QuizQuestion(
          prompt: 'What is moving pollen from flower to flower called?',
          options: ['Pollination', 'Germination', 'Evaporation'],
          answer: 0,
          explanation:
              'Pollination helps flowers make seeds. Germination is when a '
              'seed starts to grow.',
        ),
      ),
    ],
  ),
  StoryLevel(
    id: 'flower-to-fruit',
    title: 'From Flower to Fruit',
    summary: 'Watch a flower turn into a fruit.',
    steps: [
      NarrationStep(
        PhotoArt('tomato'),
        'After pollination, the flower petals fall off. The bottom of the '
        'flower slowly swells and becomes a fruit.',
      ),
      NarrationStep(
        PhotoArt('papaya'),
        'A fruit is like a lunchbox for seeds. It protects the seeds inside '
        'until they are ready to grow.',
      ),
      QuestionStep(
        PhotoArt('papaya'),
        QuizQuestion(
          prompt: 'Where do you find seeds?',
          options: ['Inside the fruit', 'Inside the roots', 'On the stem tip'],
          answer: 0,
          explanation: 'Fruits grow from flowers and hold the seeds inside.',
        ),
      ),
      NarrationStep(
        PhotoArt('mango'),
        'Mangoes, guavas and chilies are all fruits. Even a tomato is a fruit, '
        'because it grows from a flower and has seeds!',
      ),
      QuestionStep(
        PhotoArt('tomato'),
        QuizQuestion(
          prompt: 'A tomato grows from a flower and has seeds. So it is a...',
          options: ['Root', 'Leaf', 'Fruit'],
          answer: 2,
          explanation:
              'Scientists call anything that grows from a flower and holds '
              'seeds a fruit.',
        ),
      ),
    ],
  ),
  StoryLevel(
    id: 'seed-travelers',
    title: 'Seed Travelers',
    summary: 'Seeds go on journeys without legs!',
    steps: [
      NarrationStep(
        PhotoArt('dandelion'),
        'Seeds need space to grow, so they travel. Dandelion seeds have tiny '
        'parachutes and fly with the wind.',
      ),
      NarrationStep(
        PhotoArt('coconut'),
        'A coconut is a seed that can float. It sails across the sea and grows '
        'on a new beach.',
      ),
      QuestionStep(
        PhotoArt('coconut'),
        QuizQuestion(
          prompt: 'How does a coconut travel to a new island?',
          options: ['It flies', 'It floats on the sea', 'It rolls uphill'],
          answer: 1,
          explanation:
              'Coconuts float and can drift on the sea for months before '
              'landing on a new beach.',
        ),
      ),
      NarrationStep(
        PhotoArt('spanish_needles'),
        'Ketul seeds have little hooks. They hitch a ride on animal fur and on '
        'your socks!',
      ),
      QuestionStep(
        PhotoArt('dandelion'),
        QuizQuestion(
          prompt: 'Which helper carries dandelion seeds?',
          options: ['The wind', 'Fish', 'Worms'],
          answer: 0,
          explanation:
              'Each dandelion seed has a parachute that rides the wind.',
        ),
      ),
    ],
  ),
  StoryLevel(
    id: 'water-plants',
    title: 'Life on the Water',
    summary: 'Explore plants that float.',
    steps: [
      NarrationStep(
        PhotoArt('water_lily'),
        'Water lilies grow roots in the mud at the bottom of a pond, but their '
        'round leaves float on top to catch the sun.',
      ),
      NarrationStep(
        PhotoArt('water_hyacinth'),
        'Eceng gondok has puffy stalks full of air, like a swimming ring. That '
        'is how it floats!',
      ),
      QuestionStep(
        PhotoArt('water_hyacinth'),
        QuizQuestion(
          prompt: 'What helps eceng gondok float?',
          options: [
            'Air inside its puffy stalks',
            'Heavy stones in its roots',
            'It swims with its leaves',
          ],
          answer: 0,
          explanation: 'Air trapped in its stalks makes the plant light.',
        ),
      ),
      NarrationStep(
        PhotoArt('water_lettuce'),
        'Kayu apu has tiny hairs that trap air and keep its leaves dry. But '
        'floating plants can grow too fast and cover a whole lake.',
      ),
      QuestionStep(
        PhotoArt('water_lily'),
        QuizQuestion(
          prompt: 'Why do water lily leaves float on top of the water?',
          options: ['To catch sunlight', 'To hide from fish', 'To stay cold'],
          answer: 0,
          explanation:
              'Leaves need sunlight to make food, so floating leaves stay on '
              'the surface.',
        ),
      ),
    ],
  ),
  StoryLevel(
    id: 'desert-survivors',
    title: 'Desert Survivors',
    summary: 'How plants live where it hardly rains.',
    steps: [
      NarrationStep(
        PhotoArt('prickly_pear'),
        'In dry places, plants must save every drop. A cactus stores water in '
        'its thick, fleshy stems.',
      ),
      NarrationStep(
        PhotoArt('prickly_pear'),
        'Its spines are actually leaves. Thin spines lose very little water '
        'and protect the plant from thirsty animals.',
      ),
      QuestionStep(
        PhotoArt('prickly_pear'),
        QuizQuestion(
          prompt: 'Where does a cactus store water?',
          options: ['In its spines', 'In its thick stems', 'In the clouds'],
          answer: 1,
          explanation: 'Cactus stems are thick and juicy, like a water bottle.',
        ),
      ),
      NarrationStep(
        PhotoArt('aloe_vera'),
        'Lidah buaya keeps water in its juicy leaves. Plants like this are '
        'called succulents.',
      ),
      QuestionStep(
        PhotoArt('aloe_vera'),
        QuizQuestion(
          prompt: 'Plants that store water in thick leaves are called...',
          options: ['Succulents', 'Seaweeds', 'Mushrooms'],
          answer: 0,
          explanation: 'Succulent means juicy. Aloe and cactus are succulents.',
        ),
      ),
    ],
  ),
  StoryLevel(
    id: 'moving-plants',
    title: 'Plants That Move',
    summary: 'Plants can move, slowly or in a flash.',
    steps: [
      NarrationStep(
        PhotoArt('mimosa'),
        'Putri malu is shy! When you touch its leaves, they fold up in a few '
        'seconds.',
      ),
      QuestionStep(
        PhotoArt('mimosa'),
        QuizQuestion(
          prompt: 'What happens when you touch putri malu?',
          options: [
            'It grows a flower',
            'Its leaves fold up',
            'It changes color',
          ],
          answer: 1,
          explanation:
              'Its leaves fold up quickly, which may scare away hungry '
              'insects.',
        ),
      ),
      NarrationStep(
        PhotoArt('sunflower'),
        'Young sunflowers move slowly. They turn to follow the sun from '
        'morning to evening.',
      ),
      NarrationStep(
        SceneArt(StoryScene.seedSprouting),
        'Even a sprout on your windowsill bends toward the light. Try it at '
        'home!',
      ),
      QuestionStep(
        PhotoArt('sunflower'),
        QuizQuestion(
          prompt: 'What do young sunflowers follow across the sky?',
          options: ['The moon', 'The sun', 'The clouds'],
          answer: 1,
          explanation:
              'Young sunflowers track the sun to catch as much light as they '
              'can.',
        ),
      ),
    ],
  ),
  StoryLevel(
    id: 'mangrove-heroes',
    title: 'Mangrove Heroes',
    summary: 'The trees that guard our coasts.',
    steps: [
      NarrationStep(
        PhotoArt('mangrove'),
        'Indonesia has more mangrove forests than any other country. These '
        'trees grow where the sea meets the land.',
      ),
      NarrationStep(
        PhotoArt('mangrove'),
        'Their tangled roots slow down big waves and hold the mud, so the '
        'coast does not wash away.',
      ),
      QuestionStep(
        PhotoArt('mangrove'),
        QuizQuestion(
          prompt: 'How do mangroves protect the coast?',
          options: [
            'Their roots slow waves and hold the mud',
            'They push the sea back with their leaves',
            'They drink all the seawater',
          ],
          answer: 0,
          explanation:
              'Mangrove roots break the power of waves and keep the soil in '
              'place.',
        ),
      ),
      NarrationStep(
        PhotoArt('mangrove'),
        'Fish, crabs and birds raise their babies among the roots. Mangroves '
        'also store a lot of carbon, which helps fight climate change.',
      ),
      QuestionStep(
        PhotoArt('mangrove'),
        QuizQuestion(
          prompt: 'Who lives among mangrove roots?',
          options: ['Fish and crabs', 'Camels', 'Penguins'],
          answer: 0,
          explanation:
              'Mangroves are nurseries for fish, crabs, shrimp and many birds.',
        ),
      ),
    ],
  ),
  StoryLevel(
    id: 'plants-we-use',
    title: 'Plants We Use',
    summary: 'Food, medicine, and staying safe.',
    steps: [
      NarrationStep(
        PhotoArt('coconut'),
        'Plants give us food, medicine and materials. From one coconut palm we '
        'get coconut water, santan, wood and leaves for ketupat.',
      ),
      NarrationStep(
        PhotoArt('periwinkle'),
        'Scientists made medicines for fighting cancer from tapak dara. Many '
        'medicines come from plants.',
      ),
      NarrationStep(
        PhotoArt('oleander'),
        'But be careful! Some plants are poisonous, like oleander and the '
        'seeds of the castor bean. Pretty does not always mean safe.',
      ),
      QuestionStep(
        PhotoArt('lantana'),
        QuizQuestion(
          prompt: 'You find shiny berries on a bush. What should you do?',
          options: [
            'Eat one to taste it',
            'Do not eat it, and ask an adult',
            'Give it to a friend',
          ],
          answer: 1,
          explanation:
              'Never eat wild berries or leaves. Some, like lantana berries, '
              'are poisonous.',
        ),
      ),
      QuestionStep(
        PhotoArt('coconut'),
        QuizQuestion(
          prompt: 'Which of these do we NOT get from a coconut palm?',
          options: ['Coconut water', 'Santan', 'Rice'],
          answer: 2,
          explanation: 'Rice comes from the rice plant, not from coconuts.',
        ),
      ),
    ],
  ),
  StoryLevel(
    id: 'protect-forests',
    title: 'Protect Our Forests',
    summary: 'Become a guardian of life on land.',
    steps: [
      NarrationStep(
        SceneArt(StoryScene.forest),
        'Forests are home to most of the animals and plants on land. They '
        'clean the air and keep water in the ground.',
      ),
      NarrationStep(
        SceneArt(StoryScene.forest),
        'When too many trees are cut down, animals lose their homes and the '
        'soil washes away when it rains.',
      ),
      QuestionStep(
        SceneArt(StoryScene.forest),
        QuizQuestion(
          prompt: 'What happens when a forest is cut down?',
          options: [
            'Animals lose their homes',
            'There is more oxygen',
            'Rivers get cleaner',
          ],
          answer: 0,
          explanation:
              'Without trees, animals lose shelter and food, and the soil '
              'erodes.',
        ),
      ),
      NarrationStep(
        SceneArt(StoryScene.plantingTree),
        'You can help! Plant a tree, use both sides of your paper, and never '
        'litter in nature. Small actions add up.',
      ),
      QuestionStep(
        SceneArt(StoryScene.plantingTree),
        QuizQuestion(
          prompt: 'Which action helps protect plants and forests?',
          options: [
            'Planting trees',
            'Throwing trash in rivers',
            'Picking every flower you see',
          ],
          answer: 0,
          explanation:
              'Planting trees and keeping nature clean protect life on land. '
              'That is UN Sustainable Development Goal 15.',
        ),
      ),
    ],
  ),
];

StoryLevel storyLevelById(String id) =>
    storyLevels.firstWhere((level) => level.id == id);
