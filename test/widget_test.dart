import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sourdough_app/main.dart';

void main() {
  testWidgets('onboarding opens the app without ads before consent',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp(showOnboarding: true));
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Starter Recipe'), findsOneWidget);
    expect(find.byType(AdWidget), findsNothing);
  });
}
