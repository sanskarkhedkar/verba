import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verba/app.dart';

void main() {
  testWidgets('Verba launches onboarding', (tester) async {
    await tester.pumpWidget(ProviderScope(child: VerbaApp()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Verba'), findsOneWidget);
    expect(find.text('Start speaking today'), findsOneWidget);
  });
}
