import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:semaphore_quiz/core/audio/audio_service.dart';
import 'package:semaphore_quiz/presentation/home/home.dart';
import 'package:semaphore_quiz/presentation/introduction/page/introductionCodePage.dart';
import 'package:semaphore_quiz/presentation/learn/page/LearnsPramukaPage.dart';
import 'package:semaphore_quiz/presentation/level/menu/levelhome.dart';
import 'package:semaphore_quiz/presentation/onboarding/onboardingPage.dart';
import 'package:semaphore_quiz/presentation/score/page/scorepage.dart';
import 'package:semaphore_quiz/presentation/semaphore/semaphore.dart';
import 'package:semaphore_quiz/presentation/splash/splash.dart';

late List<CameraDescription> cameras;

bool isCameraAvailable = false;
bool isAudioAvailable = false;

void logError(String message, {Object? error, StackTrace? stackTrace}) {
  if (kDebugMode) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('Detail: $error');
    if (stackTrace != null) debugPrint('$stackTrace');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AudioService.instance.init();
    await AudioService.instance.preloadBgm();
    isAudioAvailable = true;
  } catch (e, st) {
    isAudioAvailable = false;
    logError('Gagal inisialisasi audio', error: e, stackTrace: st);
  }

  try {
    cameras = await availableCameras();
    isCameraAvailable = cameras.isNotEmpty;
  } catch (e, st) {
    cameras = <CameraDescription>[];
    isCameraAvailable = false;
    logError('Gagal mengambil daftar kamera', error: e, stackTrace: st);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smaphore Quiz',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/onboarding': (context) => const OnboardingPage(),
        '/home': (context) => const HomePage(),
        '/level': (context) => const Levelhome(),
        '/smaphore': (context) => const SmaphorePage(),
        '/learn': (context) => const LearnPramukaPage(),
        '/introductioncode': (context) => const IntroductionCodePage(),
        '/score': (context) => const ScorePage(),
      },
    );
  }
}
