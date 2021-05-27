/* Based on https://github.com/flutter/plugins/blob/master/packages/sensors/android/src/main/java/io/flutter/plugins/sensors/SensorsPlugin.java
   License and credits can be found in given repository.
  */

package com.ymc.accelerometer;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;

/** SensorsPlugin */
public class AccelerometerPlugin implements FlutterPlugin {
  private static final String
          ACCELEROMETER_CHANNEL_NAME = "plugins.ymc.com/accelerometer",
          LINEAR_ACCELEROMETER_CHANNEL_NAME = "plugins.ymc.com/linear_accelerometer";

  private EventChannel
          accelerometerChannel,
          linearAccelerometerChannel;

  /** Plugin registration. */
  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
    AccelerometerPlugin plugin = new AccelerometerPlugin();
    plugin.setupEventChannels(registrar.context(), registrar.messenger());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    final Context context = binding.getApplicationContext();
    setupEventChannels(context, binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    teardownEventChannels();
  }

  private void setupEventChannels(Context context, BinaryMessenger messenger) {
    accelerometerChannel = new EventChannel(messenger, ACCELEROMETER_CHANNEL_NAME);
    final StreamHandlerImpl accelerationStreamHandler =
        new StreamHandlerImpl(
            (SensorManager) context.getSystemService(Context.SENSOR_SERVICE),
            Sensor.TYPE_ACCELEROMETER);
    accelerometerChannel.setStreamHandler(accelerationStreamHandler);

    linearAccelerometerChannel = new EventChannel(messenger, LINEAR_ACCELEROMETER_CHANNEL_NAME);
    final StreamHandlerImpl linearAccelerationStreamHandler =
        new StreamHandlerImpl(
            (SensorManager) context.getSystemService(Context.SENSOR_SERVICE),
            Sensor.TYPE_LINEAR_ACCELERATION);
    linearAccelerometerChannel.setStreamHandler(linearAccelerationStreamHandler);
  }

  private void teardownEventChannels() {
    accelerometerChannel.setStreamHandler(null);
    linearAccelerometerChannel.setStreamHandler(null);
  }
}