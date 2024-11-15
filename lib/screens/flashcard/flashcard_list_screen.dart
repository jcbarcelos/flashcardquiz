// flashcard_list_screen.dart
import 'dart:io' show Platform;

import 'package:flashcardquiz/core/database/sqlite/db_helper.dart';
import 'package:flashcardquiz/models/flashcard_model.dart';
import 'package:flashcardquiz/screens/flashcard/widget/gridview_widget.dart';
import 'package:flashcardquiz/screens/flashcard/widget/listview_widget.dart';
import 'package:flashcardquiz/screens/flashcard/widget/stackwidget.dart';
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
  bool isLoading = true;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Função para criar backup
  Future<void> _backupDatabase() async {
    try {
      String message = await _dbHelper.backupDatabase();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
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
    if (Platform.isAndroid || Platform.isIOS) {
      _isGridMode = false;
    }
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    isLoading = true;
    List<FlashCard> flashcards = await DatabaseHelper().getFlashcards();
    setState(() {
      _flashcards = flashcards;
      isLoading = false;
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
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _loadFlashcards();
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
              child: RefreshIndicator(
                onRefresh: _loadFlashcards,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _isGridMode
                        ? GridViewWidget(
                            flashcards: _flashcards,
                            loadFlashcards: _loadFlashcards,
                          )
                        : ListViewWidget(
                            flashcards: _flashcards,
                            loadFlashcards: _loadFlashcards,
                          ),
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
      floatingActionButton: Stackwidget(flashcard: _flashcards),
    );
  }

  final List<int> colorCodes = <int>[600, 500, 100];
}
