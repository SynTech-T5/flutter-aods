import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:aods_app/app/routes/app_pages.dart';

void main() {
  testWidgets('App starts with GetMaterialApp test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      GetMaterialApp(
        title: "Application",
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
      ),
    );

    // Verify that the app builds without errors
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
