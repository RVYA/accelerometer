/* Based on https://github.com/flutter/plugins/blob/master/packages/sensors/android/src/main/java/io/flutter/plugins/sensors/StreamHandlerImpl.java
   License and credits can be found on the given repository.
  */

package com.ymc.accelerometer;

import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import io.flutter.plugin.common.EventChannel;

class StreamHandlerImpl implements EventChannel.StreamHandler {

  private SensorEventListener sensorEventListener;
  private final SensorManager sensorManager;
  private final Sensor sensor;

  StreamHandlerImpl(SensorManager sensorManager, int sensorType) {
    this.sensorManager = sensorManager;
    sensor = sensorManager.getDefaultSensor(sensorType);
  }

  @Override
  public void onListen(Object arguments, EventChannel.EventSink events) {
    sensorEventListener = createSensorEventListener(events);
    // Because the Linear Accelerometer uses Gyroscope to receive data,
    // accelerometer will be used for both instances. Filtering will be made
    // in listener.
    sensorManager.registerListener(sensorEventListener, sensor, SensorManager.SENSOR_DELAY_NORMAL);
  }

  @Override
  public void onCancel(Object arguments) {
    sensorManager.unregisterListener(sensorEventListener);
  }

  SensorEventListener createSensorEventListener(final EventChannel.EventSink events) {
    return new SensorEventListener() {
      @Override
      public void onAccuracyChanged(Sensor sensor, int accuracy) {}

      @Override
      public void onSensorChanged(SensorEvent event) {
        final double[] sensorValues = new double[event.values.length];
        for (int i = 0; i < event.values.length; i++) {
          sensorValues[i] = event.values[i];
        }
        events.success(sensorValues);
      }
    };
  }
}