class Monkey {
  final String name;
  final String scientificName;
  final String imagePath;
  final String description;
  final String lifespan;
  final String place;
  final String diet;
  final String habitat;
  final double latitude;
  final double longitude;

  const Monkey({
    required this.name,
    required this.scientificName,
    required this.imagePath,
    required this.description,
    required this.lifespan,
    required this.place,
    this.diet = "Omnivore",
    this.habitat = "Forest",
    this.latitude = 0.0,
    this.longitude = 0.0,
  });
}

typedef Papaya = Monkey;
typedef PapayaMaturity = Monkey;

const List<Monkey> monkeyData = [
  Monkey(
    name: "Papaya Unripe",
    scientificName: "Carica papaya (Stage 1 - Mature Green)",
    imagePath: "assets/images/papaya_unripe.png",
    description: "Completely dark green and firm on the outside. Flesh is dense, pale white or light green with immature seeds. High in papain enzyme, dietary fiber, and vitamins. Widely used for culinary dishes like green papaya salad (Som Tum), pickling, and digestive health.",
    lifespan: "0% - 15% Yellowing",
    place: "Mature Green Stage",
    habitat: "Crisp & Firm Texture",
    diet: "Cooking & Pickling",
    latitude: 14.5995,
    longitude: 120.9842,
  ),
  Monkey(
    name: "Papaya Ripening",
    scientificName: "Carica papaya (Stage 2 - Turning / Breaker)",
    imagePath: "assets/images/papaya_ripening.png",
    description: "Skin transitions with distinct yellow patches covering 16% to 75% of the fruit surface. Flesh begins softening into a delicate orange hue with rising natural sugar content. Perfect for fresh snacking or light culinary desserts.",
    lifespan: "16% - 75% Yellowing",
    place: "Turning / Breaker Stage",
    habitat: "Semi-Firm Texture",
    diet: "Fresh Snacking & Sweets",
    latitude: 14.5995,
    longitude: 120.9842,
  ),
  Monkey(
    name: "Papaya Ripe",
    scientificName: "Carica papaya (Stage 3 - Fully Ripe)",
    imagePath: "assets/images/papaya_ripe.png",
    description: "Skin is vibrant golden-orange with minimal green remaining (>76% yellow). Flesh is deep salmon-orange, tender, juicy, and intensely sweet with glossy black seeds. Rich in vitamins A and C, beta-carotene, and antioxidants.",
    lifespan: "76% - 100% Yellowing",
    place: "Fully Ripe Stage",
    habitat: "Soft, Juicy & Sweet",
    diet: "Fresh Fruit, Smoothies & Bowls",
    latitude: 14.5995,
    longitude: 120.9842,
  ),
  Monkey(
    name: "Papaya Overripe",
    scientificName: "Carica papaya (Stage 4 - Overripe / Senescent)",
    imagePath: "assets/images/papaya_overripe.png",
    description: "Skin transitions to a deep amber-orange speckled with distinctive brown or black sunken freckles. The flesh is softened, intensely fragrant, and high in concentrated natural sugars. Best suited for blending into healthy smoothies, natural purees, dessert baking, or rich compost.",
    lifespan: "Dark Freckles & Soft Peel",
    place: "Overripe / Senescent Stage",
    habitat: "Very Soft & Fragrant",
    diet: "Smoothies, Purees & Baking",
    latitude: 14.5995,
    longitude: 120.9842,
  ),
];
