import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'package:semaphore_quiz/main.dart';
import 'package:semaphore_quiz/presentation/semaphore/utils/angle_smoother.dart';
import 'package:semaphore_quiz/presentation/shared/widget/setting/services/semaphore_tflite_service.dart';

import 'painters/pose_painter.dart';
import 'widget/angle_indicator.dart';

class SmaphorePage extends StatefulWidget {
  const SmaphorePage({
    super.key,
    this.level = 1,
  });

  final int level;

  @override
  State<SmaphorePage> createState() => _SmaphorePageState();
}

class _SmaphorePageState extends State<SmaphorePage>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  late final PoseDetector _poseDetector;

  CameraDescription? _currentCamera;
  Pose? _currentPose;

  bool _isBusy = false;
  bool _isInitializingCamera = false;
  bool _isFrontCamera = true;
  bool _isDisposed = false;

  String? _cameraError;
  String _detectedLetter = "";
  double _smoothRight = 0;
  double _smoothLeft = 0;

  final AngleSmoother _rightSmoother = AngleSmoother();
  final AngleSmoother _leftSmoother = AngleSmoother();

  late int _currentLevel;
  late List<String> _questions;

  int _questionIndex = 0;
  int _letterIndex = 0;
  int _timeLeft = 60;
  int _score = 0;

  Timer? _timer;
  bool _quizFinished = false;
  bool _isMovingNext = false;

  DateTime _lastCorrectAt = DateTime.fromMillisecondsSinceEpoch(0);

  String get _currentQuestion {
    if (_questions.isEmpty) return "";
    if (_questionIndex >= _questions.length) return "";
    return _questions[_questionIndex];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
    );

    _currentLevel = widget.level;
    _startLevel(_currentLevel);

    SemaphoreTfliteService.instance.loadModel();
    _initCamera();
  }

  List<String> _getQuestionsByLevel(int level) {
    switch (level) {
      case 1:
        return ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];

      case 2:
        return ['AB', 'CD', 'EF', 'GH', 'IJ', 'KL', 'MN', 'OP', 'QR', 'ST'];

      case 3:
        return [
          'SAND',
          'KODE',
          'SIAP',
          'RAJA',
          'BUDI',
          'DASA',
          'TALI',
          'KOTA',
          'RAPI',
          'JAGA',
        ];

      case 4:
        return [
          'SIAGA',
          'SANDI',
          'PRAMU',
          'RAMUK',
          'SCOUT',
          'TUNAS',
          'KOMPA',
          'JELAS',
          'PATUH',
          'DISIP',
        ];

      default:
        return ['A', 'B', 'C', 'D', 'E'];
    }
  }

  void _startLevel(int level) {
    _timer?.cancel();

    _questions = _getQuestionsByLevel(level)..shuffle();

    _questionIndex = 0;
    _letterIndex = 0;
    _score = 0;
    _timeLeft = 60;
    _quizFinished = false;
    _isMovingNext = false;

    _startTimer();

    if (mounted) setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 60;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted || _quizFinished) return;

        if (_timeLeft <= 1) {
          timer.cancel();
          _nextQuestion();
        } else {
          setState(() {
            _timeLeft--;
          });
        }
      },
    );
  }

  void _nextQuestion() {
    if (_isMovingNext || _quizFinished) return;

    _isMovingNext = true;
    _timer?.cancel();

    Future.delayed(
      const Duration(milliseconds: 700),
      () {
        if (!mounted) return;

        if (_questionIndex + 1 >= _questions.length) {
          _finishQuiz();
          return;
        }

        setState(() {
          _questionIndex++;
          _letterIndex = 0;
          _timeLeft = 60;
          _isMovingNext = false;
        });

        _startTimer();
      },
    );
  }

  void _finishQuiz() {
    _timer?.cancel();

    setState(() {
      _quizFinished = true;
      _isMovingNext = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Kuis Selesai'),
          content: Text(
            'Level: $_currentLevel\nSkor akhir: $_score',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startLevel(_currentLevel);
              },
              child: const Text('Ulangi'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  void _checkDetectedLetter(String detected) {
    if (detected.isEmpty) return;
    if (_quizFinished) return;
    if (_isMovingNext) return;
    if (_currentQuestion.isEmpty) return;
    if (_letterIndex >= _currentQuestion.length) return;

    final now = DateTime.now();

    if (now.difference(_lastCorrectAt).inMilliseconds < 700) {
      return;
    }

    final targetLetter = _currentQuestion[_letterIndex];

    if (detected.toUpperCase() == targetLetter.toUpperCase()) {
      _lastCorrectAt = now;

      setState(() {
        _letterIndex++;
        _score += 10;
      });

      if (_letterIndex >= _currentQuestion.length) {
        _nextQuestion();
      }
    }
  }

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[SmaphorePage] $message');
      if (error != null) debugPrint('Detail: $error');
      if (stackTrace != null) debugPrint('$stackTrace');
    }
  }

  ResolutionPreset _pickResolutionPreset() {
    return ResolutionPreset.high;
  }

  Future<void> _initCamera({CameraDescription? camera}) async {
    if (_isInitializingCamera || _isDisposed) return;
    _isInitializingCamera = true;

    try {
      if (!isCameraAvailable || cameras.isEmpty) {
        _cameraError = 'Kamera tidak tersedia di perangkat ini.';
        if (mounted) setState(() {});
        return;
      }

      final selectedCamera = camera ??
          cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          );

      _currentCamera = selectedCamera;
      _isFrontCamera =
          selectedCamera.lensDirection == CameraLensDirection.front;

      final oldController = _cameraController;
      _cameraController = null;

      await oldController?.stopImageStream().catchError((_) {});
      await oldController?.dispose();

      final controller = CameraController(
        selectedCamera,
        _pickResolutionPreset(),
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();

      if (_isDisposed) {
        await controller.dispose();
        return;
      }

      await controller.startImageStream(_processImage);

      _cameraController = controller;
      _cameraError = null;

      if (mounted) setState(() {});
    } catch (e, st) {
      _cameraError = 'Gagal menginisialisasi kamera.';
      _log('Init kamera gagal', error: e, stackTrace: st);
      if (mounted) setState(() {});
    } finally {
      _isInitializingCamera = false;
    }
  }

  Future<void> _switchCamera() async {
    if (_cameraController == null ||
        _currentCamera == null ||
        cameras.isEmpty ||
        _isInitializingCamera) {
      return;
    }

    try {
      final newCamera = cameras.firstWhere(
        (c) => c.lensDirection != _currentCamera!.lensDirection,
        orElse: () => _currentCamera!,
      );

      _currentPose = null;
      _detectedLetter = "";

      if (mounted) setState(() {});

      await _initCamera(camera: newCamera);
    } catch (e, st) {
      _log('Switch kamera gagal', error: e, stackTrace: st);
    }
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isBusy || _isDisposed) return;
    _isBusy = true;

    try {
      final inputImage = _convertToInputImage(image);
      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isEmpty) {
        _currentPose = null;
        _detectedLetter = "";
        return;
      }

      final pose = poses.first;
      _currentPose = pose;

      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final rightElbow = pose.landmarks[PoseLandmarkType.rightElbow];
      final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
      final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];

      final hasRightArm =
          rightShoulder != null && rightElbow != null && rightWrist != null;
      final hasLeftArm =
          leftShoulder != null && leftElbow != null && leftWrist != null;

      if (!hasRightArm || !hasLeftArm) {
        _detectedLetter = "";
        return;
      }

      final right = _calculateAngle(rightShoulder, rightElbow, rightWrist);
      final left = _calculateAngle(leftShoulder, leftElbow, leftWrist);

      if (right == null || left == null) {
        _detectedLetter = "";
        return;
      }

      _smoothRight = _rightSmoother.smooth(right);
      _smoothLeft = _leftSmoother.smooth(left);

      final tfliteLetter = SemaphoreTfliteService.instance.predict(
        pose,
        threshold: 0.60,
      );

      final ruleLetter = _detectSemaphoreByArmDirection(pose);

      _detectedLetter = tfliteLetter.isNotEmpty ? tfliteLetter : ruleLetter;

      _checkDetectedLetter(_detectedLetter);
    } catch (e, st) {
      _log('Proses frame gagal', error: e, stackTrace: st);
    } finally {
      _isBusy = false;
      if (mounted) setState(() {});
    }
  }

  InputImage _convertToInputImage(CameraImage image) {
    final buffer = WriteBuffer();

    for (final plane in image.planes) {
      buffer.putUint8List(plane.bytes);
    }

    return InputImage.fromBytes(
      bytes: buffer.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: _isFrontCamera
            ? InputImageRotation.rotation270deg
            : InputImageRotation.rotation90deg,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  double? _calculateAngle(
    PoseLandmark a,
    PoseLandmark b,
    PoseLandmark c,
  ) {
    final ab = Offset(a.x - b.x, a.y - b.y);
    final cb = Offset(c.x - b.x, c.y - b.y);

    final dot = ab.dx * cb.dx + ab.dy * cb.dy;
    final magAB = sqrt(ab.dx * ab.dx + ab.dy * ab.dy);
    final magCB = sqrt(cb.dx * cb.dx + cb.dy * cb.dy);
    final mag = magAB * magCB;

    if (mag == 0) return null;

    final ratio = (dot / mag).clamp(-1.0, 1.0);
    return acos(ratio) * 180 / pi;
  }

  String _detectSemaphoreByArmDirection(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = pose.landmarks[PoseLandmarkType.rightWrist];

    if (leftShoulder == null ||
        rightShoulder == null ||
        leftWrist == null ||
        rightWrist == null) {
      return "";
    }

    final leftPos = _armPosition(leftShoulder, leftWrist);
    final rightPos = _armPosition(rightShoulder, rightWrist);

    if (leftPos == 0 || rightPos == 0) return "";

    final positions = [leftPos, rightPos]..sort();
    final key = "${positions[0]}-${positions[1]}";

    const semaphoreMap = {
      "1-2": "A",
      "1-3": "B",
      "1-4": "C",
      "1-5": "D",
      "1-6": "E",
      "1-7": "F",
      "1-8": "G",
      "2-3": "H",
      "2-4": "I",
      "2-5": "K",
      "2-6": "L",
      "2-7": "M",
      "2-8": "N",
      "3-4": "O",
      "3-5": "P",
      "3-6": "Q",
      "3-7": "R",
      "3-8": "S",
      "4-5": "T",
      "4-6": "J",
      "4-7": "U",
      "4-8": "Z",
      "5-6": "V",
      "5-7": "W",
      "5-8": "X",
      "6-7": "Y",
    };

    return semaphoreMap[key] ?? "";
  }

  int _armPosition(PoseLandmark shoulder, PoseLandmark wrist) {
    final dx = wrist.x - shoulder.x;
    final dy = wrist.y - shoulder.y;

    final distance = sqrt(dx * dx + dy * dy);

    if (distance < 35) return 0;

    double degree = atan2(dy, dx) * 180 / pi;

    if (degree < 0) degree += 360;

    if (_nearDegree(degree, 135)) return 1;
    if (_nearDegree(degree, 180)) return 2;
    if (_nearDegree(degree, 225)) return 3;
    if (_nearDegree(degree, 270)) return 4;
    if (_nearDegree(degree, 315)) return 5;
    if (_nearDegree(degree, 0)) return 6;
    if (_nearDegree(degree, 45)) return 7;
    if (_nearDegree(degree, 90)) return 8;

    return 0;
  }

  bool _nearDegree(double value, double target) {
    const tolerance = 35.0;

    final diff = (value - target).abs();
    final circularDiff = min(diff, 360 - diff);

    return circularDiff <= tolerance;
  }

  Widget _buildQuestionText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _currentQuestion.length,
        (index) {
          final letter = _currentQuestion[index];
          final isCorrect = index < _letterIndex;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: isCorrect ? Colors.greenAccent : Colors.white,
                shadows: const [
                  Shadow(
                    blurRadius: 8,
                    color: Colors.black,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _timeLeft <= 10 ? Colors.red : Colors.white,
          width: 1.5,
        ),
      ),
      child: Text(
        'Waktu: $_timeLeft detik',
        style: TextStyle(
          color: _timeLeft <= 10 ? Colors.redAccent : Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuizOverlay() {
    return Positioned(
      top: 24,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Column(
          children: [
            _buildTimer(),
            const SizedBox(height: 12),
            _buildQuestionText(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Level $_currentLevel | Soal ${_questionIndex + 1}/${_questions.length} | Skor $_score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedLetter() {
    return Positioned(
      bottom: 95,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          _detectedLetter.isEmpty ? '-' : _detectedLetter,
          style: TextStyle(
            fontSize: 82,
            fontWeight: FontWeight.bold,
            color:
                _detectedLetter.isNotEmpty ? Colors.greenAccent : Colors.white,
            shadows: const [
              Shadow(
                blurRadius: 10,
                color: Colors.black,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _timer?.cancel();
      await controller.stopImageStream().catchError((_) {});
      await controller.dispose().catchError((_) {});
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      if (!_quizFinished) _startTimer();
      await _initCamera(camera: _currentCamera);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();

    WidgetsBinding.instance.removeObserver(this);

    final controller = _cameraController;
    _cameraController = null;

    controller?.stopImageStream().catchError((_) {});
    controller?.dispose().catchError((_) {});
    _poseDetector.close();

    SemaphoreTfliteService.instance.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraError != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Semaphore Detector'),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _cameraError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final previewSize = _cameraController!.value.previewSize!;
    final previewRatio = _cameraController!.value.aspectRatio;
    final screenSize = MediaQuery.of(context).size;
    final screenRatio = screenSize.width / screenSize.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Semaphore Detector'),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _switchCamera,
        child: const Icon(Icons.cameraswitch),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Transform.scale(
              scale: previewRatio / screenRatio,
              child: AspectRatio(
                aspectRatio: previewRatio,
                child: CameraPreview(_cameraController!),
              ),
            ),
          ),
          if (_currentPose != null)
            Positioned.fill(
              child: CustomPaint(
                painter: PosePainter(
                  pose: _currentPose!,
                  imageSize: Size(previewSize.height, previewSize.width),
                  isFrontCamera: _isFrontCamera,
                  rightAngle: _smoothRight,
                  leftAngle: _smoothLeft,
                ),
              ),
            ),
          _buildQuizOverlay(),
          _buildDetectedLetter(),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: AngleIndicator(
              rightAngle: _smoothRight,
              leftAngle: _smoothLeft,
            ),
          ),
        ],
      ),
    );
  }
}