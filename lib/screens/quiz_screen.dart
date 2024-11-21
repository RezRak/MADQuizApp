import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/question.dart';
import 'summary_screen.dart';

class QuizScreen extends StatefulWidget {
  final int numberOfQuestions;
  final String? category;
  final String difficulty;
  final String type;

  QuizScreen(
      {required this.numberOfQuestions,
      required this.category,
      required this.difficulty,
      required this.type});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isLoading = true;
  bool isAnswered = false;
  String feedback = '';
  int timer = 15;
  late Future<void> loadQuestionsFuture;
  late PageController _pageController;
  List<String> userAnswers = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    loadQuestionsFuture = fetchQuestions();
    startTimer();
  }

  Future<void> fetchQuestions() async {
    String url = 'https://opentdb.com/api.php?amount=${widget.numberOfQuestions}';
    if (widget.category != null) url += '&category=${widget.category}';
    url += '&difficulty=${widget.difficulty}';
    url += '&type=${widget.type}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List results = json.decode(response.body)['results'];
      setState(() {
        questions = results.map((q) => Question.fromJson(q)).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load questions');
    }
  }

  void startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        if (timer > 0 && !isAnswered) {
          setState(() {
            timer--;
          });
          startTimer();
        } else if (timer == 0 && !isAnswered) {
          setState(() {
            isAnswered = true;
            feedback = "Time's up!";
            userAnswers.add('No Answer');
          });
          proceedToNextQuestion();
        }
      }
    });
  }

  void checkAnswer(String answer) {
    setState(() {
      isAnswered = true;
      userAnswers.add(answer);
      if (answer == questions[currentQuestionIndex].correctAnswer) {
        score++;
        feedback = 'Correct!';
      } else {
        feedback = 'Incorrect! The correct answer was ${questions[currentQuestionIndex].correctAnswer}.';
      }
    });
    proceedToNextQuestion();
  }

  void proceedToNextQuestion() {
    Future.delayed(Duration(seconds: 2), () {
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          isAnswered = false;
          feedback = '';
          timer = 15;
        });
        _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
        startTimer();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryScreen(
              score: score,
              totalQuestions: questions.length,
              questions: questions,
              userAnswers: userAnswers,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Quiz'),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / questions.length,
                    minHeight: 8,
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Time Left: $timer seconds',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        return buildQuestion(questions[index]);
                      },
                    ),
                  ),
                  if (feedback.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        feedback,
                        style: TextStyle(fontSize: 20, color: Colors.red),
                      ),
                    ),
                ],
              ));
  }

  Widget buildQuestion(Question question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            question.question,
            style: TextStyle(fontSize: 20),
          ),
        ),
        ...question.options.map((option) {
          return ListTile(
            title: Text(option),
            onTap: isAnswered ? null : () => checkAnswer(option),
          );
        }).toList(),
      ],
    );
  }
}