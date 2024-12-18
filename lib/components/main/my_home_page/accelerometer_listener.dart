import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerListener {
  static StreamSubscription? _subscription;
  static bool isListening = false;

  static void startListening(Function onTiltLeft, Function onTiltRight) {
    if (isListening) return;

    bool isActionPerformed = false;
    isListening = true;

    _subscription = accelerometerEvents.listen((event) {
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

  static void stopListening() {
    if (!isListening) return;

    isListening = false;
    _subscription?.cancel();
    _subscription = null;
  }
}
