import 'dart:async';
import 'dart:io';

import 'package:asl_app/providers/lsm_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final List<String> remainingLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
  String currentLetter = 'A';
  bool isCorrect = false;

  CameraController? _cameraController;
  Timer? _timer;

  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      debugPrint('No cameras disponibles');
      return;
    }

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    if (!mounted) return;
    setState(() {});

    _startDetectionLoop();
  }

  void _startDetectionLoop() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_cameraController == null || !_cameraController!.value.isInitialized) return;

      if (!_isDetecting && !isCorrect) {
        _isDetecting = true;
        try {
          // Tomar foto
          final image = await _cameraController!.takePicture();

          // Obtener archivo de imagen
          final file = File(image.path);

          // Enviar imagen al provider para detectar letra
          final lsmProvider = context.read<LSMProvider>();
          final detectedLetter = await lsmProvider.detectarLetra(file);

          debugPrint('Detectado: $detectedLetter, Esperando: $currentLetter');

          if (detectedLetter != null && detectedLetter.toUpperCase() == currentLetter.toUpperCase()) {
            setState(() {
              isCorrect = true;
              remainingLetters.remove(currentLetter);
              if (remainingLetters.isNotEmpty) {
                currentLetter = remainingLetters.first;
                isCorrect = false;
              }
            });
          }
        } catch (e) {
          debugPrint('Error en captura/detección: $e');
        } finally {
          _isDetecting = false;
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lsmProvider = context.watch<LSMProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ASL'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Letra y ejemplo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("LETRA: $currentLetter", style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                Image.asset(
                  'assets/images/$currentLetter.png',
                  width: 200,
                  height: 200,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Vista previa cámara o indicador de carga
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[300],
              child: _cameraController != null && _cameraController!.value.isInitialized
                  ? CameraPreview(_cameraController!)
                  : const Center(child: CircularProgressIndicator()),
            ),

            const SizedBox(height: 16),

            // Estado (correcto o incorrecto)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("CORRECTO: "),
                Icon(
                  isCorrect ? Icons.check_box : Icons.close,
                  color: isCorrect ? Colors.green : Colors.red,
                )
              ],
            ),

            const SizedBox(height: 30),

            // Letras restantes
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: remainingLetters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final letter = remainingLetters[index];
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentLetter = letter;
                        isCorrect = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          letter == currentLetter ? Colors.black : Colors.blue,
                      minimumSize: const Size(50, 50),
                    ),
                    child: Text(letter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
