import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:semaphore_quiz/main.dart';
import 'package:semaphore_quiz/presentation/semaphore/utils/angle_smoother.dart';
import 'models/semaphore_model.dart';
import 'painters/pose_painter.dart';
import 'widget/angle_indicator.dart';

class SmaphorePage extends StatefulWidget {
  const SmaphorePage({super.key});

  @override
  State<SmaphorePage> createState() => _SmaphorePageState();
}

class _SmaphorePageState extends State<SmaphorePage> {
  CameraController? _cameraController;
  late final PoseDetector _poseDetector;

  CameraDescription? _currentCamera;
  Pose? _currentPose;

  bool _isBusy = false;
  bool _isInitializingCamera = false;
  bool _isFrontCamera = true;

  String? _cameraError;
  String _detectedLetter = "";
  double _smoothRight = 0;
  double _smoothLeft = 0;

  final AngleSmoother _rightSmoother = AngleSmoother();
  final AngleSmoother _leftSmoother = AngleSmoother();

  @override
  void initState() {
    super.initState();
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
    );
    _initCamera();
  }

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[SmaphorePage] $message');
      if (error != null) debugPrint('Detail: $error');
      if (stackTrace != null) debugPrint('$stackTrace');
    }
  }

  Future<void> _initCamera({CameraDescription? camera}) async {
    if (_isInitializingCamera) return;
    _isInitializingCamera = true;

    try {
      if (!isCameraAvailable || cameras.isEmpty) {
        _cameraError = 'Kamera tidak tersedia di perangkat ini.';
        if (mounted) setState(() {});
        return;
      }

      final selectedCamera =
          camera ??
          cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          );

      _currentCamera = selectedCamera;
      _isFrontCamera =
          selectedCamera.lensDirection == CameraLensDirection.front;

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();
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
        cameras.isEmpty) {
      return;
    }

    try {
      final newCamera = cameras.firstWhere(
        (c) => c.lensDirection != _currentCamera!.lensDirection,
        orElse: () => _currentCamera!,
      );

      await _cameraController?.stopImageStream();
      await _cameraController?.dispose();
      _cameraController = null;
      _currentPose = null;

      await _initCamera(camera: newCamera);
    } catch (e, st) {
      _log('Switch kamera gagal', error: e, stackTrace: st);
    }
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isBusy) return;
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
        _log('Frame dilewati: landmark lengan tidak lengkap');
        return;
      }

      final right = _calculateAngle(rightShoulder!, rightElbow!, rightWrist!);

      final left = _calculateAngle(leftShoulder!, leftElbow!, leftWrist!);

      if (right == null || left == null) {
        _detectedLetter = "";
        _log('Frame dilewati: sudut tidak valid');
        return;
      }

      _smoothRight = _rightSmoother.smooth(right);
      _smoothLeft = _leftSmoother.smooth(left);
      _detectedLetter = _detectSemaphore(_smoothRight, _smoothLeft);
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

  double? _calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
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

  String _detectSemaphore(double right, double left) {
    const tolerance = 15.0;

    bool match(double a, double b) => a >= b - tolerance && a <= b + tolerance;

    for (final s in semaphoreList) {
      if (match(right, s.right) && match(left, s.left)) {
        return s.letter;
      }
    }

    return "";
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraError != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Semaphore Detector'),
          backgroundColor: Colors.green.shade800,
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Semaphore Detector'),
        backgroundColor: Colors.green.shade800,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade700,
        onPressed: _switchCamera,
        child: const Icon(Icons.cameraswitch),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),
          if (_currentPose != null)
            CustomPaint(
              painter: PosePainter(
                pose: _currentPose!,
                imageSize: Size(previewSize.height, previewSize.width),
                isFrontCamera: _isFrontCamera,
                rightAngle: _smoothRight,
                leftAngle: _smoothLeft,
              ),
            ),
          Center(
            child: Text(
              _detectedLetter,
              style: TextStyle(
                fontSize: 140,
                fontWeight: FontWeight.bold,
                color: _detectedLetter.isNotEmpty ? Colors.green : Colors.white,
              ),
            ),
          ),
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
