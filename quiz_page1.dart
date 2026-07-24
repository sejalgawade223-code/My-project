import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_service.dart';
import 'recommended_products_page.dart';
import 'api_config.dart';
import 'translated_text.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final ScrollController _scrollController = ScrollController();

  final List<String> categories = [
    "Cereal crop",
    "Vegetables",
    "Fruit",
  ];

  String? selectedCategory;
  List<dynamic> questions = [];
  Map<int, String> selectedOptions = {};
  bool isLoading = false;




  Future<void> fetchQuestions(String category) async {
    setState(() {
      isLoading = true;
      questions.clear();
      selectedOptions.clear();
    });

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}fetch_quiz_questions.php?category=$category"),
      );

      final data = jsonDecode(response.body);
      if (data["status"] == "success") {
        setState(() => questions = data["data"]);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: TText("Server error")),
        );
      }
    }

    if (mounted) setState(() => isLoading = false);
  }


  Future<void> submitQuiz() async {
    if (selectedOptions.length < questions.length || questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: TText("Please answer all questions")),
      );
      return;
    }

    setState(() => isLoading = true);

    String problem = selectedOptions[3] ?? "";
    String pref = selectedOptions[4] ?? "";

    final results = await ProductService.fetchRecommendations(
      problem: problem,
      pref: pref,
    );

    if (mounted) setState(() => isLoading = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecommendedProductsPage(products: results),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f9f6),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Color(0xff2e7d32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const TText("🌱 Fertilizer Quiz", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  hint: const TText("Select Category"),
                  value: selectedCategory,
                  items: categories.map((c) => DropdownMenuItem(
                    value: c,
                    child: TText(c),
                  )).toList(),
                  onChanged: (v) {
                    setState(() => selectedCategory = v);
                    fetchQuestions(v!);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.green)),

            if (!isLoading && questions.isNotEmpty)
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: questions.length,
                    padding: const EdgeInsets.only(bottom: 20),
                    itemBuilder: (_, index) {
                      final q = questions[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.green.withOpacity(0.1),
                                    child: Text("${index + 1}", style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 10),
                                  const TText("Question", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 12),


                              TText(
                                q["question"],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 15),


                              ...List.generate(
                                q["options"].length,
                                    (i) {
                                  String optionValue = q["options"][i].toString();
                                  bool isSelected = selectedOptions[index] == optionValue;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isSelected ? Colors.green.withOpacity(0.05) : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected ? Colors.green : Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: RadioListTile<String>(
                                      activeColor: Colors.green,
                                      title: TText(optionValue, style: TextStyle(color: isSelected ? Colors.green[800] : Colors.black87)),
                                      value: optionValue,
                                      groupValue: selectedOptions[index],
                                      onChanged: (v) {
                                        setState(() => selectedOptions[index] = v!);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),


      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: submitQuiz,
          child: const TText(
            "Submit Quiz",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}


