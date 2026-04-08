import 'package:flutter/material.dart';
import 'package:smaphore_quiz/persentaion/level/widget/levelImage.dart';
import 'package:smaphore_quiz/persentaion/level/widget/levelimage1.dart';
import 'package:smaphore_quiz/persentaion/shared/widget/custom_back_app_bar.dart';

class Levelhome extends StatelessWidget {
  const Levelhome({super.key});

  static const String _bgImage = 'assets/images/bg_home.png';

  @override
  Widget build(BuildContext context) {
    final levels = ['Tingkat 1', 'Tingkat 2', 'Tingkat 3', 'Tingkat 4'];

    return Scaffold(
      body: Stack(
        children: [
          /// Background
          Positioned.fill(child: Image.asset(_bgImage, fit: BoxFit.cover)),

          /// Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          /// Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const CustomBackAppBar(),
                  const SizedBox(height: 80),

                  /// Title
                  const LevelImage(title: 'Pilih Tingkatan'),

                  const SizedBox(height: 88),

                  /// GRID (MAIN PART)
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        /// Responsive column count
                        int crossAxisCount = 2;
                        if (constraints.maxWidth > 600) {
                          crossAxisCount = 3; // tablet
                        }

                        return GridView.builder(
                          itemCount: levels.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1, // kotak
                              ),
                          itemBuilder: (context, index) {
                            return LevelImage1(title: levels[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
