import 'package:flutter/material.dart';
import 'setup_screen.dart';
import '../models/question.dart';

class SummaryScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<Question> questions;
  final List<String> userAnswers;

  SummaryScreen(
      {required this.score,
      required this.totalQuestions,
      required this.questions,
      required this.userAnswers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Summary'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Your Score: $score / $totalQuestions',
              style: TextStyle(fontSize: 24),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  Question question = questions[index];
                  String userAnswer = userAnswers[index];
                  bool isCorrect = userAnswer == question.correctAnswer;
                  return ListTile(
                    title: Text(question.question),
                    subtitle: Text('Your answer: $userAnswer\nCorrect answer: ${question.correctAnswer}'),
                    trailing: Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SetupScreen()),
                    (route) => false);
              },
              child: Text('Retake Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}