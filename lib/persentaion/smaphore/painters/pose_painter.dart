import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PosePainter extends CustomPainter {
  final Pose pose;
  final Size imageSize; // ukuran asli frame (width, height) dari CameraImage
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
    // Skala langsung sesuai ruang koordinat image (TANPA swap x/y)
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    Offset transform(double x, double y) {
      double dx = x * scaleX;
      double dy = y * scaleY;

      // Mirror horizontal untuk kamera depan (selfie)
      if (isFrontCamera) {
        dx = size.width - dx;
      }
      return Offset(dx, dy);
    }

    void drawLine(PoseLandmarkType a, PoseLandmarkType b) {
      final p1 = pose.landmarks[a];
      final p2 = pose.landmarks[b];
      if (p1 == null || p2 == null) return;

      canvas.drawLine(transform(p1.x, p1.y), transform(p2.x, p2.y), linePaint);
    }

    // ===== BODY =====
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);

    // ===== ARMS =====
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    drawLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    drawLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);

    // ===== LEGS =====
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    drawLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    drawLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    drawLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);

    // ===== HEAD =====
    drawLine(PoseLandmarkType.nose, PoseLandmarkType.leftEye);
    drawLine(PoseLandmarkType.nose, PoseLandmarkType.rightEye);
    drawLine(PoseLandmarkType.leftEye, PoseLandmarkType.leftEar);
    drawLine(PoseLandmarkType.rightEye, PoseLandmarkType.rightEar);

    // ===== JOINT POINTS =====
    for (final lm in pose.landmarks.values) {
      canvas.drawCircle(transform(lm.x, lm.y), 4, jointPaint);
    }

    // ===== ANGLE INFO =====
    final textPainter = TextPainter(
      text: TextSpan(
        text:
            'R: ${rightAngle.toStringAsFixed(1)}° | L: ${leftAngle.toStringAsFixed(1)}°',
        style: const TextStyle(color: Colors.green, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, const Offset(20, 20));
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    // repaint jika pose / ukuran / kamera / sudut berubah
    return oldDelegate.pose != pose ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.isFrontCamera != isFrontCamera ||
        oldDelegate.rightAngle != rightAngle ||
        oldDelegate.leftAngle != leftAngle;
  }
}
