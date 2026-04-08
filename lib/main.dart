import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:smaphore_quiz/persentaion/home/home.dart';
import 'package:smaphore_quiz/persentaion/level/menu/levelhome.dart';
import 'package:smaphore_quiz/persentaion/onboarding/onboardingPage.dart';
import 'package:smaphore_quiz/persentaion/smaphore/smaphore.dart';
import 'package:smaphore_quiz/persentaion/introduction/page/introductionCodePage.dart';
import 'package:smaphore_quiz/persentaion/learn/page/LearnsPramukaPage.dart';
import 'package:smaphore_quiz/persentaion/splash/splash.dart';

/// GLOBAL CAMERA LIST (WAJIB)
late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi kamera sebelum aplikasi berjalan
  cameras = await availableCameras();

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
      },
    );
  }
}
