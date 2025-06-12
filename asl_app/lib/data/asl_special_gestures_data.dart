import 'package:asl_app/models/special_gesture_info.dart';

final List<SpecialGestureInfo> aslSpecialGesturesData = [
  SpecialGestureInfo(
    name: 'Gracias',
    imagePath: 'assets/images/special_gestures/gracias.png',
    videoPath: 'assets/videos/special_gestures/gracias.mp4',
    description: 'Este gesto representa gratitud, se realiza moviendo la mano desde el mentón hacia adelante.',
  ),
  SpecialGestureInfo(
    name: 'Sí',
    imagePath: 'assets/images/special_gestures/si.png',
    videoPath: 'assets/videos/special_gestures/si.mp4',
    description: 'Gesto para afirmar o decir que sí, generalmente con el pulgar hacia arriba o moviendo la cabeza.',
  ),
  SpecialGestureInfo(
    name: 'No',
    imagePath: 'assets/images/special_gestures/no.png',
    videoPath: 'assets/videos/special_gestures/no.mp4',
    description: 'Gesto para negar o decir que no, realizado moviendo los dedos índice y medio juntos hacia delante y atrás.',
  ),
  // Añade más gestos especiales aquí...
];
