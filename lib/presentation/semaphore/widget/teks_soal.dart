// import 'package:flutter/material.dart';

// Widget buildQuestionText() {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: List.generate(
//       currentQuestionText.length,
//       (index) {
//         final letter = currentQuestionText[index];
//         final isCorrect = index < currentLetterIndex;

//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 6),
//           child: Text(
//             letter,
//             style: TextStyle(
//               fontSize: 42,
//               fontWeight: FontWeight.bold,
//               color: isCorrect ? Colors.green : Colors.white,
//               shadows: const [
//                 Shadow(
//                   blurRadius: 6,
//                   color: Colors.black,
//                   offset: Offset(1, 1),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     ),
//   );
// }