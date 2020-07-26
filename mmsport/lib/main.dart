import 'package:flutter/material.dart';
import 'package:mmsport/screens/choose_social_profile.dart';
import 'package:mmsport/screens/choose_sport_school.dart';
import 'package:mmsport/screens/homes/home.dart';
import 'package:mmsport/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
        future: checkSharedPreferences(),
        // ignore: missing_return
        builder: (BuildContext context, AsyncSnapshot<Map<String, bool>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['chosenSocialProfile'] == true) {
              return MaterialApp(
                home: Home(),
              );
            } else if (snapshot.data['chosenSportSchool'] == true) {
              return MaterialApp(
                home: ChooseSocialProfile(),
              );
            } else if (snapshot.data['loggedInUserId'] == true) {
              return MaterialApp(
                home: ChooseSportSchool(),
              );
            } else if (snapshot.data['loggedInUserId'] == false) {
              return MaterialApp(
                home: Login(),
              );
            }
          } else {
            return Container();
          }
        });

    MaterialApp(
      home: Login(),
    );
  }

  Future<Map<String, bool>> checkSharedPreferences() async {
    Map<String, bool> map = new Map();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("loggedInUserId") == null) {
      map['loggedInUserId'] = false;
    }if (sharedPreferences.getString("loggedInUserId") != null) {
      map['loggedInUserId'] = true;
    }if (sharedPreferences.getString("chosenSportSchool") != null) {
      map['chosenSportSchool'] = true;
    }if (sharedPreferences.getString("chosenSocialProfile") != null) {
      map['chosenSocialProfile'] = true;
    }

    return map;
  }
}
