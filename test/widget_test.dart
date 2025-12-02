import 'package:flutter_test/flutter_test.dart';
import 'package:god_life/main.dart';

void main() {
  testWidgets('홈 화면이 루틴과 할 일을 보여준다', (tester) async {
    await tester.pumpWidget(const GodLifeApp());

    expect(find.textContaining('오늘'), findsWidgets);
    expect(find.textContaining('루틴'), findsWidgets);
    expect(find.textContaining('할 일'), findsWidgets);
    expect(find.text('오늘 루틴/할 일 추가하기'), findsOneWidget);
  });
}
