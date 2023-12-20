import 'dart:async';

import 'package:battery_alarm/views/Ringtones/batteryalarm_provider.dart';
import 'package:battery_alarm/views/controller/home_controller.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';
import 'package:torch_light/torch_light.dart';
import 'package:vibration/vibration.dart';

class BatteryMonitor {
  final Battery _battery = Battery();
  late bool _isNotificationShown;
  late bool _isLowBatteryNotificationShown;
  late double _currentValue;
  late double _currentLowValue;
  final assetsAudioPlayer = AssetsAudioPlayer();
  late BuildContext context;
  late SharedPreferences prefs;
  var controller = Get.put(HomeController());
  late bool isFlashlightOn;
  bool vibrationSwitch = false;
  String selectedVibrate = "small";

  BatteryMonitor({
    required bool isNotificationShown,
    required bool isLowBatteryNotificationShown,
    required double currentValue,
    required double currentLowValue,
    required BuildContext context,
  }) {
    _isNotificationShown = isNotificationShown;
    _isLowBatteryNotificationShown = isLowBatteryNotificationShown;
    _currentValue = currentValue;
    _currentLowValue = currentLowValue;
    this.context = context;

    _monitorBatteryLevel();
  }

  Future<void> showBatteryAlarmNotification({String? message}) async {
    // initializeTorchLight();
    playAlarmSounds();

    // AwesomeNotifications().createNotification(
    //   content: NotificationContent(
    //     id: 0,
    //     channelKey: 'basic_channel',
    //     title: 'Battery Alarm',
    //     body: message ?? 'Battery level reached your selected level!',
    //   ),
    // );
  }

  void initializeTorchLight() async {
    await TorchLight.enableTorch();
  }

  Future<void> disposeTorchLight() async {
    await TorchLight.disableTorch();
  }

  void playAlarmSounds() async {
    prefs = await SharedPreferences.getInstance();
    final batteryLevel = await _battery.batteryLevel;

    BatteryAlarmprovider pro =
        Provider.of<BatteryAlarmprovider>(context, listen: false);
    assetsAudioPlayer.open(
      Audio(prefs.getString("selectedRingtone") ?? ""),
    );
    if (prefs.getBool('flashlightSwitch') != false) {
      if (controller.flashType == "short") {
        initializeTorchLight();
        Timer(const Duration(seconds: 3), () {
          toggleFlashlight(false); // Turn off flashlight after 3 seconds
          disposeTorchLight();
        });
      }

      if (controller.flashType == "long") {
        // Fixed typo in flashType
        initializeTorchLight();
        Timer(const Duration(seconds: 5), () {
          toggleFlashlight(false); // Turn off flashlight after 5 seconds
          disposeTorchLight();
        });
      }
    }

    if (vibrationSwitch) {
      // Vibrate the device based on the selected pattern
      if (selectedVibrate == "small") {
        Vibration.vibrate(duration: 1000);
        Vibration.cancel();
      } else if (selectedVibrate == "medium") {
        Vibration.vibrate(pattern: [500, 1000, 500, 2000, 500, 3000, 500, 500]);
        Vibration.cancel();
      } else if (selectedVibrate == "large") {
        Vibration.vibrate(
          pattern: [500, 1000, 500, 2000, 500, 3000, 500, 500],
          intensities: [0, 128, 0, 255, 0, 64, 0, 255],
        );
      }
    }
  }

  void toggleFlashlight(bool light) {
    if (light) {
      TorchLight.enableTorch();
    } else {
      TorchLight.disableTorch();
    }
    // Note: Remove setState if not using StatefulWidget
    // setState(() {
    //   isFlashlightOn = light;
    // });
  }

  void _monitorBatteryLevel() async {
    prefs = await SharedPreferences.getInstance();
    _battery.onBatteryStateChanged.listen((BatteryState state) async {
      final batteryLevel = await _battery.batteryLevel;
      print("Check Statement: ${prefs.getDouble('currentLowValue') ?? 20.0}");

      if (batteryLevel.toInt() == _currentValue.toInt()) {
        if (!_isNotificationShown) {
          await showBatteryAlarmNotification(
              message:
                  "Battery level reached to ${_currentValue.toInt().round()}%");
          _isNotificationShown = true;

          prefs.setBool('isNotificationShown', false);
        } else {
          _isNotificationShown = false;
        }
      }

      if (batteryLevel.toInt() == _currentLowValue.toInt()) {
        print("objectaadada");

        if (!_isLowBatteryNotificationShown) {
          showBatteryAlarmNotification(message: "Low Battery Notification");
          _isLowBatteryNotificationShown = true;
        } else {
          _isLowBatteryNotificationShown = false;
        }
      }
    });
  }
}
