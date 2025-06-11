import 'package:asl_app/screens/learning_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ASL',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Para centrar solo el contenido necesario
          children: [
            ElevatedButton(
              onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LearningScreen()),
              );
            },
              child: const Text('Aprender'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 50),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20), // Espacio entre botones
            ElevatedButton(
              onPressed: () {
                // Navegar a pantalla de repaso
              },
              child: const Text('Repasar'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 50),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
