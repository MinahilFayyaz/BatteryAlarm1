import 'package:battery_alarm/Model/ringtones_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BatteryAlarmprovider extends ChangeNotifier {
  bool isChecked = false;
  double lowerVal = 0;
  int? selectedIndex;
  String? selectedRingtonePath;
  late SharedPreferences prefs;

  void toggleCheckbox(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  selectedLowerVal(double val) async {
    lowerVal = val;
    notifyListeners();
    prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('currentLowValue', lowerVal);
  }

  selectedRingtone(String path) async {
    selectedRingtonePath = path;
    notifyListeners();
    prefs = await SharedPreferences.getInstance();
    await prefs?.setString('selectedRingtone', selectedRingtonePath!);
  }
}

// class valProvider extends ChangeNotifier {
//   double lowerVal = 0;
//   late SharedPreferences prefs;

//   selectedLowerVal(double val) async {
//     lowerVal = val;
//     notifyListeners();
//     prefs = await SharedPreferences.getInstance();
//     await prefs.setDouble('currentLowValue', lowerVal);
//   }
// }
