import 'package:flashcardquiz/core/database/sqlite/db_helper.dart';
import 'package:flashcardquiz/models/flashcard_model.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<FlashCard> _flashcards = [];

  int _currentIndex = 0;
  int _score = 0;
  FlashCard? currentQuestion;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  void _loadFlashcards() async {
    final allQuestions = await DatabaseHelper().getFlashcards();
    allQuestions.shuffle();
    setState(() {
      _flashcards = allQuestions;
    });
  }

  void checkAnswer(int selectedIndex) {
    final isCorrect = selectedIndex == _flashcards[_currentIndex].correctIndex;

    if (isCorrect) {
      _score++;
    }
    if (_currentIndex < _flashcards.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      showCompletionDialog(); // Exibe o diálogo de conclusão quando todas as perguntas foram respondidas
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isCorrect ? "Correto!" : "Incorreto"),
        content: Text(
          isCorrect
              ? "Parabéns, você acertou!"
              : "A resposta correta era: ${_flashcards[_currentIndex].options[selectedIndex]}",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadFlashcards(); // Carrega uma nova pergunta após fechar o alerta
            },
            child: const Text("Próxima Pergunta"),
          ),
        ],
      ),
    );
  }

  // Diálogo de conclusão ao finalizar o quiz
  void showCompletionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Concluído!"),
        content:
            Text("Você acertou $_score de ${_flashcards.length} perguntas."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o diálogo
              Navigator.of(context).pop(); // Volta para a tela anterior
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Aleatório")),
      body: _flashcards.isEmpty
          ? const Center(
              child: Text('Sem perguntas', style: TextStyle(fontSize: 24)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Pergunta ${_currentIndex + 1} de ${_flashcards.length}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(_flashcards[_currentIndex].question,
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 20),
                    ...List.generate(
                      _flashcards[_currentIndex].options.length,
                      (index) => ElevatedButton(
                        onPressed: () => checkAnswer(index),
                        child: Text(_flashcards[_currentIndex].options[index]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
