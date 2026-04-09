import 'package:flutter/material.dart';

class LevelImage1 extends StatelessWidget {
  const LevelImage1({
    super.key,
    required this.title,
    required this.onTap,
    this.backgroundImage = 'assets/images/level/bg_lv.png',
    this.iconImage = 'assets/images/level/ic_l1.png',
  });

  final String title;
  final VoidCallback? onTap;
  final String backgroundImage;
  final String iconImage;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      backgroundImage,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFD7B690),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF8B5E3C),
                              width: 1.2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        iconImage,
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.emoji_events_rounded,
                            size: 28,
                            color: Color(0xFF5C3415),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C3415),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
