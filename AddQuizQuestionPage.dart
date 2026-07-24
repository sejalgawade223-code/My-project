import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'translated_text.dart';

class AddQuizQuestionPage extends StatefulWidget {
  final Map? questionData;
  const AddQuizQuestionPage({super.key, this.questionData});

  @override
  State<AddQuizQuestionPage> createState() => _AddQuizQuestionPageState();
}

class _AddQuizQuestionPageState extends State<AddQuizQuestionPage> {
  final _formKey = GlobalKey<FormState>();

  String selectedCategory = "Cereal crop";
  final categories = ["Cereal crop", "Vegetables", "Fruit", "Flower"];

  final questionController = TextEditingController();
  final option1 = TextEditingController();
  final option2 = TextEditingController();
  final option3 = TextEditingController();
  final option4 = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.questionData != null) {
      selectedCategory = widget.questionData!['category'] ?? "Cereal crop";
      questionController.text = widget.questionData!['question'] ?? "";
      option1.text = widget.questionData!['option1'] ?? "";
      option2.text = widget.questionData!['option2'] ?? "";
      option3.text = widget.questionData!['option3'] ?? "";
      option4.text = widget.questionData!['option4'] ?? "";
    }
  }

  Future<void> saveQuestion() async {
    setState(() => _isSaving = true);
    try {
      Map<String, String> bodyData = {
        "category": selectedCategory,
        "question": questionController.text.trim(),
        "option1": option1.text.trim(),
        "option2": option2.text.trim(),
        "option3": option3.text.trim(),
        "option4": option4.text.trim(),
      };

      if (widget.questionData != null) {
        var idValue = widget.questionData!['question_id'] ?? widget.questionData!['id'];
        bodyData["id"] = idValue.toString();
      }

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}admin_quiz_api.php"),
        body: bodyData,
      );

      final data = jsonDecode(response.body);
      if (data["status"] == "success" && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: TText(data["message"] ?? "Success")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }


  Future<void> deleteQuestion() async {
    if (widget.questionData == null) return;
    try {

      var idValue = widget.questionData!['question_id'] ?? widget.questionData!['id'];

      final response = await http.post(

        Uri.parse("${ApiConfig.baseUrl}admin_quiz_api.php?action=delete"),
        body: {
          "id": idValue.toString(),
        },
      );


      debugPrint("Delete Response: ${response.body}");

      final data = jsonDecode(response.body);
      if (data["status"] == "success" && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted Successfully")));
        Navigator.pop(context, true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Delete Failed: ${data['message']}")));
        }
      }
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.questionData != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: TText(isEdit ? "Update Question" : "Add Question",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green[700],
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirm Delete"),
                    content: const Text("Do you want to delete this question?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            deleteQuestion();
                          },
                          child: const Text("Delete", style: TextStyle(color: Colors.red))
                      ),
                    ],
                  ),
                );
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: TText("Select Category", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.green),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.green[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: categories.map((c) => DropdownMenuItem(
                  value: c,
                  child: FutureBuilder<String>(
                    future: TranslationService.translate(c),
                    builder: (context, snapshot) => Text(snapshot.data ?? c),
                  ),
                )).toList(),
                onChanged: (v) => setState(() => selectedCategory = v!),
              ),
              const SizedBox(height: 20),
              _buildField(questionController, "Question", Icons.help_outline, maxLines: 2),
              _buildField(option1, "Option 1", Icons.looks_one_outlined),
              _buildField(option2, "Option 2", Icons.looks_two_outlined),
              _buildField(option3, "Option 3", Icons.looks_3_outlined),
              _buildField(option4, "Option 4", Icons.looks_4_outlined),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: _isSaving ? null : () {
                    if (_formKey.currentState!.validate()) saveQuestion();
                  },
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : TText(isEdit ? "Update" : "Save",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FutureBuilder<String>(
          future: TranslationService.translate(label),
          builder: (context, snapshot) {
            String translatedLabel = snapshot.data ?? label;
            return TextFormField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                labelText: translatedLabel,
                prefixIcon: Icon(icon, color: Colors.green[700]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.green, width: 2)),
              ),
              validator: (v) => v!.isEmpty ? "Required" : null,
            );
          }
      ),
    );
  }
}