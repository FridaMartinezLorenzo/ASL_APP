import 'package:flutter/material.dart';
import 'package:asl_app/screens/learning_screen.dart';
import 'package:asl_app/screens/informative/informative_screen.dart';
import 'package:asl_app/themes/app_colors.dart';
import 'package:asl_app/themes/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lenguaje de Señas (ASL)'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido',
              style: AppTextStyles.heading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Elige una opción para comenzar:',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildMenuButton(
              context,
              label: 'Aprender',
              icon: Icons.school,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LearningScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context,
              label: 'Repasar',
              icon: Icons.refresh,
              onPressed: () {
                // TODO: implementar navegación a pantalla de repaso
              },
            ),
            const SizedBox(height: 20),
            _buildMenuButton(
              context,
              label: 'Información',
              icon: Icons.info_outline,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InformativeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
