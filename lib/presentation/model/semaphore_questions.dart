import 'package:semaphore_quiz/presentation/model/semaphore_question.dart';

class SemaphoreQuestions {
  static List<SemaphoreQuestion> byLevel(int level) {
    switch (level) {
      case 1:
        return const [
          SemaphoreQuestion(text: 'A', level: 1),
          SemaphoreQuestion(text: 'B', level: 1),
          SemaphoreQuestion(text: 'C', level: 1),
          SemaphoreQuestion(text: 'D', level: 1),
          SemaphoreQuestion(text: 'E', level: 1),
        ];

      case 2:
        return const [
          SemaphoreQuestion(text: 'AB', level: 2),
          SemaphoreQuestion(text: 'CD', level: 2),
          SemaphoreQuestion(text: 'EF', level: 2),
          SemaphoreQuestion(text: 'GH', level: 2),
          SemaphoreQuestion(text: 'IJ', level: 2),
        ];

      case 3:
        return const [
          SemaphoreQuestion(text: 'SAND', level: 3),
          SemaphoreQuestion(text: 'PRAM', level: 3),
          SemaphoreQuestion(text: 'KODE', level: 3),
          SemaphoreQuestion(text: 'SIAP', level: 3),
          SemaphoreQuestion(text: 'RAJA', level: 3),
        ];

      case 4:
        return const [
          SemaphoreQuestion(text: 'RAMU', level: 4),
          SemaphoreQuestion(text: 'SIAGA', level: 4),
          SemaphoreQuestion(text: 'SANDI', level: 4),
          SemaphoreQuestion(text: 'PRAMU', level: 4),
          SemaphoreQuestion(text: 'SCOUT', level: 4),
        ];

      default:
        return const [SemaphoreQuestion(text: 'A', level: 1)];
    }
  }
}
