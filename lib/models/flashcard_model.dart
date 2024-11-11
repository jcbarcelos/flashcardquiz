import 'dart:convert';

class FlashCard {
  final int? id;
  final String question;
  final int correctIndex; // Índice da resposta correta
  final List<String> options; // Adicionando as opções de resposta

  FlashCard({
    this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'correctIndex': correctIndex,
      'options': jsonEncode(options), // Armazenando as opções como uma string
    };
  }

  static FlashCard fromMap(Map<String, dynamic> map) {
    return FlashCard(
      id: map['id'],
      question: map['question'],
      correctIndex: map['correctIndex'],
      options: List<String>.from(jsonDecode(map['options'])),
    );
  }
}
