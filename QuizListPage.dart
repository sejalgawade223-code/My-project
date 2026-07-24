import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'AddQuizQuestionPage.dart';
import 'api_config.dart';
import 'translated_text.dart';

class QuizListPage extends StatefulWidget {
  const QuizListPage({super.key});

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  List questions = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }



  Future<void> fetchQuestions() async {
    try {
      final res = await http.get(Uri.parse("${ApiConfig.baseUrl}admin_quiz_api.php?action=view"));
      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            questions = jsonDecode(res.body);
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      debugPrint("Error: $e");
    }
  }

  Future<void> deleteQue(String id) async {
    try {
      await http.post(
          Uri.parse("${ApiConfig.baseUrl}admin_quiz_api.php?action=delete"),
          body: {"id": id}
      );
      fetchQuestions();
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const TText("Manage Quiz Questions", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const AddQuizQuestionPage())
        ).then((_) => fetchQuestions()),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : questions.isEmpty
          ? const Center(child: TText("No questions found"))
          : Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 6,
        radius: const Radius.circular(10),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          itemCount: questions.length,
          itemBuilder: (context, i) {
            final q = questions[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: Colors.green[50],
                  child: Text("${i + 1}", style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold)),
                ),
                title: TText(
                  q['question'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const TText("Category", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(": ${q['category']}", style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => AddQuizQuestionPage(questionData: q))
                      ).then((_) => fetchQuestions()),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _showDeleteDialog(q['question_id'].toString()),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const TText("Delete Question"),
        content: const TText("Are you sure you want to delete this question?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const TText("Cancel")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
            onPressed: () {
              Navigator.pop(context);
              deleteQue(id);
            },
            child: const TText("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}