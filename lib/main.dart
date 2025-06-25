import 'package:flutter/material.dart';
import 'package:n61/viewmodel/chat_view_model.dart';
import 'package:provider/provider.dart';
import 'viewmodel/user_view_model.dart';
import 'v/home.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        // ChangeNotifierProvider(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        // Buraya diğer provider'lar eklenebilir
        // ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        // ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        // Provider<SomeService>(create: (_) => SomeService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'N61',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
