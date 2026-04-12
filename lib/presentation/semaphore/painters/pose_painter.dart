import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final Pose pose;
  final Size imageSize;
  final bool isFrontCamera;
  final double rightAngle;
  final double leftAngle;

  PosePainter({
    required this.pose,
    required this.imageSize,
    required this.isFrontCamera,
    required this.rightAngle,
    required this.leftAngle,
  });

  final Paint jointPaint = Paint()
    ..color = Colors.green
    ..strokeWidth = 4
    ..style = PaintingStyle.fill;

  final Paint linePaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final fittedSizes = applyBoxFit(BoxFit.cover, imageSize, size);
    final sourceSize = fittedSizes.source;
    final destinationSize = fittedSizes.destination;

    final dx = (size.width - destinationSize.width) / 2;
    final dy = (size.height - destinationSize.height) / 2;

    final scaleX = destinationSize.width / sourceSize.width;
    final scaleY = destinationSize.height / sourceSize.height;

    Offset transform(double x, double y) {
      double mappedX = x * scaleX + dx;
      double mappedY = y * scaleY + dy;

      if (isFrontCamera) {
        mappedX = dx + destinationSize.width - (x * scaleX);
      }

      return Offset(mappedX, mappedY);
    }

    void drawLine(PoseLandmarkType a, PoseLandmarkType b) {
      final p1 = pose.landmarks[a];
      final p2 = pose.landmarks[b];
      if (p1 == null || p2 == null) return;

      canvas.drawLine(
        transform(p1.x, p1.y),
        transform(p2.x, p2.y),
        linePaint,
      );
    }

    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);

    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    drawLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    drawLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);

    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    drawLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    drawLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    drawLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);

    drawLine(PoseLandmarkType.nose, PoseLandmarkType.leftEye);
    drawLine(PoseLandmarkType.nose, PoseLandmarkType.rightEye);
    drawLine(PoseLandmarkType.leftEye, PoseLandmarkType.leftEar);
    drawLine(PoseLandmarkType.rightEye, PoseLandmarkType.rightEar);

    for (final lm in pose.landmarks.values) {
      canvas.drawCircle(transform(lm.x, lm.y), 4, jointPaint);
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text:
            'R: ${rightAngle.toStringAsFixed(1)}° | L: ${leftAngle.toStringAsFixed(1)}°',
        style: const TextStyle(
          color: Colors.green,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, const Offset(20, 20));
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.isFrontCamera != isFrontCamera ||
        oldDelegate.rightAngle != rightAngle ||
        oldDelegate.leftAngle != leftAngle;
  }
}