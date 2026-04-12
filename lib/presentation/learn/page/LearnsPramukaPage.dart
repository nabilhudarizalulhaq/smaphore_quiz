import 'package:flutter/material.dart';
import 'package:semaphore_quiz/presentation/home/widget/ic_menu.dart';
import 'package:semaphore_quiz/presentation/learn/data/sejarah_pramuka.dart';
import 'package:semaphore_quiz/presentation/learn/model/article_section.dart';
import 'package:semaphore_quiz/presentation/shared/widget/custom_back_app_bar.dart';

class LearnPramukaPage extends StatelessWidget {
  const LearnPramukaPage({super.key});

  static const String _bgImage = 'assets/images/bg_home.png';

  @override
  Widget build(BuildContext context) {
    final List<ArticleSection> sections = SejarahPramukaData.sections;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(_bgImage, fit: BoxFit.cover)),
          Positioned.fill(
            // ignore: deprecated_member_use
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          SafeArea(
            child: Column(
              children: [
                const CustomBackAppBar(), // AppBar dengan tombol back
                const SizedBox(height: 20),
                const MenuImage(title: 'Sejarah Pramuka'),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE9BF).withOpacity(0.80),
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      itemCount: sections.length + 1,
                      separatorBuilder: (_, __) => const _SectionDivider(),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const _ArticleHeader();
                        }

                        final ArticleSection section = sections[index - 1];
                        return _ArticleCard(
                          title: section.title,
                          content: section.content,
                        );
                      },
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

class _ArticleHeader extends StatelessWidget {
  const _ArticleHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Artikel Edukasi',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF643B15),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          SejarahPramukaData.articleTitle,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          SejarahPramukaData.articleSubtitle,
          style: TextStyle(
            fontSize: 14.5,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 207, 187, 150),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color(0xFFC36A2B), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(child: Divider(color: Color(0xFFC36A2B), thickness: 1.0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 18,
              color: Color(0xFF643B15),
            ),
          ),
          Expanded(child: Divider(color: Color(0xFFC36A2B), thickness: 1.0)),
        ],
      ),
    );
  }
}
