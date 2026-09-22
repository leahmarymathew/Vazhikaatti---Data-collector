import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:path/path.dart' as p;
import 'package:vazhikatti_dataset_collector/services/panorama/panorama_stitcher.dart';

/// Textured 360° cylinder (radius f) rendered into 8 pinhole views, 45° apart.
List<String> _renderViews(Directory dir, {int skipTexture = -1}) {
  const w = 480, h = 640;
  final f = (w / 2) / math.tan(30 * math.pi / 180); // 60° horizontal FOV
  final scene = cv.Mat.zeros(h, (2 * math.pi * f).round(), cv.MatType.CV_8UC3);
  final rng = math.Random(7);
  for (var i = 0; i < 1500; i++) {
    cv.circle(
      scene,
      cv.Point(rng.nextInt(scene.cols), rng.nextInt(h)),
      3 + rng.nextInt(18),
      cv.Scalar(rng.nextInt(255).toDouble(), rng.nextInt(255).toDouble(),
          rng.nextInt(255).toDouble()),
      thickness: rng.nextBool() ? -1 : 2,
    );
  }
  final paths = <String>[];
  for (var k = 0; k < 8; k++) {
    final yaw = k * 45 * math.pi / 180;
    final mx = Float32List(w * h), my = Float32List(w * h);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final dx = x - w / 2, dy = y - h / 2;
        final theta = yaw + math.atan(dx / f);
        var u = theta * f;
        u = ((u % scene.cols) + scene.cols) % scene.cols;
        mx[y * w + x] = u;
        my[y * w + x] = h / 2 + f * dy / f / math.sqrt(dx * dx / (f * f) + 1);
      }
    }
    final view = cv.remap(
      scene,
      cv.Mat.fromList(h, w, cv.MatType.CV_32FC1, mx),
      cv.Mat.fromList(h, w, cv.MatType.CV_32FC1, my),
      cv.INTER_LINEAR,
    );
    final path = p.join(dir.path, 'view_$k.jpg');
    cv.imwrite(path, k == skipTexture ? cv.Mat.zeros(h, w, cv.MatType.CV_8UC3) : view);
    paths.add(path);
  }
  return paths;
}

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('pano_test'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('8 overlapping views stitch into one valid panorama', () async {
    final views = _renderViews(dir);
    final out = p.join(dir.path, 'pano.jpg');
    final result = await PanoramaStitcher.stitch(views, out);
    expect(File(out).existsSync(), isTrue);
    final img = cv.imread(out);
    expect(img.isEmpty, isFalse);
    expect(img.cols, result.width);
    expect(img.cols, greaterThan(480 * 3));
    expect(result.inlierCount, greaterThan(0));
    // originals untouched
    for (final v in views) {
      expect(File(v).existsSync(), isTrue);
    }
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('a textureless frame fails with the failing image identified', () async {
    final views = _renderViews(dir, skipTexture: 3);
    final out = p.join(dir.path, 'pano.jpg');
    await expectLater(
      PanoramaStitcher.stitch(views, out),
      throwsA(
        isA<PanoramaStitchException>()
            .having((e) => e.stage, 'stage', 'features')
            .having((e) => e.pair, 'pair', 4),
      ),
    );
    expect(File(out).existsSync(), isFalse);
    for (final v in views) {
      expect(File(v).existsSync(), isTrue);
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}
