import '../models/plant.dart';

/// Plants with hand-written content. Every scientific name matches a label of
/// the on-device classifier, so a scan of these plants shows this content.
const plantCatalog = <PlantProfile>[
  PlantProfile(
    id: 'sunflower',
    scientificName: 'Helianthus annuus',
    commonName: 'Sunflower',
    localName: 'Bunga matahari',
    category: PlantCategory.flower,
    habitat: 'Sunny fields and gardens',
    description:
        'A tall plant with a giant yellow flower head. What looks like one '
        'flower is really hundreds of tiny flowers packed together.',
    funFact:
        'Young sunflowers turn to follow the sun across the sky during the '
        'day. Grown-up flower heads stop moving and face east.',
    uses:
        'Its seeds are a tasty snack and are pressed to make cooking oil. '
        'Bees love its pollen.',
  ),
  PlantProfile(
    id: 'mango',
    scientificName: 'Mangifera indica',
    commonName: 'Mango tree',
    localName: 'Mangga',
    category: PlantCategory.fruit,
    habitat: 'Warm, tropical gardens and orchards',
    description:
        'A big, shady tree with long, dark green leaves. Its sweet fruits '
        'grow on long stalks that hang from the branches.',
    funFact:
        'Mango trees can live for more than 100 years and are cousins of the '
        'cashew tree.',
    uses:
        'The fruit is rich in vitamins A and C. The tree also gives cool shade '
        'and wood.',
    caution: 'The sap of the tree and fruit skin can make skin itchy.',
  ),
  PlantProfile(
    id: 'coconut',
    scientificName: 'Cocos nucifera',
    commonName: 'Coconut palm',
    localName: 'Kelapa',
    category: PlantCategory.tree,
    habitat: 'Sandy, tropical coasts',
    description:
        'A tall palm with a smooth trunk and long, feather-like leaves at the '
        'top. Its big seeds are the coconuts.',
    funFact:
        'A coconut can float in the sea for months and grow into a new palm '
        'on a faraway beach.',
    uses:
        'Almost every part is useful: coconut water to drink, the white flesh '
        'for santan, young leaves to wrap ketupat and the trunk for wood.',
  ),
  PlantProfile(
    id: 'papaya',
    scientificName: 'Carica papaya',
    commonName: 'Papaya',
    localName: 'Pepaya',
    category: PlantCategory.fruit,
    habitat: 'Tropical gardens and yards',
    description:
        'A fast-growing plant with one straight stem and big, hand-shaped '
        'leaves. The fruits grow right on the stem, under the leaves.',
    funFact:
        'A papaya plant can give fruit less than a year after the seed is '
        'planted.',
    uses:
        'The fruit helps digestion. In Indonesia the young leaves and flowers '
        'are cooked as vegetables.',
  ),
  PlantProfile(
    id: 'hibiscus',
    scientificName: 'Hibiscus rosa-sinensis',
    commonName: 'Chinese hibiscus',
    localName: 'Kembang sepatu',
    category: PlantCategory.shrub,
    habitat: 'Gardens, fences and schoolyards',
    description:
        'A bushy shrub with shiny leaves and large, trumpet-shaped flowers, '
        'often bright red, with a long, pollen-covered stalk in the middle.',
    funFact:
        'It is called "shoe flower" because people once rubbed the petals on '
        'shoes to make them shine.',
    uses: 'Planted as a colorful hedge. Its flowers feed bees and sunbirds.',
  ),
  PlantProfile(
    id: 'aloe_vera',
    scientificName: 'Aloe vera',
    commonName: 'Aloe vera',
    localName: 'Lidah buaya',
    category: PlantCategory.succulent,
    habitat: 'Dry, sunny places and flower pots',
    description:
        'A plant with thick, juicy leaves that have soft spikes along the '
        'edges. The leaves store water for dry days.',
    funFact:
        'Its Indonesian name means "crocodile tongue" because of its long, '
        'pointy leaves.',
    uses: 'The clear gel inside the leaves soothes dry skin and small burns.',
    caution:
        'Do not eat it. The yellow sap under the skin of the leaf upsets your '
        'stomach.',
  ),
  PlantProfile(
    id: 'mimosa',
    scientificName: 'Mimosa pudica',
    commonName: 'Sensitive plant',
    localName: 'Putri malu',
    category: PlantCategory.herb,
    habitat: 'Grassy fields and roadsides',
    description:
        'A small creeping plant with feathery leaves and fluffy pink flowers '
        'shaped like pom-poms.',
    funFact:
        'Touch its leaves and they fold up in a few seconds. This may scare '
        'away hungry insects.',
    uses:
        'Like beans, its roots add nitrogen to the soil, and bees visit its '
        'flowers.',
    caution: 'Its stems have small thorns. Touch the leaves gently.',
  ),
  PlantProfile(
    id: 'monstera',
    scientificName: 'Monstera deliciosa',
    commonName: 'Swiss cheese plant',
    localName: 'Monstera',
    category: PlantCategory.vine,
    habitat: 'Rainforests, homes and offices',
    description:
        'A climbing plant with big, glossy leaves full of holes and cuts. It '
        'uses air roots to climb up trees.',
    funFact:
        'Young leaves have no holes. The holes appear as the leaves grow and '
        'may help them let light through to lower leaves.',
    uses: 'A popular houseplant that makes rooms greener.',
    caution: 'Its leaves sting your mouth if chewed. Keep away from pets.',
  ),
  PlantProfile(
    id: 'guava',
    scientificName: 'Psidium guajava',
    commonName: 'Guava',
    localName: 'Jambu biji',
    category: PlantCategory.fruit,
    habitat: 'Yards and orchards in warm places',
    description:
        'A small tree with smooth bark that peels off in flakes. Its round '
        'fruit is green outside and white or pink inside, full of seeds.',
    funFact: 'A guava has about four times more vitamin C than an orange.',
    uses: 'The fruit is eaten fresh or made into juice.',
  ),
  PlantProfile(
    id: 'frangipani',
    scientificName: 'Plumeria rubra',
    commonName: 'Frangipani',
    localName: 'Kamboja',
    category: PlantCategory.tree,
    habitat: 'Gardens, temples and parks',
    description:
        'A small tree with thick branches and sweet-smelling flowers that have '
        'five petals.',
    funFact:
        'Its flowers smell strongest at night to attract moths, but they have '
        'no nectar. The moths are tricked into carrying the pollen.',
    uses: 'In Bali the flowers are used in daily offerings called canang sari.',
    caution: 'The milky sap can irritate your skin and eyes.',
  ),
  PlantProfile(
    id: 'lantana',
    scientificName: 'Lantana camara',
    commonName: 'Lantana',
    localName: 'Tembelekan',
    category: PlantCategory.shrub,
    habitat: 'Roadsides, fields and gardens',
    description:
        'A rough, bushy shrub with small flowers in round clusters and a '
        'strong smell.',
    funFact:
        'Its flowers change color as they get older, so one cluster can be '
        'yellow, orange and pink at the same time.',
    uses: 'Butterflies love its flowers.',
    caution: 'Its berries and leaves are poisonous. Never eat them.',
  ),
  PlantProfile(
    id: 'periwinkle',
    scientificName: 'Catharanthus roseus',
    commonName: 'Madagascar periwinkle',
    localName: 'Tapak dara',
    category: PlantCategory.flower,
    habitat: 'Gardens, pots and sandy places',
    description:
        'A small plant with shiny leaves and pink or white flowers with five '
        'flat petals. It blooms almost all year.',
    funFact:
        'Scientists made important medicines for fighting cancer from this '
        'plant.',
    uses: 'Grown as a pretty garden flower and studied for medicine.',
    caution: 'The whole plant is poisonous if eaten.',
  ),
  PlantProfile(
    id: 'canna',
    scientificName: 'Canna indica',
    commonName: 'Indian shot',
    localName: 'Bunga tasbih',
    category: PlantCategory.flower,
    habitat: 'Wet gardens and riverbanks',
    description:
        'A tall plant with wide, paddle-shaped leaves and bright red or '
        'orange flowers.',
    funFact:
        'Its round black seeds are so hard that people used them as beads, '
        'which is why it is called "tasbih" flower.',
    uses: 'Its seeds are made into beads and its leaves wrap food.',
  ),
  PlantProfile(
    id: 'chili',
    scientificName: 'Capsicum annuum',
    commonName: 'Chili pepper',
    localName: 'Cabai',
    category: PlantCategory.vegetable,
    habitat: 'Gardens and farms',
    description:
        'A small bushy plant with white flowers. Its fruits start green and '
        'turn red, orange or yellow when ripe.',
    funFact:
        'The spicy taste comes from capsaicin. Birds cannot feel it, so they '
        'eat the fruits and spread the seeds.',
    uses: 'An important spice in Indonesian food, like sambal.',
    caution: 'Wash your hands after touching chilies and do not rub your eyes.',
  ),
  PlantProfile(
    id: 'tomato',
    scientificName: 'Solanum lycopersicum',
    commonName: 'Tomato',
    localName: 'Tomat',
    category: PlantCategory.vegetable,
    habitat: 'Gardens and farms',
    description:
        'A soft-stemmed plant with hairy leaves, small yellow flowers and '
        'juicy red fruits.',
    funFact:
        'Scientists call the tomato a fruit, because it grows from a flower '
        'and has seeds inside.',
    uses: 'Eaten fresh or cooked. It is full of vitamin C.',
    caution: 'Only the ripe fruit is food. Do not eat the leaves or stems.',
  ),
  PlantProfile(
    id: 'mangrove',
    scientificName: 'Rhizophora mangle',
    commonName: 'Red mangrove',
    localName: 'Bakau',
    category: PlantCategory.tree,
    habitat: 'Muddy, salty coasts',
    description:
        'A tree that grows in salty seawater and stands on arching stilt '
        'roots. It is a close relative of the bakau trees on Indonesian '
        'coasts.',
    funFact:
        'Its seeds sprout while they still hang on the tree, then drop into '
        'the mud like little spears.',
    uses:
        'Mangroves protect coasts from big waves, give homes to fish and '
        'crabs, and store lots of carbon.',
  ),
  PlantProfile(
    id: 'poinsettia',
    scientificName: 'Euphorbia pulcherrima',
    commonName: 'Poinsettia',
    localName: 'Kastuba',
    category: PlantCategory.shrub,
    habitat: 'Gardens and flower pots',
    description:
        'A shrub with bright red leaves at the top of its branches. The real '
        'flowers are the tiny yellow buds in the middle.',
    funFact:
        'The red parts are not petals. They are colored leaves called bracts.',
    uses: 'A popular decoration plant.',
    caution: 'Its milky sap can irritate your skin.',
  ),
  PlantProfile(
    id: 'purslane',
    scientificName: 'Portulaca oleracea',
    commonName: 'Purslane',
    localName: 'Krokot',
    category: PlantCategory.herb,
    habitat: 'Sidewalk cracks, fields and gardens',
    description:
        'A low plant with thick, juicy leaves, reddish stems and tiny yellow '
        'flowers.',
    funFact:
        'Purslane has omega-3 fats, which are usually found in fish and are '
        'good for the brain.',
    uses: 'It is eaten as a vegetable in many countries.',
  ),
  PlantProfile(
    id: 'bird_of_paradise',
    scientificName: 'Strelitzia reginae',
    commonName: 'Bird of paradise',
    localName: 'Bunga cendrawasih',
    category: PlantCategory.flower,
    habitat: 'Sunny gardens',
    description:
        'A plant with large leaves and orange and blue flowers that look like '
        'the head of a colorful bird.',
    funFact:
        'When a bird lands on the flower to drink nectar, the flower dusts its '
        'feet with pollen.',
    uses: 'A favorite garden and bouquet flower.',
  ),
  PlantProfile(
    id: 'cosmos',
    scientificName: 'Cosmos bipinnatus',
    commonName: 'Garden cosmos',
    localName: 'Bunga kosmos',
    category: PlantCategory.flower,
    habitat: 'Sunny fields and gardens',
    description:
        'A slim plant with thin, feathery leaves and daisy-like flowers in '
        'pink, purple or white.',
    funFact:
        'Its name comes from the Greek word "kosmos", which means harmony, '
        'because its petals are so neatly arranged.',
    uses: 'Planted to attract bees and butterflies.',
  ),
  PlantProfile(
    id: 'dandelion',
    scientificName: 'Taraxacum officinale',
    commonName: 'Dandelion',
    localName: 'Randa tapak',
    category: PlantCategory.herb,
    habitat: 'Lawns, fields and mountain meadows',
    description:
        'A low plant with toothed leaves and a bright yellow flower that '
        'turns into a fluffy white ball of seeds.',
    funFact:
        'Each seed has a tiny parachute, so the wind can carry it far away.',
    uses: 'Its young leaves can be eaten, and bees feed on its flowers.',
  ),
  PlantProfile(
    id: 'wild_carrot',
    scientificName: 'Daucus carota',
    commonName: 'Wild carrot',
    localName: 'Wortel liar',
    category: PlantCategory.herb,
    habitat: 'Fields and roadsides',
    description:
        'A plant with lacy leaves and flat, white flower clusters that look '
        'like an umbrella.',
    funFact:
        'The orange carrots we eat were bred from this wild plant, which has '
        'a thin white root.',
    uses: 'Its flowers feed many helpful insects.',
    caution:
        'It looks like poisonous plants, so never pick wild plants to eat.',
  ),
  PlantProfile(
    id: 'water_lily',
    scientificName: 'Nymphaea alba',
    commonName: 'White water lily',
    localName: 'Teratai putih',
    category: PlantCategory.aquatic,
    habitat: 'Ponds and calm lakes',
    description:
        'A water plant with round leaves that float on the water and big white '
        'flowers.',
    funFact:
        'Its leaves breathe through tiny holes on the top side, while most '
        'plants have them underneath.',
    uses: 'Gives shade and shelter to fish and frogs in ponds.',
  ),
  PlantProfile(
    id: 'water_hyacinth',
    scientificName: 'Eichhornia crassipes',
    commonName: 'Water hyacinth',
    localName: 'Eceng gondok',
    category: PlantCategory.aquatic,
    habitat: 'Rivers, lakes and ponds',
    description:
        'A floating plant with puffy, air-filled leaf stalks and pale purple '
        'flowers.',
    funFact:
        'It grows so fast that it can double in number in about two weeks and '
        'cover a whole lake.',
    uses: 'Its dried stems are woven into bags, mats and furniture.',
    caution:
        'It blocks sunlight for fish and other plants. Never release it into '
        'rivers.',
  ),
  PlantProfile(
    id: 'taro',
    scientificName: 'Colocasia esculenta',
    commonName: 'Taro',
    localName: 'Talas',
    category: PlantCategory.vegetable,
    habitat: 'Wet fields and riverbanks',
    description:
        'A plant with huge, heart-shaped leaves on long stalks. It stores food '
        'in a round underground stem.',
    funFact:
        'Water rolls off its leaves in shiny drops because the leaf surface is '
        'waterproof.',
    uses: 'The underground part is a starchy food that is boiled or steamed.',
    caution: 'Raw taro makes your mouth itchy. It must always be cooked.',
  ),
  PlantProfile(
    id: 'flame_tree',
    scientificName: 'Delonix regia',
    commonName: 'Flame tree',
    localName: 'Flamboyan',
    category: PlantCategory.tree,
    habitat: 'Roadsides, parks and schoolyards',
    description:
        'A wide, umbrella-shaped tree with fern-like leaves that is covered in '
        'bright red-orange flowers.',
    funFact:
        'Its brown seed pods can grow up to 60 cm long and rattle like '
        'maracas.',
    uses: 'Planted for shade and for its beautiful flowers.',
  ),
  PlantProfile(
    id: 'leadtree',
    scientificName: 'Leucaena leucocephala',
    commonName: 'White leadtree',
    localName: 'Lamtoro',
    category: PlantCategory.tree,
    habitat: 'Fields, fences and dry hills',
    description:
        'A fast-growing small tree with tiny leaflets, round white flower '
        'balls and long, flat seed pods.',
    funFact:
        'Its roots team up with bacteria to add nitrogen to the soil, which '
        'feeds other plants.',
    uses:
        'Its leaves feed goats and cows, and young seeds are eaten in some '
        'Indonesian dishes.',
  ),
  PlantProfile(
    id: 'castor_bean',
    scientificName: 'Ricinus communis',
    commonName: 'Castor bean',
    localName: 'Jarak',
    category: PlantCategory.shrub,
    habitat: 'Roadsides and empty lots',
    description:
        'A tall shrub with big, star-shaped leaves and spiky seed pods.',
    funFact: 'Castor oil from its seeds is used to make soap, paint and oil.',
    uses: 'Grown on farms for castor oil.',
    caution: 'Its seeds are very poisonous. Never eat or chew them.',
  ),
  PlantProfile(
    id: 'prickly_pear',
    scientificName: 'Opuntia ficus-indica',
    commonName: 'Prickly pear cactus',
    localName: 'Kaktus pir',
    category: PlantCategory.succulent,
    habitat: 'Dry, rocky places and pots',
    description:
        'A cactus made of flat, paddle-shaped pads covered with spines. It '
        'grows yellow flowers and sweet fruits.',
    funFact: 'The flat pads are its stems. Its spines are actually its leaves.',
    uses: 'The fruits and young pads are eaten in Mexico.',
    caution: 'It has tiny hair-like spines that stick in your skin.',
  ),
  PlantProfile(
    id: 'water_lettuce',
    scientificName: 'Pistia stratiotes',
    commonName: 'Water lettuce',
    localName: 'Kayu apu',
    category: PlantCategory.aquatic,
    habitat: 'Ponds, ditches and slow rivers',
    description:
        'A floating rosette of soft, velvety leaves that looks like a small '
        'lettuce.',
    funFact:
        'Tiny hairs on its leaves trap air and keep it dry, so it can float.',
    uses: 'Gives shelter to small fish in ponds.',
    caution: 'It spreads very fast. Never release it into rivers.',
  ),
  PlantProfile(
    id: 'crape_myrtle',
    scientificName: 'Lagerstroemia indica',
    commonName: 'Crape myrtle',
    localName: 'Bungur',
    category: PlantCategory.tree,
    habitat: 'Streets, parks and gardens',
    description:
        'A small tree with smooth, peeling bark and clusters of crinkly pink '
        'or purple flowers.',
    funFact:
        'Its petals look like crinkled crepe paper, which gives the tree its '
        'name.',
    uses: 'Planted along streets for shade and color.',
  ),
  PlantProfile(
    id: 'spanish_needles',
    scientificName: 'Bidens pilosa',
    commonName: 'Spanish needles',
    localName: 'Ketul',
    category: PlantCategory.herb,
    habitat: 'Fields, yards and roadsides',
    description:
        'A common wild plant with small flowers that have white petals and a '
        'yellow center.',
    funFact:
        'Its seeds have tiny hooks that stick to your socks, so you help carry '
        'them to new places.',
    uses: 'Its flowers are an important food for bees.',
  ),
  PlantProfile(
    id: 'woodsorrel',
    scientificName: 'Oxalis corniculata',
    commonName: 'Creeping woodsorrel',
    localName: 'Calincing',
    category: PlantCategory.herb,
    habitat: 'Lawns, pots and garden paths',
    description:
        'A tiny creeping plant with heart-shaped leaflets in groups of three '
        'and small yellow flowers.',
    funFact: 'Its ripe seed pods burst open when touched and shoot seeds away.',
    uses: 'Its leaves taste sour and were used to flavor food.',
    caution: 'Eating a lot of it is not healthy.',
  ),
  PlantProfile(
    id: 'beach_morning_glory',
    scientificName: 'Ipomoea pes-caprae',
    commonName: 'Beach morning glory',
    localName: 'Katang-katang',
    category: PlantCategory.vine,
    habitat: 'Sandy beaches',
    description:
        'A vine that creeps over beach sand, with purple trumpet flowers and '
        'thick, two-lobed leaves.',
    funFact:
        'Its scientific name "pes-caprae" means "goat\'s foot", because the '
        'leaves look like a goat\'s footprint.',
    uses: 'Its long runners hold the sand of beaches in place.',
  ),
  PlantProfile(
    id: 'strawberry',
    scientificName: 'Fragaria vesca',
    commonName: 'Wild strawberry',
    localName: 'Stroberi liar',
    category: PlantCategory.fruit,
    habitat: 'Cool forests and mountain gardens',
    description:
        'A low plant with leaves in groups of three, small white flowers and '
        'tiny, sweet red berries.',
    funFact:
        'The little "seeds" on the outside are the real fruits. Each one has a '
        'seed inside.',
    uses: 'Its berries are eaten fresh or made into jam.',
  ),
  PlantProfile(
    id: 'apple',
    scientificName: 'Malus ×domestica',
    commonName: 'Apple',
    localName: 'Apel',
    category: PlantCategory.fruit,
    habitat: 'Cool highlands, like Batu in East Java',
    description:
        'A tree with white or pink blossoms and round, crunchy fruits.',
    funFact:
        'Apples float in water, because about a quarter of an apple is air.',
    uses: 'Its fruit is eaten fresh or made into juice.',
  ),
  PlantProfile(
    id: 'nettle',
    scientificName: 'Urtica dioica',
    commonName: 'Stinging nettle',
    localName: 'Jelatang',
    category: PlantCategory.herb,
    habitat: 'Forest edges and damp fields',
    description:
        'A plant with saw-toothed leaves that are covered with tiny stinging '
        'hairs.',
    funFact:
        'Each stinging hair works like a tiny needle that breaks when you '
        'touch it.',
    uses: 'Its stems were used to make cloth, and cooked leaves are a food.',
    caution: 'Do not touch it. It stings and itches.',
  ),
  PlantProfile(
    id: 'yellow_bells',
    scientificName: 'Tecoma stans',
    commonName: 'Yellow bells',
    localName: 'Tekoma',
    category: PlantCategory.shrub,
    habitat: 'Gardens and roadsides',
    description:
        'A shrub with toothed leaves and bunches of bright yellow, bell-shaped '
        'flowers.',
    funFact: 'Bees crawl right inside its bell-shaped flowers to find nectar.',
    uses: 'Planted for its cheerful flowers.',
  ),
  PlantProfile(
    id: 'african_tulip',
    scientificName: 'Spathodea campanulata',
    commonName: 'African tulip tree',
    localName: 'Kecrutan',
    category: PlantCategory.tree,
    habitat: 'Parks and roadsides',
    description:
        'A tall tree with large, cup-shaped, orange-red flowers at the top of '
        'its branches.',
    funFact:
        'Its flower buds are full of water, and squeezing them makes a squirt, '
        'which is why it is called kecrutan.',
    uses: 'Planted for shade and its striking flowers.',
  ),
  PlantProfile(
    id: 'oleander',
    scientificName: 'Nerium oleander',
    commonName: 'Oleander',
    localName: 'Bunga mentega',
    category: PlantCategory.shrub,
    habitat: 'Gardens and road dividers',
    description:
        'An evergreen shrub with long, narrow leaves and pink or white '
        'flowers.',
    funFact: 'It is tough enough to grow in hot, dry places and by highways.',
    uses: 'Planted as a flowering hedge.',
    caution: 'Every part is very poisonous. Look, but never eat or chew it.',
  ),
];

final Map<String, PlantProfile> _byId = {
  for (final plant in plantCatalog) plant.id: plant,
};

final Map<String, PlantProfile> _byScientificName = {
  for (final plant in plantCatalog) plant.scientificName: plant,
};

PlantProfile plantById(String id) {
  final plant = _byId[id];
  if (plant == null) throw ArgumentError.value(id, 'id', 'Unknown plant');
  return plant;
}

PlantProfile? plantByScientificName(String scientificName) =>
    _byScientificName[scientificName];
