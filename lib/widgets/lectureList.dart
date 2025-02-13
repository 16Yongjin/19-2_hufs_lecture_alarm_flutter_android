import 'package:flutter/material.dart';

import '../model/lecture.dart';

class LectureList extends StatelessWidget {
  final List<Lecture> lectures;
  final String selectedLectureId;
  final Function onLectureSelect;
  final String error;

  const LectureList({
    this.lectures,
    this.selectedLectureId,
    this.onLectureSelect,
    this.error,
  });

  Color getColor(String lectureId) {
    return selectedLectureId == lectureId
        ? Color.fromRGBO(204, 213, 221, 1)
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    if (error.isNotEmpty)
      return Center(
        child: Text(
          error,
          style: TextStyle(
            color: Colors.red,
            fontSize: 20,
          ),
        ),
      );
    else if (lectures.length <= 0)
      return Center(child: CircularProgressIndicator());
    else
      return Column(
        children: <Widget>[
          ...lectures.map((lecture) {
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
              child: Container(
                color: getColor(lecture.id),
                child: ListTile(
                  onTap: () {
                    onLectureSelect(lecture.id);
                  },
                  title: Text(lecture.name),
                  subtitle: Text('${lecture.professor}\n${lecture.time}'),
                ),
              ),
            );
          })
        ],
      );
  }
}
