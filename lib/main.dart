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
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final bool isWideScreen = mediaQuery.size.width > 480;

        if (!isWideScreen) {
          return child!;
        }

        // Jika dibuka di browser Edge tanpa DevTools (layar lebar saat presentasi),
        // otomatis tampilkan dalam ukuran layar HP yang proporsional di tengah layar.
        const double mobileWidth = 390.0;
        final double mobileHeight =
            (mediaQuery.size.height - 32.0).clamp(560.0, 780.0);

        return ColoredBox(
          color: const Color(0xFF0F172A),
          child: Center(
            child: Container(
              width: mobileWidth,
              height: mobileHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFF334155),
                  width: 6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: MediaQuery(
                data: mediaQuery.copyWith(
                  size: Size(mobileWidth, mobileHeight),
                ),
                child: ScaffoldMessenger(
                  child: child!,
                ),
              ),
            ),
          ),
        );
      },
      home: const MainNavigation(),
    );
  }
}
