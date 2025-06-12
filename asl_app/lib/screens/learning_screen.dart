import 'dart:async';
import 'dart:io';

import 'package:asl_app/providers/lsm_provider.dart';
import 'package:asl_app/themes/app_colors.dart';
import 'package:asl_app/themes/app_text_styles.dart';
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
  final List<String> remainingLetters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'H', 'I', 'J',
    'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R',
    'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];
  String currentLetter = 'A';
  bool isCorrect = false;

  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  CameraController? _cameraController;
  Timer? _timer;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;

    await _startCamera(_selectedCameraIndex);
    _startDetectionLoop();
  }

  Future<void> _startCamera(int index) async {
    final selectedCamera = _cameras[index];

    _cameraController?.dispose();
    _cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  void _toggleCamera() async {
    if (_cameras.length < 2) return;

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _startCamera(_selectedCameraIndex);
  }

  void _startDetectionLoop() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_cameraController == null || !_cameraController!.value.isInitialized)
        return;
      if (!_isDetecting && !isCorrect) {
        _isDetecting = true;
        try {
          final image = await _cameraController!.takePicture();
          final file = File(image.path);
          final lsmProvider = context.read<LSMProvider>();
          final detectedLetter = await lsmProvider.detectarLetra(file);

          if (detectedLetter != null &&
              detectedLetter.toUpperCase() == currentLetter.toUpperCase()) {
            setState(() {
              isCorrect = true;
              remainingLetters.remove(currentLetter);
            });

            Future.delayed(const Duration(seconds: 1), () {
              if (remainingLetters.isNotEmpty) {
                setState(() {
                  currentLetter = remainingLetters.first;
                  isCorrect = false;
                });
              }
            });
          }
        } catch (e) {
          print('Error en captura/detección: $e');
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
        title: Text('Aprende LSM', style: AppTextStyles.heading),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Letra actual
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Letra:", style: AppTextStyles.heading),
                const SizedBox(width: 8),
                Text(currentLetter,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 36,
                      color: AppColors.accent,
                    )),
                const SizedBox(width: 16),
                Image.asset(
                  'assets/images/$currentLetter.png',
                  width: 100,
                  height: 100,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Vista previa de la cámara
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black12,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _cameraController != null &&
                            _cameraController!.value.isInitialized
                        ? CameraPreview(_cameraController!)
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: AppColors.accent,
                    onPressed: _toggleCamera,
                    child: const Icon(Icons.cameraswitch, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Estado de retroalimentación
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Correcto:", style: AppTextStyles.body),
                const SizedBox(width: 8),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 28,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Letras restantes
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: remainingLetters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final letter = remainingLetters[index];
                  final isSelected = letter == currentLetter;

                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentLetter = letter;
                        isCorrect = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? AppColors.primary
                          : AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(50, 50),
                    ),
                    child: Text(
                      letter,
                      style: AppTextStyles.body.copyWith(color: Colors.white),
                    ),
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
