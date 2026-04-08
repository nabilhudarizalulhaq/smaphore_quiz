import 'package:flutter/material.dart';
import 'package:smaphore_quiz/persentaion/home/widget/ic_menu.dart';
import 'package:smaphore_quiz/persentaion/home/widget/iconButton.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String _bgImage = 'assets/images/bg_home.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          Positioned.fill(child: Image.asset(_bgImage, fit: BoxFit.cover)),

          /// Dark Overlay (biar teks kebaca)
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          /// Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),

                  const MenuImage(title: 'Semaphore Quiz'),

                  const SizedBox(height: 80),

                  const MenuImageButton(
                    title: 'Sejarah Pramuka',
                    icon: Icons.menu_book,
                    routeName: '/learn',
                  ),

                  const SizedBox(height: 16),

                  const MenuImageButton(
                    title: 'Pengenalan Sandi',
                    icon: Icons.info_outline,
                    routeName: '/introductioncode',
                  ),

                  const SizedBox(height: 16),

                  const MenuImageButton(
                    title: 'Start Quiz',
                    icon: Icons.play_arrow,
                    routeName: '/level',
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
