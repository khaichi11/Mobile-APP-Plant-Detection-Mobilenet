import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'classifier_math.dart';

class IdentificationResult {
  const IdentificationResult(this.predictions);

  /// Best guesses, highest confidence first. Never empty.
  final List<Prediction> predictions;

  Prediction get best => predictions.first;

  static const backgroundLabel = 'background';

  /// True when the model sees no plant at all.
  bool get isBackground => best.label == backgroundLabel;

  /// Alternatives that are real plants.
  List<Prediction> get alternatives =>
      predictions
          .skip(1)
          .where((p) => p.label != backgroundLabel && p.confidence >= 0.02)
          .toList();
}

abstract interface class PlantIdentifier {
  Future<IdentificationResult> identify(String imagePath);
  Future<void> dispose();
}

class IdentificationException implements Exception {
  const IdentificationException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Runs the on-device TensorFlow Lite plant model in a background isolate.
///
/// Supports quantized (uint8) and float32 models with NHWC input. Float
/// models receive values between 0 and 1.
class TfliteIdentifier implements PlantIdentifier {
  TfliteIdentifier._(
    this._interpreter,
    this._isolate,
    this._labels,
    this._inputSize,
    this._inputIsQuantized,
    this._outputType,
    this._outputScale,
    this._outputZeroPoint,
  );

  static const modelAsset = 'assets/models/plant_classifier.tflite';
  static const labelsAsset = 'assets/models/plant_labels.csv';

  final Interpreter _interpreter;
  final IsolateInterpreter _isolate;
  final List<String> _labels;
  final int _inputSize;
  final bool _inputIsQuantized;
  final TensorType _outputType;
  final double _outputScale;
  final int _outputZeroPoint;

  static Future<TfliteIdentifier> load() async {
    final labels = parseLabelMap(await rootBundle.loadString(labelsAsset));
    final interpreter = await Interpreter.fromAsset(
      modelAsset,
      options: InterpreterOptions()..threads = 4,
    );
    final input = interpreter.getInputTensor(0);
    final output = interpreter.getOutputTensor(0);
    if (output.shape.last != labels.length) {
      interpreter.close();
      throw IdentificationException(
        'The model has ${output.shape.last} classes but there are '
        '${labels.length} labels.',
      );
    }
    final isolate = await IsolateInterpreter.create(
      address: interpreter.address,
    );
    return TfliteIdentifier._(
      interpreter,
      isolate,
      labels,
      input.shape[1],
      input.type == TensorType.uint8,
      output.type,
      output.params.scale,
      output.params.zeroPoint,
    );
  }

  /// The isolate interpreter ignores calls while busy, so runs are queued.
  Future<void> _queue = Future.value();

  @override
  Future<IdentificationResult> identify(String imagePath) {
    final result = _queue.then((_) => _identify(imagePath));
    _queue = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  Future<IdentificationResult> _identify(String imagePath) async {
    final encoded = await File(imagePath).readAsBytes();
    final size = _inputSize;
    final rgb = await Isolate.run(() => preprocessToRgb(encoded, size));
    if (rgb == null) {
      throw const IdentificationException('This file is not a photo.');
    }
    final Object input = _inputIsQuantized ? rgb : rgbToUnitFloats(rgb).buffer;

    final List<double> scores;
    if (_outputType == TensorType.uint8) {
      final output = Uint8List(_labels.length);
      await _isolate.run(input, output);
      scores = dequantize(output, _outputScale, _outputZeroPoint);
    } else {
      final output = Float32List(_labels.length);
      await _isolate.run(input, output.buffer);
      scores = ensureProbabilities(output);
    }
    return IdentificationResult(topK(scores, _labels, 5));
  }

  @override
  Future<void> dispose() async {
    await _queue;
    await _isolate.close();
    _interpreter.close();
  }
}
