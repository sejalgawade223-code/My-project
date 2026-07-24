import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/* ================= APP ================= */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fertilizer E-Commerce',
      home: CategoryPage(),
    );
  }
}

/* ================= PRODUCT DATA ================= */

final List<Map<String, dynamic>> products = [
  {
    "name": "KU 20:10:10",
    "category": "Cereal crop",
    "stage": "Vegetative",
    "days": "15-30 days",
    "soil": "Loamy",
    "water": "Medium",
    "price": 1250,
    "image":
    "https://i.imgur.com/8Km9tLL.png",
    "benefits": "Improves tillering and green growth"
  },
  {
    "name": "KU 18:18:10",
    "category": "Cereal crop",
    "stage": "Flowering",
    "days": "30-60 days",
    "soil": "Clay",
    "water": "High",
    "price": 1350,
    "image":
    "https://i.imgur.com/QCNbOAo.png",
    "benefits": "Balanced nutrition during flowering"
  },
  {
    "name": "PDM Potash",
    "category": "Vegetables",
    "stage": "Fruit formation",
    "days": "More than 60 days",
    "soil": "Sandy",
    "water": "Low",
    "price": 950,
    "image":
    "https://i.imgur.com/Vz6E8KY.png",
    "benefits": "Improves fruit size and quality"
  },
  {
    "name": "KU 18:18:10",
    "category": "Fruit",
    "stage": "Vegetative",
    "days": "15-30 days",
    "soil": "Loamy",
    "water": "Medium",
    "price": 1450,
    "image":
    "https://i.imgur.com/4QyZ9Ym.png",
    "benefits": "Strengthens plant growth"
  },
];

List<Map<String, dynamic>> cart = [];

/* ================= RECOMMENDATION LOGIC ================= */

List<Map<String, dynamic>> recommendProducts(
    String category,
    String stage,
    String days,
    String soil,
    String water,
    ) {
  // Exact match
  final exact = products.where((p) =>
  p['category'] == category &&
      p['stage'] == stage &&
      p['days'] == days &&
      p['soil'] == soil &&
      p['water'] == water).toList();

  if (exact.isNotEmpty) return exact;

  // Partial match
  final partial = products.where((p) =>
  p['category'] == category &&
      p['stage'] == stage).toList();

  if (partial.isNotEmpty) return partial;

  // Category match
  final categoryMatch =
  products.where((p) => p['category'] == category).toList();

  return categoryMatch;
}

/* ================= CATEGORY PAGE ================= */

class CategoryPage extends StatelessWidget {
  final List<String> categories = [
    "Cereal crop",
    "Vegetables",
    "Fruit",
  ];

  CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Crop Category")),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (_, index) {
          return ListTile(
            title: Text(categories[index]),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizPage(category: categories[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/* ================= QUIZ PAGE ================= */

class QuizPage extends StatefulWidget {
  final String category;

  const QuizPage({super.key, required this.category});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String stage = "Vegetative";
  String days = "15-30 days";
  String soil = "Loamy";
  String water = "Medium";

  final List<String> stages = [
    "Seeding",
    "Vegetative",
    "Flowering",
    "Fruit formation",
  ];

  final List<String> daysList = [
    "Less than 15 days",
    "15-30 days",
    "30-60 days",
    "More than 60 days",
  ];

  final List<String> soilList = ["Loamy", "Clay", "Sandy"];
  final List<String> waterList = ["Low", "Medium", "High"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crop Quiz")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          dropdown("Growth Stage", stages, stage, (v) => stage = v),
          dropdown("Days Since Sowing", daysList, days, (v) => days = v),
          dropdown("Soil Type", soilList, soil, (v) => soil = v),
          dropdown("Water Availability", waterList, water, (v) => water = v),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductPage(
                    category: widget.category,
                    stage: stage,
                    days: days,
                    soil: soil,
                    water: water,
                  ),
                ),
              );
            },
            child: const Text("Get Recommendation"),
          )
        ],
      ),
    );
  }

  Widget dropdown(String label, List<String> items, String value,
      Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        DropdownButtonFormField(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

/* ================= PRODUCT PAGE ================= */

class ProductPage extends StatelessWidget {
  final String category, stage, days, soil, water;

  const ProductPage({
    super.key,
    required this.category,
    required this.stage,
    required this.days,
    required this.soil,
    required this.water,
  });

  @override
  Widget build(BuildContext context) {
    final result = recommendProducts(category, stage, days, soil, water);

    return Scaffold(
      appBar: AppBar(title: const Text("Recommended Fertilizers")),
      body: ListView.builder(
        itemCount: result.length,
        itemBuilder: (_, i) {
          final p = result[i];
          return Card(
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                Image.network(
                  p['image'],
                  height: 180,
                  fit: BoxFit.cover,
                ),
                ListTile(
                  title: Text(p['name']),
                  subtitle: Text(p['benefits']),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("₹${p['price']}"),
                      ElevatedButton(
                        onPressed: () {
                          cart.add(p);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Added to cart")),
                          );
                        },
                        child: const Text("Add"),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
