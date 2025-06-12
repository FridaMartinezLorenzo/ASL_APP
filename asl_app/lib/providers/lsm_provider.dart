// lib/providers/lsm_provider.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/models/sign_model.dart';

class LSMProvider with ChangeNotifier {
 String getBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:8080'; // Navegador web
    } else if (Platform.isAndroid) {
      // Para emulador Android:
      // return 'http://10.0.2.2:8080'; 

      // Para dispositivo Android físico en red local:
      return 'http://172.20.10.2:8080';
    } else if (Platform.isIOS) {
      return 'http://localhost:8080'; // Emulador iOS
    } else {
      return 'http://localhost:8080'; // Otros (desktop, etc)
    }
  }


  bool isLoading = false;
  SignResponse? lastResponse;

  Future<String?> detectarLetra(File imagen) async {
    try {
      isLoading = true;
      notifyListeners();

      final request = http.MultipartRequest('POST', Uri.parse('${getBaseUrl()}/detectar'));
      request.files.add(await http.MultipartFile.fromPath('file', imagen.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseBody);
        lastResponse = SignResponse.fromJson(jsonData);
        print(lastResponse);
        return lastResponse?.letraDetectada;
      } else {
        print('Error en respuesta: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al enviar imagen: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
