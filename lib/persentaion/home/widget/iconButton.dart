import 'package:flutter/material.dart';

class MenuImageButton extends StatelessWidget {
  const MenuImageButton({
    super.key,
    required this.title,
    required this.routeName, required IconData icon,
  });

  final String title;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 78,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, routeName),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/icon_btn.png',
                fit: BoxFit.fill,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C3415),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}