import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:asl_app/screens/home_screen.dart';
import 'package:asl_app/providers/lsm_provider.dart';
import 'package:asl_app/themes/app_colors.dart';
import 'package:asl_app/themes/app_text_styles.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LSMProvider()),
        // Agrega más providers aquí si es necesario
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
      debugShowCheckedModeBanner: false,
      title: 'ASL',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodyMedium: AppTextStyles.body,
          titleLarge: AppTextStyles.heading,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
