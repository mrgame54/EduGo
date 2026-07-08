import 'package:flutter_test/flutter_test.dart';
import 'package:edugo/main.dart';

void main() {
  test('EduGo code base compilation smoke test', () {
    // This test ensures main.dart and its dependencies compile properly.
    const app = EduGoApp();
    expect(app, isNotNull);
  });
}
