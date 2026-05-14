import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/quiz_viewmodel.dart';

class QuestionWidget extends StatelessWidget {
  const QuestionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<QuizViewModel>(context);

    return Column(
      children: vm.currentQuestion.options.asMap().entries.map((entry) {
        int idx = entry.key;
        String option = entry.value;

        return RadioListTile<int>(
          title: Text(option),
          value: idx,
          groupValue: vm.selectedAnswer,
          onChanged: (value) => vm.selectAnswer(value!),
        );
      }).toList(),
    );
  }
}