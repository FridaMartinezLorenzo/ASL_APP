import 'package:asl_app/models/special_gesture_info.dart';

final List<SpecialGestureInfo> aslSpecialGesturesData = [
  SpecialGestureInfo(
    name: 'Gracias',
    imagePath: 'assets/images/gracias.png',
    videoPath: 'assets/videos/gracias.mp4',
    description: 'Este gesto representa gratitud, se realiza moviendo la mano desde el mentón hacia adelante.',
  ),
  SpecialGestureInfo(
    name: 'Sí',
    imagePath: 'assets/images/si.png',
    videoPath: 'assets/videos/si.mp4',
    description: 'Gesto para afirmar o decir que sí, generalmente con el pulgar hacia arriba o moviendo la cabeza.',
  ),
  SpecialGestureInfo(
    name: 'No',
    imagePath: 'assets/images/no.png',
    videoPath: 'assets/videos/no.mp4',
    description: 'Gesto para negar o decir que no, realizado moviendo los dedos índice y medio juntos hacia delante y atrás.',
  ),

];
