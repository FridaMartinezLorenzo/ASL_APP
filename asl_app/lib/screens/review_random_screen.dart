import 'dart:async';
import 'dart:io';

import 'package:asl_app/providers/lsm_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ReviewRandomScreen extends StatefulWidget {
  const ReviewRandomScreen({super.key});

  @override
  State<ReviewRandomScreen> createState() => _ReviewRandomScreenState();
}

class _ReviewRandomScreenState extends State<ReviewRandomScreen> {
  final List<String> allLetters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  List<Map<String, dynamic>> lettersStatus = [];
  String currentLetter = '';
  bool isCorrect = false;

  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  CameraController? _cameraController;
  Timer? _timer;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeLetters();
    _initializeCamera();
  }

  void _initializeLetters() {
    final random = allLetters.toList()..shuffle();
    final selected = random.take(5).toList();

    lettersStatus =
        selected
            .map((letter) => {'letter': letter, 'completed': false})
            .toList();

    currentLetter = lettersStatus.first['letter'];
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      print('No cameras disponibles');
      return;
    }

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
    if (_cameras.length < 2) return; // Solo una cámara disponible

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

          print('Detectado: $detectedLetter, Esperando: $currentLetter');

          if (detectedLetter != null &&
              detectedLetter.toUpperCase() == currentLetter.toUpperCase()) {
            setState(() {
              isCorrect = true;
              final index = lettersStatus.indexWhere(
                (element) => element['letter'] == currentLetter,
              );
              if (index != -1) {
                setState(() {
                  lettersStatus[index]['completed'] = true;
                });
              }
            });

            Future.delayed(const Duration(seconds: 1), () {
              final nextIndex = lettersStatus.indexWhere(
                (e) => !e['completed'],
              );

              if (nextIndex != -1) {
                setState(() {
                  currentLetter = lettersStatus[nextIndex]['letter'];
                  isCorrect = false;
                });
              } else {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('¡Felicidades!'),
                        content: const Text('Has completado todas las letras.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Aceptar'),
                          ),
                        ],
                      ),
                );
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
            // Letra actual
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "LETRA: $currentLetter",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 16),
                Image.asset(
                  'assets/images/$currentLetter.png',
                  width: 200,
                  height: 200,
                  errorBuilder:
                      (_, __, ___) => const Icon(Icons.image_not_supported),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Vista previa cámara
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child:
                      _cameraController != null &&
                              _cameraController!.value.isInitialized
                          ? CameraPreview(_cameraController!)
                          : const Center(child: CircularProgressIndicator()),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _toggleCamera,
                    child: const Icon(Icons.cameraswitch),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Estado
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("CORRECTO: "),
                Icon(
                  isCorrect ? Icons.check_box : Icons.close,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Letras restantes
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                children:
                    lettersStatus.map((letterData) {
                      final letter = letterData['letter'];
                      final completed = letterData['completed'] == true;

                      return ElevatedButton(
                        onPressed:
                            completed
                                ? null
                                : () {
                                  setState(() {
                                    currentLetter = letter;
                                    isCorrect = false;
                                  });
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              completed
                                  ? Colors.grey
                                  : (letter == currentLetter
                                      ? Colors.black
                                      : Colors.blue),
                          minimumSize: const Size(50, 50),
                        ),
                        child: Text(
                          letter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
