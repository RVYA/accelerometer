/// Based on https://github.com/flutter/plugins/blob/master/packages/sensors/lib/sensors.dart
/// License and credits can be found in given repository.


import 'dart:async';
import 'dart:math' as math show pi, acos, sqrt;

import 'package:flutter/services.dart' show EventChannel;


const EventChannel _accelerometerEventChannel =
    EventChannel('plugins.ymc.com/accelerometer');

const double _kHighPassFilterRampFactor = 0.1;
const double
    _kDeviceAngleThresholdZTowardsGround =  25,
    _kDeviceAngleThresholdZTowardsSky    = 155;


/// Discrete reading from an accelerometer. Accelerometers measure the velocity
/// of the device. Note that these readings include the effects of gravity. Put
/// simply, you can use accelerometer readings to tell if the device is moving in
/// a particular direction.
class AccelerometerEvent {
  /// Contructs an instance with the given [x], [y], and [z] values.
  const AccelerometerEvent(this.x, this.y, this.z);

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


  AccelerometerEvent applyHighPassFilter({
    required final List<double> priorDelta,
    final double alpha = _kHighPassFilterRampFactor,
  }) {
    priorDelta[0] = (this.x * alpha) + (priorDelta[0] * (1.0 - alpha));
    priorDelta[1] = (this.y * alpha) + (priorDelta[1] * (1.0 - alpha));
    priorDelta[2] = (this.z * alpha) + (priorDelta[2] * (1.0 - alpha));
    
    return
        AccelerometerEvent(
          this.x - priorDelta[0],
          this.y - priorDelta[1],
          this.z - priorDelta[2],
        );
  }

  /// When device is held "perpendicular" to the ground in portrait view,
  /// "y" value of acceleration vector is equal to the gravity. And when the
  /// device is held "parallel" to the ground, "y" value of acceleration vector
  /// should be about (gravity/2).
  ///
  /// By deciding that device should be perceived as "flat" (z axis pointing
  /// towards sky or ground) when angle between ground and device is "equal or
  /// less than 25" or "equal or greater than 155 degrees", it can be known
  /// if device is held flat or not.
  bool isDeviceHeldFlat({
    double angleThresholdScreenToGround = _kDeviceAngleThresholdZTowardsGround,
    double angleThresholdScreenToSky    = _kDeviceAngleThresholdZTowardsSky,
  }) {
    final int inclination = calculateDeviceZInclination();
    return (inclination <= angleThresholdScreenToGround)
        || (inclination >= angleThresholdScreenToSky);
  }

  /// The z axis points towards screen; this means to calculate the angle
  /// between screen and ground plane, inclination of z axis against ground
  /// must be calculated.
  int calculateDeviceZInclination() {
    final double accelerationNormal =
        math.sqrt(
          (this.x * this.x)
          + (this.y * this.y)
          + (this.z * this.z),
        );
    
    return _radianToDegrees(math.acos(this.z / accelerationNormal)).round();
  }

  /// The x axis points towards right side of the device; this means to
  /// calculate angle between device and the YZ axis, inclination of x axis
  /// against plane which is perpendicular to the ground must be calculated.
  /// 
  /// NOTE: While the x inclination returns about 90 degrees when device is
  /// on portrait mode while screen is perpendicular against ground, this
  /// method is intended to calculate "yaw" while device is flat (parallel
  /// to the ground.)
  int calculateDeviceXInclination() {
    final double accelerationNormal =
        math.sqrt(
          (this.x * this.x)
          + (this.y * this.y)
          + (this.z * this.z),
        );
    
    return _radianToDegrees(math.acos(this.x / accelerationNormal)).round();
  }

  @override
  String toString() => '[AccelerometerEvent (x: $x, y: $y, z: $z)]';
}


AccelerometerEvent _listToAccelerometerEvent(List<double> list) {
  return AccelerometerEvent(list[0], list[1], list[2]);
}

double _radianToDegrees(double radian) => ((radian * 180.0) / math.pi);


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
