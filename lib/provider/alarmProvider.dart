import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:hufs_lecture_alarm/model/lecture.dart';

const String apiUrl = 'http://localhost:3000/users';

class AlarmProvider {
  static Future<List<Lecture>> loadMyAlarms(String userId) async {
    print('loadMyAlarms');
    final response = await http.get('$apiUrl/$userId');

    if (response.statusCode == 200) {
      return parseLectures(response);
    } else {
      throw Exception('알람 가져오기에 실패했습니다.');
    }
  }

  static Future<List<Lecture>> addAlarm(String userId, String lectureId) async {
    print('userId: $userId');
    print('lectureId: $lectureId');

    final body = json.encode({'userId': userId, 'lectureId': lectureId});

    final response = await http.post(apiUrl, body: body);

    print(response.statusCode);
    if (response.statusCode == 200) {
      return parseLectures(response);
    } else {
      throw Exception('알람 등록에 실패했습니다.');
    }
  }

  static Future<List<Lecture>> removeAlarm(
      String userId, String lectureId) async {
    final response = await http.delete('$apiUrl/$userId/$lectureId');

    if (response.statusCode == 200) {
      return parseLectures(response);
    } else {
      throw Exception('알람 삭제에 실패했습니다.');
    }
  }

  static List<Lecture> parseLectures(http.Response response) {
    String body = utf8.decode(response.bodyBytes);

    List<Lecture> lectures = List();

    json.decode(body).forEach((v) {
      lectures.add(Lecture.fromJson(v));
    });

    return lectures;
  }
}
