import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:smaphore_quiz/persentaion/home/home.dart';
import 'package:smaphore_quiz/persentaion/onboarding/onboardingPage.dart';
import 'package:smaphore_quiz/persentaion/smaphore/smaphore.dart';
import 'package:smaphore_quiz/persentaion/smaphore/widget/introductionCodePage.dart';
import 'package:smaphore_quiz/persentaion/smaphore/widget/learnSmaphore.dart';
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
        '/quiz': (context) => const SmaphorePage(),
        '/learn': (context) => const LearnsmaphorePage(),
        '/introductioncode': (context) => const IntroductionCodePage(),
      },
    );
  }
}
