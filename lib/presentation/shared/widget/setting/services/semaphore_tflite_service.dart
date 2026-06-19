import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class SemaphoreTfliteService {
  SemaphoreTfliteService._();

  static final SemaphoreTfliteService instance = SemaphoreTfliteService._();

  Interpreter? _interpreter;
  List<String> _labels = [];
  List<String> _featureCols = [];

  bool get isReady => _interpreter != null;

  Future<void> loadModel() async {
    // _interpreter ??= await Interpreter.fromAsset(
    //   'model/model_semaphore.tflite',
    // );
    try {
      _interpreter ??= await Interpreter.fromAsset(
        'model/model_semaphore.tflite',
      );

      print('MODEL TFLITE BERHASIL DIMUAT');
    } catch (e) {
      print('GAGAL LOAD MODEL TFLITE: $e');
    }

    final labelText = await rootBundle.loadString('assets/model/labels.txt');

    _labels = labelText
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final featureText = await rootBundle.loadString(
      'assets/model/feature_cols.json',
    );

    _featureCols = List<String>.from(jsonDecode(featureText));
  }

  String predict(Pose pose, {double threshold = 0.70}) {
    if (_interpreter == null || _labels.isEmpty || _featureCols.isEmpty) {
      return '';
    }

    final input = _extractFeatures(pose);

    if (input.length != _featureCols.length) {
      return '';
    }

    final output = List.generate(
      1,
      (_) => List<double>.filled(_labels.length, 0),
    );

    _interpreter!.run([input], output);

    final probabilities = output.first;

    double bestScore = probabilities.first;
    int bestIndex = 0;

    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > bestScore) {
        bestScore = probabilities[i];
        bestIndex = i;
      }
    }

    if (bestScore < threshold) {
      return '';
    }

    return _labels[bestIndex];
  }

  List<double> _extractFeatures(Pose pose) {
    final values = <double>[];

    for (final col in _featureCols) {
      values.add(_getLandmarkValue(pose, col));
    }

    return values;
  }

  double _getLandmarkValue(Pose pose, String col) {
    final parts = col.split('_');

    if (parts.length < 2) {
      return 0.0;
    }

    final axis = parts.last;
    final landmarkName = parts.sublist(0, parts.length - 1).join('_');

    final type = _mapLandmarkType(landmarkName);
    final landmark = pose.landmarks[type];

    if (landmark == null) {
      return 0.0;
    }

    if (axis == 'x') return landmark.x;
    if (axis == 'y') return landmark.y;
    if (axis == 'z') return landmark.z;
    if (axis == 'likelihood') return landmark.likelihood;

    return 0.0;
  }

  PoseLandmarkType _mapLandmarkType(String name) {
    switch (name) {
      case 'nose':
        return PoseLandmarkType.nose;
      case 'left_eye_inner':
        return PoseLandmarkType.leftEyeInner;
      case 'left_eye':
        return PoseLandmarkType.leftEye;
      case 'left_eye_outer':
        return PoseLandmarkType.leftEyeOuter;
      case 'right_eye_inner':
        return PoseLandmarkType.rightEyeInner;
      case 'right_eye':
        return PoseLandmarkType.rightEye;
      case 'right_eye_outer':
        return PoseLandmarkType.rightEyeOuter;
      case 'left_ear':
        return PoseLandmarkType.leftEar;
      case 'right_ear':
        return PoseLandmarkType.rightEar;
      case 'left_mouth':
        return PoseLandmarkType.leftMouth;
      case 'right_mouth':
        return PoseLandmarkType.rightMouth;
      case 'left_shoulder':
        return PoseLandmarkType.leftShoulder;
      case 'right_shoulder':
        return PoseLandmarkType.rightShoulder;
      case 'left_elbow':
        return PoseLandmarkType.leftElbow;
      case 'right_elbow':
        return PoseLandmarkType.rightElbow;
      case 'left_wrist':
        return PoseLandmarkType.leftWrist;
      case 'right_wrist':
        return PoseLandmarkType.rightWrist;
      case 'left_pinky':
        return PoseLandmarkType.leftPinky;
      case 'right_pinky':
        return PoseLandmarkType.rightPinky;
      case 'left_index':
        return PoseLandmarkType.leftIndex;
      case 'right_index':
        return PoseLandmarkType.rightIndex;
      case 'left_thumb':
        return PoseLandmarkType.leftThumb;
      case 'right_thumb':
        return PoseLandmarkType.rightThumb;
      case 'left_hip':
        return PoseLandmarkType.leftHip;
      case 'right_hip':
        return PoseLandmarkType.rightHip;
      case 'left_knee':
        return PoseLandmarkType.leftKnee;
      case 'right_knee':
        return PoseLandmarkType.rightKnee;
      case 'left_ankle':
        return PoseLandmarkType.leftAnkle;
      case 'right_ankle':
        return PoseLandmarkType.rightAnkle;
      case 'left_heel':
        return PoseLandmarkType.leftHeel;
      case 'right_heel':
        return PoseLandmarkType.rightHeel;
      case 'left_foot_index':
        return PoseLandmarkType.leftFootIndex;
      case 'right_foot_index':
        return PoseLandmarkType.rightFootIndex;
      default:
        return PoseLandmarkType.nose;
    }
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
