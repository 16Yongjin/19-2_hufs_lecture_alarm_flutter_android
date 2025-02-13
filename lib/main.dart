import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/provider.dart';
import 'widgets/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (_) => Alarm()),
      ],
      child: Consumer<Alarm>(
        builder: (context, alarm, _) {
          return MaterialApp(
            theme: ThemeData(
              primaryColor: Color.fromRGBO(0, 45, 86, 1),
              accentColor: Color.fromRGBO(0, 45, 86, 1),
            ),
            title: '한국외대 강의 빈자리 알람',
            home: HomeWidget(),
          );
        },
      ),
    );
  }
}
