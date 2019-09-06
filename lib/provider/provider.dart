import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hufs_lecture_alarm/model/lecture.dart';

class Counter with ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

class Alarm with ChangeNotifier {
  String _userId;
  List<Lecture> _myAlarms = [];

  String get userId => _userId;
  List<Lecture> get myAlarms => _myAlarms;
  bool get alarmLimit => _myAlarms.length > 5;

  Future<void> loadMyAlarms() async {
    print('loadMyAlarms');
    final response =
        await http.get('https://api.lecture.hufs.app/myalarm/$userId');

    if (response.statusCode == 200) {
      _myAlarms = parseLectures(response);
      notifyListeners();
    } else {
      throw Exception('알람 가져오기에 실패했습니다.');
    }
  }

  Future<void> addAlarm(String lectureId) async {
    print('userId: $userId');
    print('lectureId: $lectureId');

    final user = {'id': userId};
    final body = json.encode({'user': user, 'lectureId': lectureId});

    final response =
        await http.post('https://api.lecture.hufs.app/myalarm', body: body);

    print(response.statusCode);
    if (response.statusCode == 201) {
      _myAlarms = parseLectures(response);
      notifyListeners();
    } else {
      throw Exception('알람 등록에 실패했습니다.');
    }
  }

  void removeAlarm(String lectureId) async {
    final response = await http
        .delete('https://api.lecture.hufs.app/myalarm/$userId/$lectureId');

    if (response.statusCode == 200) {
      _myAlarms = parseLectures(response);
      notifyListeners();
    } else {
      throw Exception('알람 삭제에 실패했습니다.');
    }
  }

  List<Lecture> parseLectures(http.Response response) {
    String body = utf8.decode(response.bodyBytes);

    List<Lecture> lectures = List();

    json.decode(body).forEach((v) {
      lectures.add(Lecture.fromJson(v));
    });

    return lectures;
  }

  void setUserId(String token) {
    _userId = token;
  }
}
