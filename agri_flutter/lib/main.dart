import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/crop_provider.dart';
import 'providers/market_provider.dart';
import 'providers/user_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

// Simple Main App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CropProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'AgriNova',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.green[700],
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            primary: Colors.green[700]!,
          ),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
