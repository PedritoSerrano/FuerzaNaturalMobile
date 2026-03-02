import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fuerza_natural_login/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FuerzaNaturalApp());
    await tester.pump();
  });
}
