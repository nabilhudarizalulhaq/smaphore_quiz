import 'package:flutter/material.dart';
import 'package:semaphore_quiz/core/audio/audio_service.dart';
import 'settings_controller.dart';

class GameSettingsDialog extends StatefulWidget {
  const GameSettingsDialog({
    super.key,
    required this.controller,
    this.onHome,
    this.onReplay,
    this.onMoreGames,
    this.onMoreSettings,
    this.onDefaultSkin,
  });

  final SettingsController controller;
  final VoidCallback? onHome;
  final VoidCallback? onReplay;
  final VoidCallback? onMoreGames;
  final VoidCallback? onMoreSettings;
  final VoidCallback? onDefaultSkin;

  @override
  State<GameSettingsDialog> createState() => _GameSettingsDialogState();
}

class _GameSettingsDialogState extends State<GameSettingsDialog> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _playClick() async {
    await AudioService.instance.playClick();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
        decoration: BoxDecoration(
          color: const Color(0xFFA9A9A9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF8F8F8F),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _buildTopToggles(),
                  const SizedBox(height: 18),
                  const Divider(color: Colors.black26, thickness: 2),
                  const SizedBox(height: 18),
                  _buildActionButton(
                    icon: Icons.sports_esports_rounded,
                    label: 'More Games',
                    color: const Color(0xFF39D80A),
                    onTap: widget.onMoreGames,
                    showBadge: true,
                  ),
                  const SizedBox(height: 14),
                  _buildActionButton(
                    icon: Icons.settings_rounded,
                    label: 'More Settings',
                    color: const Color(0xFF39D80A),
                    onTap: widget.onMoreSettings,
                    showBadge: true,
                  ),
                  const SizedBox(height: 14),
                  _buildActionButton(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    color: const Color(0xFF39D80A),
                    onTap: widget.onHome,
                  ),
                  const SizedBox(height: 14),
                  _buildActionButton(
                    icon: Icons.refresh_rounded,
                    label: 'Replay',
                    color: const Color(0xFF39D80A),
                    onTap: widget.onReplay,
                  ),
                  const SizedBox(height: 14),
                  _buildActionButton(
                    icon: Icons.checkroom_rounded,
                    label: 'Default Skin',
                    color: const Color(0xFF21C6F3),
                    onTap: widget.onDefaultSkin,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        const Expanded(
          flex: 8,
          child: Text(
            'Settings',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () async {
              await _playClick();
              if (mounted) Navigator.pop(context);
            },
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopToggles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildToggleItem(
          icon: Icons.volume_up_rounded,
          label: 'Sound',
          enabled: widget.controller.soundOn,
          onTap: () async {
            await _playClick();
            await widget.controller.toggleSound();
          },
        ),
        _buildToggleItem(
          icon: Icons.music_note_rounded,
          label: 'BGM',
          enabled: widget.controller.bgmOn,
          onTap: () async {
            await _playClick();
            await widget.controller.toggleBgm();
          },
        ),
        _buildToggleItem(
          icon: Icons.vibration_rounded,
          label: 'Vibration',
          enabled: widget.controller.vibrationOn,
          onTap: () async {
            await _playClick();
            widget.controller.toggleVibration();
          },
        ),
      ],
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 82,
        child: Column(
          children: [
            SizedBox(
              width: 58,
              height: 58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 42),
                  if (!enabled)
                    Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      transform: Matrix4.rotationZ(-0.8),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    bool showBadge = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () async {
            await _playClick();
            onTap?.call();
          },
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 6,
                ),
              ],
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Row(
              children: [
                const SizedBox(width: 18),
                Icon(icon, size: 34, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showBadge)
          const Positioned(
            right: 8,
            top: -6,
            child: CircleAvatar(radius: 9, backgroundColor: Colors.red),
          ),
      ],
    );
  }
}
