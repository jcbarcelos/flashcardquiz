// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flashcardquiz/screens/flashcard/widget/flash_card_widget.dart';
import 'package:flutter/material.dart';

import 'package:flashcardquiz/models/flashcard_model.dart';

class GridViewWidget extends StatelessWidget {
  final List<FlashCard> flashcards;
  final void Function()? loadFlashcards;
  const GridViewWidget({
    super.key,
    required this.flashcards,
    required this.loadFlashcards,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 3 / 2,
      ),
      itemCount: flashcards.length,
      itemBuilder: (context, index) {
        return FlashCardWidget(
          flashcard: flashcards[index],
          loadFlashcards: loadFlashcards,
        );
      },
    );
  }
}
