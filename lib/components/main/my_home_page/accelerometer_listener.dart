import 'package:sensors_plus/sensors_plus.dart';

void listenToAccelerometer(Function onTiltLeft, Function onTiltRight) {
  bool isActionPerformed = false;

  accelerometerEvents.listen((event) {
    if (!isActionPerformed) {
      if (event.x < -7) {
        isActionPerformed = true;
        onTiltLeft();
      } else if (event.x > 7) {
        isActionPerformed = true;
        onTiltRight();
      }
    }
    if (event.x.abs() < 3) isActionPerformed = false;
  });
}
