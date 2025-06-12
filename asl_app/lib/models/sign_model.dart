// lib/data/models/sign_model.dart

class SignResponse {
  final String? letraDetectada;

  SignResponse({this.letraDetectada});

  factory SignResponse.fromJson(Map<String, dynamic> json) {
    return SignResponse(
      letraDetectada: json['letra_detectada'],
    );
  }
}
