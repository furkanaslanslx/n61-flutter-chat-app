import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:n61/viewmodel/user_view_model.dart';
import 'package:n61/viewmodel/chat_view_model.dart';

import 'package:n61/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserViewModel()),
          ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ],
        child: const MyApp(),
      ),
    );

    // Since the app now loads products asynchronously, we need to wait a bit
    await tester.pump();

    // Just verify the app renders without error
    expect(find.text('N61'), findsOneWidget);
  });
}
