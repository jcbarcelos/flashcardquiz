// flashcard_list_screen.dart
import 'dart:io' show Platform;

import 'package:flashcardquiz/core/database/sqlite/db_helper.dart';
import 'package:flashcardquiz/models/flashcard_model.dart';
import 'package:flashcardquiz/screens/flashcard/widget/flash_card_widget.dart';
import 'package:flashcardquiz/screens/quiz/quiz_screen.dart';
import 'package:flutter/material.dart';

import 'flashcard_form_screen.dart';

class FlashCardListScreen extends StatefulWidget {
  const FlashCardListScreen({super.key});

  @override
  _FlashCardListScreenState createState() => _FlashCardListScreenState();
}

class _FlashCardListScreenState extends State<FlashCardListScreen> {
  List<FlashCard> _flashcards = [];
  bool _isGridMode = true;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Função para criar backup
  Future<void> _backupDatabase() async {
    try {
      String message = await _dbHelper.backupDatabase();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      print('e.toString( ) ${e.toString()}');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // Função para restaurar banco de dados
  Future<void> _restoreDatabase() async {
    try {
      String message = await _dbHelper.restoreDatabase();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        _loadFlashcards();
      }); // Atualiza a interface após restauração
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  void _loadFlashcards() async {
    List<FlashCard> flashcards = await DatabaseHelper().getFlashcards();
    setState(() {
      _flashcards = flashcards;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Platform.isLinux || Platform.isWindows
            ? null
            : const Text('Flash Cards Quiz'),
        actions: [
          Row(
            children: [
              if (_isGridMode)
                IconButton(
                  icon: const Icon(Icons.grid_on),
                  onPressed: () {
                    setState(() {
                      _isGridMode = false;
                    });
                  },
                )
              else
                IconButton(
                  icon: const Icon(Icons.list),
                  onPressed: () {
                    setState(() {
                      _isGridMode = true;
                    });
                  },
                ),
              const SizedBox(
                width: 50.0,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FlashcardFormScreen(),
                      )).then((_) {
                    setState(() {
                      _loadFlashcards();
                    });
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: _flashcards.isEmpty
          ? const Center(child: Text('Nenhum flashcard disponível.'))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isGridMode
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                        childAspectRatio: 3 / 2,
                      ),
                      itemCount: _flashcards.length,
                      itemBuilder: (context, index) {
                        return FlashCardWidget(
                            flashcard: _flashcards[index],
                            loadFlashcards: _loadFlashcards);
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: _flashcards.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 150,
                          child: FlashCardWidget(
                              flashcard: _flashcards[index],
                              loadFlashcards: _loadFlashcards),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                    ),
            ),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.zero,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: 70.0,
                  child: const Center(child: Text('Flash Card Quiz')),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.backup),
              onPressed: _backupDatabase,
              label: const Text("Fazer Backup"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.restore_outlined),
              onPressed: _restoreDatabase,
              label: const Text("Restaurar Backup"),
            ),
          ],
        ),
      ),
      floatingActionButton: _flashcards.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const QuizScreen(),
                ));
              },
              tooltip: 'Iniciar Quiz',
              child: const Icon(Icons.question_answer),
            )
          : null,
    );
  }

  final List<int> colorCodes = <int>[600, 500, 100];
}
