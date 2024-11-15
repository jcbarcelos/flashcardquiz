import 'package:flashcardquiz/models/flashcard_model.dart';
import 'package:flashcardquiz/screens/flashcard/widget/flash_card_widget.dart';
import 'package:flutter/material.dart';

class ListViewWidget extends StatelessWidget {
  final List<FlashCard> flashcards;
  final void Function()? loadFlashcards;
  const ListViewWidget({
    super.key,
    required this.flashcards,
    required this.loadFlashcards,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: flashcards.length,
      itemBuilder: (BuildContext context, int index) {
        return SizedBox(
          height: 150,
          child: FlashCardWidget(
            flashcard: flashcards[index],
            loadFlashcards: loadFlashcards,
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
