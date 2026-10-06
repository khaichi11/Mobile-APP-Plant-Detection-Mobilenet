import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Pure helpers used by the plant classifier. They have no Flutter or
/// TensorFlow dependency, so they run in background isolates and in tests.

/// Decodes an image, returning null instead of throwing on broken data.
img.Image? safeDecodeImage(Uint8List bytes) {
  try {
    return img.decodeImage(bytes);
  } catch (_) {
    return null;
  }
}

/// Parses an `id,name` label map. Missing ids become `Unknown`.
List<String> parseLabelMap(String csv) {
  final names = <int, String>{};
  for (final rawLine in csv.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    final comma = line.indexOf(',');
    if (comma <= 0) continue;
    final id = int.tryParse(line.substring(0, comma).trim());
    if (id == null || id < 0) continue; // Also skips the header row.
    names[id] = line.substring(comma + 1).trim().replaceAll('"', '');
  }
  if (names.isEmpty) return const [];
  final maxId = names.keys.reduce(math.max);
  return List.generate(maxId + 1, (i) => names[i] ?? 'Unknown');
}

/// Decodes an encoded photo, fixes its rotation, crops the center square and
/// resizes it to [size]. Returns RGB bytes (size * size * 3), or null when the
/// bytes are not an image.
Uint8List? preprocessToRgb(Uint8List encoded, int size) {
  final decoded = safeDecodeImage(encoded);
  if (decoded == null) return null;
  final oriented = img.bakeOrientation(decoded);
  final side = math.min(oriented.width, oriented.height);
  final square = img.copyCrop(
    oriented,
    x: (oriented.width - side) ~/ 2,
    y: (oriented.height - side) ~/ 2,
    width: side,
    height: side,
  );
  final resized = img.copyResize(
    square,
    width: size,
    height: size,
    interpolation: img.Interpolation.average,
  );
  final rgb = Uint8List(size * size * 3);
  var i = 0;
  for (final pixel in resized) {
    rgb[i++] = pixel.r.toInt();
    rgb[i++] = pixel.g.toInt();
    rgb[i++] = pixel.b.toInt();
  }
  return rgb;
}

/// Scales RGB bytes to floats between 0 and 1, for float models.
Float32List rgbToUnitFloats(Uint8List rgb) {
  final out = Float32List(rgb.length);
  for (var i = 0; i < rgb.length; i++) {
    out[i] = rgb[i] / 255.0;
  }
  return out;
}

/// Converts quantized outputs to real values.
List<double> dequantize(List<int> values, double scale, int zeroPoint) {
  return [for (final v in values) (v - zeroPoint) * scale];
}

/// Turns raw scores into probabilities when they are not probabilities yet.
List<double> ensureProbabilities(List<double> scores) {
  final sum = scores.fold<double>(0, (a, b) => a + b);
  final allInRange = scores.every((s) => s >= 0 && s <= 1);
  if (allInRange && (sum - 1).abs() < 0.05) return scores;
  final maxScore = scores.reduce(math.max);
  final exps = [for (final s in scores) math.exp(s - maxScore)];
  final total = exps.fold<double>(0, (a, b) => a + b);
  return [for (final e in exps) e / total];
}

class Prediction {
  const Prediction(this.label, this.confidence);
  final String label;
  final double confidence;

  @override
  String toString() => 'Prediction($label, $confidence)';
}

/// The [k] best labels, highest confidence first.
List<Prediction> topK(List<double> scores, List<String> labels, int k) {
  final count = math.min(scores.length, labels.length);
  final indices = List<int>.generate(count, (i) => i)
    ..sort((a, b) => scores[b].compareTo(scores[a]));
  return [for (final i in indices.take(k)) Prediction(labels[i], scores[i])];
}
