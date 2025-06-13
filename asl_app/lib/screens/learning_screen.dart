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
  final List<String> allLetters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'H', 'I', 'J',
    'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S',
    'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  Set<String> completedLetters = {};
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

    final frontCameraIndex = _cameras.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _selectedCameraIndex = frontCameraIndex != -1 ? frontCameraIndex : 0;

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
      if (_cameraController == null || !_cameraController!.value.isInitialized) return;
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
              completedLetters.add(currentLetter);
            });

            Future.delayed(const Duration(seconds: 1), () {
              final remaining = allLetters.where((l) => !completedLetters.contains(l)).toList();
              if (remaining.isNotEmpty) {
                setState(() {
                  currentLetter = remaining.first;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Learning ASL',
          style: AppTextStyles.heading.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Letter:", style: AppTextStyles.heading),
                const SizedBox(width: 8),
                Text(
                  currentLetter,
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 36,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Image.asset(
                  'assets/images/$currentLetter.png',
                  width: 100,
                  height: 100,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                ),
              ],
            ),
            const SizedBox(height: 25),
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
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("It's Correct? :", style: AppTextStyles.body),
                const SizedBox(width: 8),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 45),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: allLetters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final letter = allLetters[index];
                  final isSelected = letter == currentLetter;
                  final isCompleted = completedLetters.contains(letter);

                  return ElevatedButton(
                    onPressed: isCompleted
                        ? null
                        : () {
                            setState(() {
                              currentLetter = letter;
                              isCorrect = false;
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted
                          ? Colors.grey
                          : isSelected
                              ? AppColors.primary
                              : AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(50, 50),
                    ),
                    child: Text(
                      letter,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                      ),
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
