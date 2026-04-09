import 'package:flutter/material.dart';
import 'package:smaphore_quiz/core/audio/audio_service.dart';
import 'package:smaphore_quiz/persentaion/home/widget/ic_menu.dart';
import 'package:smaphore_quiz/persentaion/home/widget/iconButton.dart';
import 'package:smaphore_quiz/persentaion/shared/widget/setting.dart';
import 'package:smaphore_quiz/persentaion/shared/widget/setting/game_settings_dialog.dart';
import 'package:smaphore_quiz/persentaion/shared/widget/setting/settings_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String _bgImage = 'assets/images/bg_home.png';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SettingsController _settingsController = SettingsController();

  @override
  void initState() {
    super.initState();
    AudioService.instance.playBgm();
  }

  Future<void> _showSettings() async {
    await AudioService.instance.playClick();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameSettingsDialog(
        controller: _settingsController,
        onReplay: () => Navigator.pop(context),
        onMoreGames: () {},
        onMoreSettings: () {},
        onDefaultSkin: () {},
      ),
    );
  }

  Future<void> _onBackTap() async {
    await AudioService.instance.playClick();
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(HomePage._bgImage, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  CustomSettingAppBar(
                    onBackTap: () {
                      Navigator.pushReplacementNamed(context, '/onboarding');
                    },
                    onSettingTap: _showSettings,
                    centerTitle: true,
                    title: const Text(
                      'Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),
                  const MenuImage(title: 'Semaphore Quiz'),
                  const SizedBox(height: 64),

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
