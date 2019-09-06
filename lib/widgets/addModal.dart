import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../model/lecture.dart';
import '../provider/provider.dart';
import 'departmentDropdown.dart';
import 'courses.dart';
import 'lectureList.dart';
import 'radioWidget.dart';

class AddAlarmModal extends StatefulWidget {
  @override
  _AddAlarmModalState createState() => _AddAlarmModalState();
}

class _AddAlarmModalState extends State<AddAlarmModal> {
  String campusSelect = '서울';
  String courseSelect = '전공';
  String departmentSelect = 'AAR01_H1';
  String lectureSelect = '';
  List<Lecture> lectures = [];
  String error = '';

  @override
  void initState() {
    super.initState();

    _fetchLectures(departmentSelect);
  }

  void onCampusSelect(String campus) {
    setState(() {
      campusSelect = campus;

      departmentSelect = Courses.courses[campusSelect + courseSelect][0][1];

      _fetchLectures(departmentSelect);
    });
  }

  void onCourseSelect(String course) {
    setState(() {
      courseSelect = course;

      departmentSelect = Courses.courses[campusSelect + courseSelect][0][1];

      _fetchLectures(departmentSelect);
    });
  }

  void onDepartmentSelect(String department) {
    setState(() {
      departmentSelect = department;

      _fetchLectures(departmentSelect);
    });
  }

  void _fetchLectures(courseId) {
    setState(() {
      lectureSelect = '';
      error = '';
      lectures = [];
    });

    fetchLectures(departmentSelect).then((v) {
      setState(() {
        lectures = v;
      });
    }).catchError((err) {
      setState(() {
        error = '강의를 가져오는데 실패했습니다.';
      });
    });
  }

  void onLectureSelect(String lectureId) {
    setState(() {
      lectureSelect = lectureSelect == lectureId ? '' : lectureId;
    });
  }

  Widget build(BuildContext context) {
    final alarm = Provider.of<Alarm>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('알람 추가하기'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(30),
        children: <Widget>[
          Center(
              child: Text(
            '알람을 추가할 강의를 선택하세요.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          )),
          RadioWidget(
            label: '캠퍼스:',
            values: ['서울', '글로벌'],
            onSelect: onCampusSelect,
          ),
          RadioWidget(
            label: '과정:',
            values: ['전공', '교양'],
            onSelect: onCourseSelect,
          ),
          DepartmentDropdown(
            courseSelect: campusSelect + courseSelect,
            departmentSelect: departmentSelect,
            onChange: onDepartmentSelect,
          ),
          LectureList(
            lectures: lectures,
            selectedLectureId: lectureSelect,
            onLectureSelect: onLectureSelect,
            error: error,
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: ListTile(
                      title: Text('장식용 입니다.'),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('ㅇㅋ'),
                        onPressed: () => Navigator.of(context).pop(''),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: lectureSelect.isEmpty
            ? Colors.grey[300]
            : Theme.of(context).primaryColor,
        elevation: 4.0,
        icon: const Icon(Icons.add),
        label: const Text(
          '알람 추가하기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: lectureSelect.isEmpty
            ? null
            : () async {
                print('hi');
                await alarm.addAlarm(lectureSelect);
                Navigator.of(context).pop('알람 등록 성공!!');
              },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

Future<List<Lecture>> fetchLectures(String courseId) async {
  final response =
      await http.get('https://api.lecture.hufs.app/lectures/$courseId');

  if (response.statusCode == 200) {
    String body = utf8.decode(response.bodyBytes);

    List<Lecture> lectures = List();

    json.decode(body).forEach((v) {
      lectures.add(Lecture.fromJson(v));
    });

    return lectures;
  } else {
    throw Exception('Failed to load lectures');
  }
}
