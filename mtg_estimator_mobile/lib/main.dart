import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/collection_provider.dart';
import 'providers/search_provider.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/collection_screen.dart';
import 'screens/scanner_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CollectionProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: MaterialApp(
        title: 'MTG Estimator',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/search': (context) => const SearchScreen(),
          '/collection': (context) => const CollectionScreen(),
          '/scanner': (context) => const ScannerScreen(),
        },
      ),
    );
  }
}
