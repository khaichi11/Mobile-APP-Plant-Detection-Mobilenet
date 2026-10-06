import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'classifier/classifier_math.dart';

/// Keeps herbarium and avatar photos in the app's own folder, so they survive
/// when the camera cache or gallery file is deleted.
class PhotoStore {
  PhotoStore({Future<Directory> Function()? baseDirectory})
    : _baseDirectory = baseDirectory ?? getApplicationDocumentsDirectory;

  static const maxSide = 1080;

  final Future<Directory> Function() _baseDirectory;

  /// Copies [sourcePath] into [folder], shrinking large photos. Returns the
  /// new path.
  Future<String> save(String sourcePath, {required String folder}) async {
    final bytes = await File(sourcePath).readAsBytes();
    final jpeg = await Isolate.run(() => shrinkToJpeg(bytes, maxSide));
    final dir = Directory(p.join((await _baseDirectory()).path, folder));
    await dir.create(recursive: true);
    final name = '${DateTime.now().microsecondsSinceEpoch}.jpg';
    final file = File(p.join(dir.path, name));
    await file.writeAsBytes(jpeg ?? bytes, flush: true);
    return file.path;
  }

  Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}

/// Re-encodes a photo as JPEG with its longest side at most [maxSide].
/// Returns null if the bytes are not an image.
Uint8List? shrinkToJpeg(Uint8List bytes, int maxSide) {
  final decoded = safeDecodeImage(bytes);
  if (decoded == null) return null;
  final oriented = img.bakeOrientation(decoded);
  final longest = math.max(oriented.width, oriented.height);
  final resized =
      longest <= maxSide
          ? oriented
          : img.copyResize(
            oriented,
            width: oriented.width >= oriented.height ? maxSide : null,
            height: oriented.height > oriented.width ? maxSide : null,
            interpolation: img.Interpolation.average,
          );
  return img.encodeJpg(resized, quality: 85);
}
