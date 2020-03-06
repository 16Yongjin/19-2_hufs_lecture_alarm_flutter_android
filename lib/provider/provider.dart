import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hufs_lecture_alarm/model/lecture.dart';
import 'package:hufs_lecture_alarm/provider/alarmProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Alarm with ChangeNotifier {
  String _userId;
  List<Lecture> _myAlarms = [];
  int alarmLimit = 1;

  String get userId => _userId;
  List<Lecture> get myAlarms => _myAlarms;
  bool get hitAlarmLimit => _myAlarms.length >= alarmLimit;

  Future<void> loadMyAlarms() async {
    _myAlarms = await AlarmProvider.loadMyAlarms(userId);
    notifyListeners();
  }

  Future<void> addAlarm(String lectureId) async {
    _myAlarms = await AlarmProvider.addAlarm(userId, lectureId);
    notifyListeners();
  }

  void removeAlarm(String lectureId) async {
    _myAlarms = await AlarmProvider.removeAlarm(userId, lectureId);
    notifyListeners();
  }

  void setUserId(String token) {
    _userId = token;
  }

  void initAlarmLimit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    alarmLimit = prefs.getInt('alarmLimit') ?? 1;
  }

  incrementAlarmLimit(int n) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setInt('alarmLimit', min(alarmLimit + n, 5));
  }
}
