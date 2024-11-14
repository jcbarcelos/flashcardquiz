// flashcard_form_screen.dart
import 'package:flashcardquiz/core/database/sqlite/db_helper.dart';
import 'package:flashcardquiz/models/flashcard_model.dart';
import 'package:flutter/material.dart';

class FlashcardFormScreen extends StatefulWidget {
  final FlashCard? flashcard;

  const FlashcardFormScreen({super.key, this.flashcard});

  @override
  _FlashcardFormScreenState createState() => _FlashcardFormScreenState();
}

class _FlashcardFormScreenState extends State<FlashcardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionsControllers = [];
  int? _correctOptionIndex; // Para armazenar o índice da resposta correta
  List<String> options = [];
  int? id;

  @override
  void initState() {
    super.initState();
    if (widget.flashcard != null) {
      id = widget.flashcard?.id;
      _correctOptionIndex = widget.flashcard?.correctIndex;
      _questionController.text = widget.flashcard!.question;
      if (widget.flashcard!.options.isNotEmpty) {
        for (var option in widget.flashcard!.options) {
          _optionsControllers.add(TextEditingController(text: option));
        }
      } else {
        // Se não houver opções, adicionar campos vazios
        _optionsControllers.add(TextEditingController());
        _optionsControllers.add(TextEditingController());
      }
    } else {
      // Iniciar com 2 opções vazias para adicionar
      _optionsControllers.add(TextEditingController());
      _optionsControllers.add(TextEditingController());
      _optionsControllers.add(TextEditingController());
      _optionsControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _saveFlashcard() async {
    if (_formKey.currentState!.validate()) {
      List<String> options =
          _optionsControllers.map((controller) => controller.text).toList();

      if (_questionController.text.isNotEmpty && options.isNotEmpty) {
        FlashCard flashcard = FlashCard(
          id: widget.flashcard
              ?.id, // Usar o id existente se for edição, ou nulo se for criação
          question: _questionController.text,
          options: options,
          correctIndex: _correctOptionIndex!,
        );

        // Salvar ou atualizar o flashcard no banco de dados
        if (widget.flashcard == null) {
          // Novo flashcard
          await DatabaseHelper().insertFlashcard(flashcard);
        } else {
          // Editar flashcard existente
          await DatabaseHelper().updateFlashcard(flashcard);
        }

        // Voltar para a tela anterior após salvar
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.flashcard == null ? 'New Flashcard' : 'Edit Flashcard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _questionController,
                    decoration: const InputDecoration(labelText: 'Question'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a question';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Responstas',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  ..._buildOptionFields(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveFlashcard,
                    child: const Text('Save Flashcard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptionFields() {
    List<Widget> optionFields = [];

    for (int i = 0; i < _optionsControllers.length; i++) {
      optionFields.add(
        Wrap(
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          children: [
            TextField(
              controller: _optionsControllers[i],
              decoration: InputDecoration(
                labelText: 'Opção ${i + 1}',
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: ColoredBox(
                color: Colors.green,
                child: Material(
                  child: RadioListTile(
                    title: const Text('Correta'),
                    value: i,
                    groupValue: _correctOptionIndex,
                    onChanged: (value) {
                      setState(() {
                        _correctOptionIndex = value as int;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return optionFields;
  }
}
