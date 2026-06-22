// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'services/hive_service.dart';
import 'viewmodels/produto_viewmodel.dart';
import 'views/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  final hiveService = HiveService();
  await hiveService.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProdutoViewModel(hiveService),
      child: const CalculadoraLucroApp(),
    ),
  );
}

class CalculadoraLucroApp extends StatefulWidget {
  const CalculadoraLucroApp({super.key});
  @override
  State<CalculadoraLucroApp> createState() => _CalculadoraLucroAppState();
}

class _CalculadoraLucroAppState extends State<CalculadoraLucroApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF4F46E5);
    return MaterialApp(
      title: 'Calculadora de Lucro',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seedColor,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seedColor,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
      ),
      home: HomeView(onToggleTheme: _toggleTheme, themeMode: _themeMode),
    );
  }
}
