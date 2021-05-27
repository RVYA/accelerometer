///
/// Based on https://github.com/flutter/plugins/blob/master/packages/sensors/lib/sensors.dart
/// License and credits can be found in given repository.
///


import 'dart:async';

import 'package:flutter/services.dart';


const EventChannel _accelerometerEventChannel =
    EventChannel('plugins.ymc.com/sensors/accelerometer');


/// Discrete reading from an accelerometer. Accelerometers measure the velocity
/// of the device. Note that these readings include the effects of gravity. Put
/// simply, you can use accelerometer readings to tell if the device is moving in
/// a particular direction.
class AccelerometerEvent {
  /// Contructs an instance with the given [x], [y], and [z] values.
  AccelerometerEvent(this.x, this.y, this.z);

  /// Acceleration force along the x axis (including gravity) measured in m/s^2.
  ///
  /// When the device is held upright facing the user, positive values mean the
  /// device is moving to the right and negative mean it is moving to the left.
  final double x;

  /// Acceleration force along the y axis (including gravity) measured in m/s^2.
  ///
  /// When the device is held upright facing the user, positive values mean the
  /// device is moving towards the sky and negative mean it is moving towards
  /// the ground.
  final double y;

  /// Acceleration force along the z axis (including gravity) measured in m/s^2.
  ///
  /// This uses a right-handed coordinate system. So when the device is held
  /// upright and facing the user, positive values mean the device is moving
  /// towards the user and negative mean it is moving away from them.
  final double z;

  @override
  String toString() => '[AccelerometerEvent (x: $x, y: $y, z: $z)]';
}


AccelerometerEvent _listToAccelerometerEvent(List<double> list) {
  return AccelerometerEvent(list[0], list[1], list[2]);
}


Stream<AccelerometerEvent>? _accelerometerEvents;


/// A broadcast stream of events from the device accelerometer.
Stream<AccelerometerEvent> get accelerometerEvents {
  Stream<AccelerometerEvent>? accelerometerEvents = _accelerometerEvents;
  if (accelerometerEvents == null) {
    accelerometerEvents =
        _accelerometerEventChannel.receiveBroadcastStream().map(
              (dynamic event) =>
                  _listToAccelerometerEvent(event.cast<double>()),
            );
    _accelerometerEvents = accelerometerEvents;
  }

  return accelerometerEvents;
}
