import 'package:flashcardquiz/models/flashcard_model.dart';
import 'package:flashcardquiz/screens/flashcard/flashcard_form_screen.dart';
import 'package:flashcardquiz/screens/quiz/quiz_screen.dart';
import 'package:flutter/material.dart';

class Stackwidget extends StatefulWidget {
  final List<FlashCard> flashcard;
  final void Function()? loadFlashcards;
  const Stackwidget({super.key, required this.flashcard, this.loadFlashcards});

  @override
  State<Stackwidget> createState() => _StackwidgetState();
}

class _StackwidgetState extends State<Stackwidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Primeiro FloatingActionButton
        Positioned(
          right: 10,
          bottom: 10,
          child: widget.flashcard.isNotEmpty
              ? FloatingActionButton.small(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const QuizScreen(),
                    ));
                  },
                  tooltip: 'Iniciar Quiz',
                  child: const Icon(Icons.question_answer),
                )
              : Container(),
        ),
        // Segundo FloatingActionButton
        Positioned(
          right: 10,
          bottom: 100,
          child: FloatingActionButton.small(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FlashcardFormScreen(),
                  )).then((_) {
                setState(() {
                  widget.loadFlashcards;
                });
              });
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
