import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hufs_lecture_alarm/widgets/lifecycleListener.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../provider/provider.dart';
import 'alarmCard.dart';
import 'addModal.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
      resumeCallBack: () {
        final alarm = Provider.of<Alarm>(context);
        return alarm.loadMyAlarms();
      },
      suspendingCallBack: () async {},
    ));

    _firebaseMessaging.getToken().then((token) {
      print(token);

      final alarm = Provider.of<Alarm>(context);
      alarm.setUserId(token);
      alarm.loadMyAlarms();
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        final alarm = Provider.of<Alarm>(context);
        alarm.loadMyAlarms();

        print("onMessage: $message");

        FlutterRingtonePlayer.playNotification();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  Widget build(BuildContext context) {
    final alarm = Provider.of<Alarm>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('한국외대 강의 빈자리 알람'),
      ),
      body: ListView(
        padding: EdgeInsets.all(12.0),
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            child: Text('내가 등록한 알람 ${alarm.myAlarms.length} / 5개',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                )),
          ),
          ...alarm.myAlarms.map((lecture) => AlarmCard(lecture: lecture))
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              height: 48,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: alarm.alarmLimit
            ? Colors.grey[300]
            : Theme.of(context).primaryColor,
        elevation: 4.0,
        icon: const Icon(Icons.add),
        label: const Text(
          '알람 추가하기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: alarm.alarmLimit
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute<String>(
                    builder: (BuildContext context) => AddAlarmModal(),
                    fullscreenDialog: true,
                  ),
                ).then((message) {
                  if (message == null || message.isEmpty) return;

                  showToast(message);
                });
              },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void showToast(String message) {
    Toast.show(
      message,
      context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.TOP,
    );
  }
}
