import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pandai/services/classifier/classifier_math.dart';

void main() {
  test('parses the label map by id and skips the header', () {
    const csv = 'id,name\n2,background\n0,Betula lenta\n1,"Urtica dioica"\n\n';
    expect(parseLabelMap(csv), ['Betula lenta', 'Urtica dioica', 'background']);
  });

  test('fills gaps in the label ids', () {
    expect(parseLabelMap('0,A\n2,C'), ['A', 'Unknown', 'C']);
    expect(parseLabelMap(''), isEmpty);
  });

  test('preprocessing crops the center square and returns RGB bytes', () {
    // A wide image: red on the left, green in the middle, blue on the right.
    final image = img.Image(width: 300, height: 100);
    for (final pixel in image) {
      if (pixel.x < 100) {
        pixel.setRgb(255, 0, 0);
      } else if (pixel.x < 200) {
        pixel.setRgb(0, 255, 0);
      } else {
        pixel.setRgb(0, 0, 255);
      }
    }
    final png = Uint8List.fromList(img.encodePng(image));
    final rgb = preprocessToRgb(png, 10)!;
    expect(rgb.length, 10 * 10 * 3);
    // Only the green middle square is kept.
    for (var i = 0; i < rgb.length; i += 3) {
      expect(rgb.sublist(i, i + 3), [0, 255, 0]);
    }
  });

  test('preprocessing rejects bytes that are not an image', () {
    expect(preprocessToRgb(Uint8List.fromList([1, 2, 3]), 10), isNull);
  });

  test('float input is scaled to 0..1', () {
    expect(rgbToUnitFloats(Uint8List.fromList([0, 255, 51])), [
      0.0,
      1.0,
      closeTo(0.2, 1e-6),
    ]);
  });

  test('dequantizes with scale and zero point', () {
    expect(dequantize([0, 128, 255], 1 / 256, 0), [0, 0.5, 255 / 256]);
    expect(dequantize([10], 0.5, 8), [1.0]);
  });

  test('raw logits become probabilities, probabilities stay as they are', () {
    final probs = ensureProbabilities([2.0, 1.0, 0.1]);
    expect(probs.reduce((a, b) => a + b), closeTo(1, 1e-9));
    expect(probs[0], greaterThan(probs[1]));
    expect(ensureProbabilities([0.7, 0.2, 0.1]), [0.7, 0.2, 0.1]);
  });

  test('topK sorts by confidence', () {
    final result = topK([0.1, 0.6, 0.3], ['a', 'b', 'c'], 2);
    expect(result.map((p) => p.label), ['b', 'c']);
    expect(result.first.confidence, 0.6);
  });
}
