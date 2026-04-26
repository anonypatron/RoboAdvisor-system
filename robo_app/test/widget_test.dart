import 'package:flutter_test/flutter_test.dart';
import 'package:robo_app/main.dart';

void main() {
  testWidgets('메인 네비게이션 탭이 렌더링된다', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Recommendations'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
