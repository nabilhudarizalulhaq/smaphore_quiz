import 'package:flutter/material.dart';

class AngleIndicator extends StatelessWidget {
  final double rightAngle;
  final double leftAngle;

  const AngleIndicator({
    super.key,
    required this.rightAngle,
    required this.leftAngle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _angleBox('Right Arm', rightAngle),
          _angleBox('Left Arm', leftAngle),
        ],
      ),
    );
  }

  Widget _angleBox(String label, double angle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${angle.toStringAsFixed(1)}°',
          style: const TextStyle(
            color: Colors.green,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
