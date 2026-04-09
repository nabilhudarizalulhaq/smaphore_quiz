import 'package:flutter/material.dart';
import 'package:semaphore_quiz/presentation/home/widget/ic_menu.dart';
import 'package:semaphore_quiz/presentation/introduction/data/semaphore_intro.dart';
import 'package:semaphore_quiz/presentation/introduction/model/semaphore_item.dart';
import 'package:semaphore_quiz/presentation/shared/widget/custom_back_app_bar.dart';

class IntroductionCodePage extends StatefulWidget {
  const IntroductionCodePage({super.key});

  @override
  State<IntroductionCodePage> createState() => _IntroductionCodePageState();
}

class _IntroductionCodePageState extends State<IntroductionCodePage> {
  static const String _bgImage = 'assets/images/bg_home.png';

  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<SemaphoreItem> items = SemaphoreIntroData.items;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(_bgImage, fit: BoxFit.cover)),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          SafeArea(
            child: Column(
              children: [
                const CustomBackAppBar(),
                const SizedBox(height: 20),
                const MenuImage(title: 'Pengenalan Semaphore'),
                const SizedBox(height: 20),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.93),
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          SemaphoreIntroData.pageTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          SemaphoreIntroData.pageSubtitle,
                          style: TextStyle(
                            fontSize: 14.5,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: items.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: _SemaphoreSliderCard(item: item),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            int index;

                            if (_currentIndex == 0) {
                              index = i; // 0,1,2
                            } else if (_currentIndex == items.length - 1) {
                              index = items.length - 3 + i; // last 3
                            } else {
                              index = _currentIndex - 1 + i; // tengah
                            }

                            final isActive = index == _currentIndex;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: isActive ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Color(0xFF5C3A21)
                                    : Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// Tombol Sebelumnya (Outline)
                            OutlinedButton.icon(
                              onPressed: _currentIndex > 0
                                  ? () {
                                      _pageController.previousPage(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  : null,
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                              ),
                              label: const Text('Sebelumnya'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF5C3A21),
                                side: const BorderSide(
                                  color: Color(0xFF5C3A21),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),

                            /// Tombol Berikutnya (Primary)
                            ElevatedButton.icon(
                              onPressed: _currentIndex < items.length - 1
                                  ? () {
                                      _pageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  : null,
                              icon: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                              ),
                              label: const Text('Berikutnya'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5C3A21),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                elevation: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SemaphoreSliderCard extends StatelessWidget {
  const _SemaphoreSliderCard({required this.item});

  final SemaphoreItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade100,
                child: Image.asset(item.imagePath, fit: BoxFit.contain),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        item.description,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.grey.shade800,
                        ),
                      ),
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
