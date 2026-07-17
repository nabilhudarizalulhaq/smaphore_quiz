import 'package:flutter/material.dart';
import 'package:semaphore_quiz/presentation/score/model/score_history.dart';
import 'package:semaphore_quiz/presentation/score/service/score_history_service.dart';
import 'package:semaphore_quiz/presentation/shared/widget/custom_back_app_bar.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  static const String _bgScoreImage = 'assets/images/bg_score.png';

  late Future<List<ScoreHistory>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = ScoreHistoryService.instance.getHistory();
  }

  Future<void> _refreshHistory() async {
    setState(_loadHistory);
    await _historyFuture;
  }

  Future<void> _confirmClearHistory() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text(
          'Semua riwayat skor akan dihapus secara permanen dari perangkat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldClear != true) return;
    await ScoreHistoryService.instance.clearHistory();
    if (!mounted) return;
    setState(_loadHistory);
  }

  String _formatDate(DateTime date) {
    const months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}, $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(_bgScoreImage, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomBackAppBar(
                    centerTitle: true,
                    title: const Text(
                      'History Score',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<ScoreHistory>>(
                    future: _historyFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (snapshot.hasError) {
                        return _MessageState(
                          icon: Icons.error_outline,
                          title: 'Riwayat gagal dimuat',
                          subtitle: 'Silakan buka kembali halaman ini.',
                          actionLabel: 'Coba Lagi',
                          onAction: _refreshHistory,
                        );
                      }

                      final history = snapshot.data ?? <ScoreHistory>[];
                      if (history.isEmpty) {
                        return const _MessageState(
                          icon: Icons.history_rounded,
                          title: 'Belum Ada Riwayat',
                          subtitle: 'Selesaikan kuis untuk menyimpan skor pertama.',
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: _refreshHistory,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                          itemCount: history.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _SummaryCard(
                                history: history,
                                onClear: _confirmClearHistory,
                              );
                            }
                            return _ScoreHistoryCard(
                              item: history[index - 1],
                              formattedDate: _formatDate(
                                history[index - 1].completedAt,
                              ),
                            );
                          },
                        ),
                      );
                    },
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.history, required this.onClear});

  final List<ScoreHistory> history;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final best = history.reduce((a, b) => a.percentage >= b.percentage ? a : b);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            child: Icon(Icons.emoji_events_rounded, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${history.length} kali bermain',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Skor terbaik ${best.score}/${best.maximumScore} '
                  '(${best.percentage.toStringAsFixed(0)}%)',
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Hapus semua riwayat',
            onPressed: onClear,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _ScoreHistoryCard extends StatelessWidget {
  const _ScoreHistoryCard({
    required this.item,
    required this.formattedDate,
  });

  final ScoreHistory item;
  final String formattedDate;

  @override
  Widget build(BuildContext context) {
    final percentage = item.percentage;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'L${item.level}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${item.level}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.score}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              Text(
                '/ ${item.maximumScore}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 3),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 72),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
