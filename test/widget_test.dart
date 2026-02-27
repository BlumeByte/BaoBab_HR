import 'package:flutter_test/flutter_test.dart';
import 'package:baobab_hr/main.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(const BaobabHRApp());
    expect(find.text('Welcome to Baobab HR'), findsOneWidget);
  });
}
