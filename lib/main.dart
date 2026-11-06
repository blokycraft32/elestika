import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'listrik_provider.dart';
import 'main_navigation.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ListrikProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estikalis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF191970)),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}
