// Derive the in-app transparent mark from the launcher artwork, without changing
// the original icon. Run: dart run tool/prepare_app_mark.dart <input> <output>
import 'dart:io';

// The existing flutter_launcher_icons dev tool already supplies this package.
// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as img;

void main(List<String> args) {
  final source = img.decodeImage(File(args[0]).readAsBytesSync())!;
  final small = img.copyResize(source, width: 64, height: 32);
  stdout.writeln(
    'Source ${source.width} x ${source.height}, channels ${source.numChannels}',
  );
  for (var y = 0; y < small.height; y++) {
    final row = StringBuffer();
    for (var x = 0; x < small.width; x++) {
      final p = small.getPixel(x, y);
      final l = (p.r + p.g + p.b) / 3;
      row.write(
        p.a < 30
            ? ' '
            : l > 230
            ? '.'
            : l > 180
            ? ':'
            : l > 100
            ? '*'
            : '#',
      );
    }
    stdout.writeln(row);
  }
  if (args.length < 2) return;
  // The source has a light paper ground and dark monochrome lettering. Convert
  // luminance into alpha to retain anti-aliased edges, not an opaque square.
  final mark = img.Image(
    width: source.width,
    height: source.height,
    numChannels: 4,
  );
  var minX = source.width, minY = source.height, maxX = 0, maxY = 0;
  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final p = source.getPixel(x, y);
      final l = (p.r + p.g + p.b) / 3;
      final alpha = ((235 - l) / 205 * 255).round().clamp(0, 255);
      mark.setPixelRgba(x, y, 255, 255, 255, alpha);
      if (alpha > 32) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  if (minX >= maxX || minY >= maxY) throw StateError('No mark found');
  final cropped = img.copyCrop(
    mark,
    x: minX,
    y: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  );
  final resized = img.copyResize(
    cropped,
    width: 256,
    interpolation: img.Interpolation.average,
  );
  File(args[1]).writeAsBytesSync(img.encodePng(resized));
  stdout.writeln(
    'Transparent mark: ${resized.width} x ${resized.height}; crop $minX,$minY - $maxX,$maxY',
  );
}
