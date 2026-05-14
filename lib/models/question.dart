class Question {
  final String text;
  final List<String> options;
  final int correctIndex;
  final String topic;

  Question.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        options = List<String>.from(json['options']),
        correctIndex = json['correctIndex'],
        topic = json['topic'] ?? '';
}