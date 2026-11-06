import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/extractor/sources/youtube_proxy.dart';
import 'package:lottie/lottie.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('proxy addresses are normalized without leaking credentials', () {
    expect(
      LocalProxyDetector.normalizeAddress('http://user:secret@127.0.0.1:7890'),
      '127.0.0.1:7890',
    );
    expect(
      LocalProxyDetector.normalizeAddress(
        'http=127.0.0.1:10809;https=127.0.0.1:12334',
      ),
      '127.0.0.1:12334',
    );
    expect(LocalProxyDetector.normalizeAddress('  '), isNull);
  });

  test('wave badge is a native transparent Lottie composition', () async {
    final composition = await AssetLottie('assets/animations/wave_signal.json')
        .load();
    expect(composition.bounds.width, 120);
    expect(composition.bounds.height, 120);
    expect(composition.duration.inMilliseconds, closeTo(1500, 20));
    expect(composition.layers, isNotEmpty);
  });
}
