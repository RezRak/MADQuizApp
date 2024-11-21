import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quiz_screen.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  List categories = [];
  String? selectedCategory;
  String selectedDifficulty = 'easy';
  String selectedType = 'multiple';
  int numberOfQuestions = 5;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body)['trivia_categories'];
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  void startQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          numberOfQuestions: numberOfQuestions,
          category: selectedCategory,
          difficulty: selectedDifficulty,
          type: selectedType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Quiz Setup'),
        ),
        body: categories.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(labelText: 'Number of Questions'),
                      value: numberOfQuestions,
                      items: [5, 10, 15]
                          .map((num) => DropdownMenuItem(value: num, child: Text('$num')))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          numberOfQuestions = value!;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Category'),
                      value: selectedCategory,
                      items: categories
                          .map((category) => DropdownMenuItem(
                              value: category['id'].toString(), child: Text(category['name'])))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Difficulty'),
                      value: selectedDifficulty,
                      items: ['easy', 'medium', 'hard']
                          .map((difficulty) =>
                              DropdownMenuItem(value: difficulty, child: Text(difficulty)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDifficulty = value!;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Type'),
                      value: selectedType,
                      items: ['multiple', 'boolean']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: startQuiz,
                      child: Text('Start Quiz'),
                    ),
                  ],
                ),
              ));
  }
}