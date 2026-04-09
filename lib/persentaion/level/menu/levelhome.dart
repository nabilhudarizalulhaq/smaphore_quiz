import 'package:flutter/material.dart';
import 'package:smaphore_quiz/persentaion/level/widget/levelImage.dart';
import 'package:smaphore_quiz/persentaion/level/widget/levelimage1.dart';
import 'package:smaphore_quiz/persentaion/level/widget/levelimage2.dart';
import 'package:smaphore_quiz/persentaion/level/widget/levelimage3.dart';
import 'package:smaphore_quiz/persentaion/level/widget/levelimage4.dart';
import 'package:smaphore_quiz/persentaion/shared/widget/custom_back_app_bar.dart';

class Levelhome extends StatelessWidget {
  const Levelhome({super.key});

  static const String _bgImage = 'assets/images/bg_home.png';

  @override
  Widget build(BuildContext context) {
    final levelWidgets = [
      const LevelImage1(title: 'Tingkat I\nSiaga Mula'),
      const LevelImage2(title: 'Tingkat II\nSiaga Bantu'),
      const LevelImage3(title: 'Tingkat III\nSiaga Tata'),
      const LevelImage4(title: 'Tingkat IV\nPenggalang Ramu'),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(_bgImage, fit: BoxFit.cover)),

          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const CustomBackAppBar(),
                  const SizedBox(height: 80),
                  const LevelImage(title: 'Pilih Tingkatan'),
                  const SizedBox(height: 40),

                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 2;
                        double childAspectRatio = 1;

                        if (constraints.maxWidth > 900) {
                          crossAxisCount = 4;
                          childAspectRatio = 0.95;
                        } else if (constraints.maxWidth > 600) {
                          crossAxisCount = 3;
                          childAspectRatio = 0.9;
                        }

                        return GridView.builder(
                          itemCount: levelWidgets.length,
                          padding: const EdgeInsets.only(bottom: 20),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: childAspectRatio,
                              ),
                          itemBuilder: (context, index) {
                            return levelWidgets[index];
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
