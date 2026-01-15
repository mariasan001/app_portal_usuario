import 'package:flutter_test/flutter_test.dart';
import 'package:portal_servicios_usuario/app/app.dart';

void main() {
  testWidgets('Arranca la app', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(true, isTrue);
  });
}
