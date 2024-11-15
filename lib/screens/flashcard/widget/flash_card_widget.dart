import 'dart:math';

import 'package:flashcardquiz/core/database/sqlite/db_helper.dart';
import 'package:flashcardquiz/core/ui/ger_colors.dart';
import 'package:flashcardquiz/models/flashcard_model.dart';
import 'package:flashcardquiz/screens/flashcard/flashcard_form_screen.dart';
import 'package:flutter/material.dart';

class FlashCardWidget extends StatefulWidget {
  final FlashCard flashcard;
  final void Function()? loadFlashcards;

  const FlashCardWidget(
      {super.key, required this.flashcard, required this.loadFlashcards});

  @override
  _FlashCardWidgetState createState() => _FlashCardWidgetState();
}

class _FlashCardWidgetState extends State<FlashCardWidget> {
  bool _isFlipped = false;
  late Color _frontColor;
  late Color _backColor;

  @override
  void initState() {
    super.initState();
    _frontColor = getRandomColor(); // Cor aleatória para o lado da pergunta
    _backColor = getRandomColor(); // Cor aleatória para o lado da resposta
  }

  void _toggleCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _toggleCard,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final rotate = Tween(begin: pi, end: 0.0).animate(animation);
              return AnimatedBuilder(
                animation: rotate,
                child: child,
                builder: (context, child) {
                  final isUnder = ValueKey(_isFlipped) != child!.key;
                  final rotationY = isUnder ? pi : 0.0;
                  return Transform(
                    transform: Matrix4.rotationY(rotationY + rotate.value),
                    alignment: Alignment.center,
                    child: child,
                  );
                },
              );
            },
            child: _isFlipped ? _buildAnswerSide() : _buildQuestionSide(),
          ),
        ),
        Positioned(
          left: 10,
          child: IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) =>
                    FlashcardFormScreen(flashcard: widget.flashcard),
              ))
                  .then((_) {
                widget
                    .loadFlashcards!(); // Recarregar os flashcards após editar
              });
            },
            icon: Icon(
              Icons.edit,
              color: Colors.blue[50],
            ),
          ),
        ),
        Positioned(
          left: 50,
          child: IconButton(
            onPressed: () async {
              await DatabaseHelper().deleteFlashcard(widget.flashcard.id!);
              setState(() {
                widget
                    .loadFlashcards!(); // Recarregar os flashcards após editar
              });
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.redAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionSide() {
    return Container(
      key: const ValueKey(false),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _frontColor,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          widget.flashcard.question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 10,
        ),
      ),
    );
  }

  Widget _buildAnswerSide() {
    return Container(
      key: const ValueKey(true),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backColor,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.flashcard.options[widget.flashcard.correctIndex],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
        maxLines: 10,
        softWrap: true,
      ),
    );
  }
}
