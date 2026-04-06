import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'package:smaphore_quiz/main.dart';
import 'package:smaphore_quiz/persentaion/smaphore/utils/angle_smoother.dart';
import 'models/semaphore_model.dart';
import 'painters/pose_painter.dart';
import 'widget/angle_indicator.dart';

class SmaphorePage extends StatefulWidget {
  const SmaphorePage({super.key});

  @override
  State<SmaphorePage> createState() => _SmaphorePageState();
}

class _SmaphorePageState extends State<SmaphorePage> {
  late CameraController _cameraController;
  late PoseDetector _poseDetector;

  CameraDescription? _currentCamera;

  Pose? _currentPose;
  bool _isBusy = false;

  final AngleSmoother _rightSmoother = AngleSmoother();
  final AngleSmoother _leftSmoother = AngleSmoother();

  double _smoothRight = 0;
  double _smoothLeft = 0;

  String _detectedLetter = "";

  bool _isFrontCamera = true;

  @override
  void initState() {
    super.initState();

    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
    );

    _initCamera();
  }

  Future<void> _initCamera({CameraDescription? camera}) async {
    final selectedCamera =
        camera ??
        cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );

    _currentCamera = selectedCamera;
    _isFrontCamera = selectedCamera.lensDirection == CameraLensDirection.front;

    _cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController.initialize();
    await _cameraController.startImageStream(_processImage);

    if (mounted) setState(() {});
  }

  // =======================
  // SWITCH CAMERA
  // =======================
  Future<void> _switchCamera() async {
    if (_currentCamera == null) return;

    final newCamera = cameras.firstWhere(
      (c) => c.lensDirection != _currentCamera!.lensDirection,
      orElse: () => _currentCamera!,
    );

    await _cameraController.stopImageStream();
    await _cameraController.dispose();

    _currentPose = null;

    await _initCamera(camera: newCamera);
  }

  // =======================
  // PROCESS CAMERA FRAME
  // =======================
  void _processImage(CameraImage image) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      final inputImage = _convertToInputImage(image);
      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        _currentPose = poses.first;

        final right = _calculateAngle(
          _currentPose!.landmarks[PoseLandmarkType.rightShoulder]!,
          _currentPose!.landmarks[PoseLandmarkType.rightElbow]!,
          _currentPose!.landmarks[PoseLandmarkType.rightWrist]!,
        );

        final left = _calculateAngle(
          _currentPose!.landmarks[PoseLandmarkType.leftShoulder]!,
          _currentPose!.landmarks[PoseLandmarkType.leftElbow]!,
          _currentPose!.landmarks[PoseLandmarkType.leftWrist]!,
        );

        _smoothRight = _rightSmoother.smooth(right);
        _smoothLeft = _leftSmoother.smooth(left);

        _detectedLetter = _detectSemaphore(_smoothRight, _smoothLeft);
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }

    _isBusy = false;
    if (mounted) setState(() {});
  }

  // =======================
  // IMAGE → ML KIT (POTRET)
  // =======================
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

  // =======================
  // ANGLE CALCULATION
  // =======================
  double _calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final ab = Offset(a.x - b.x, a.y - b.y);
    final cb = Offset(c.x - b.x, c.y - b.y);

    final dot = ab.dx * cb.dx + ab.dy * cb.dy;
    final mag =
        sqrt(ab.dx * ab.dx + ab.dy * ab.dy) *
        sqrt(cb.dx * cb.dx + cb.dy * cb.dy);

    return acos(dot / mag) * 180 / pi;
  }

  // =======================
  // SEMAPHORE DETECTION
  // =======================
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
    _cameraController.dispose();
    _poseDetector.close();
    super.dispose();
  }

  // =======================
  // UI
  // =======================
  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final previewSize = _cameraController.value.previewSize!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Semaphore Detector'),
        backgroundColor: Colors.green.shade800,
      ),

      // BUTTON FLIP KAMERA
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade700,
        onPressed: _switchCamera,
        child: const Icon(Icons.cameraswitch),
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController),

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
