import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:mmsport/screens/choose_social_profile.dart';
import 'package:mmsport/screens/choose_sport_school.dart';
import 'package:mmsport/screens/create_sport_school.dart';
import 'package:mmsport/screens/homes/home.dart';
import 'package:mmsport/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  bool isAdmin;
  bool hasToCreateTheSportSchool = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    configLocalNotification();

    return MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('es', 'ES')
        ],
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<Map<String, bool>>(
            future: checkSharedPreferences(),
            // ignore: missing_return
            builder: (BuildContext context, AsyncSnapshot<Map<String, bool>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data['chosenSocialProfile'] == true) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: Home(),
                  );
                } else if (snapshot.data['chosenSportSchool'] == true) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: ChooseSocialProfile(),
                  );
                } else if (snapshot.data['loggedInUserId'] == true) {
                  if (isAdmin == false) {
                    if (hasToCreateTheSportSchool) {
                      return MaterialApp(
                        debugShowCheckedModeBanner: false,
                        home: CreateSportSchool(),
                      );
                    } else {
                      return MaterialApp(
                        debugShowCheckedModeBanner: false,
                        home: ChooseSportSchool(),
                      );
                    }
                  } else {
                    return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      home: Home(),
                    );
                  }
                } else if (snapshot.data['loggedInUserId'] == false) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: Login(),
                  );
                }
              } else {
                return loadingHome();
              }
            }));
  }

  Future<Map<String, bool>> checkSharedPreferences() async {
    Map<String, bool> map = new Map();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("loggedInUserId") == null) {
      map['loggedInUserId'] = false;
    }
    if (sharedPreferences.getString("loggedInUserId") != null) {
      User user = FirebaseAuth.instance.currentUser;
      bool userExists = false;
      if (user != null) {
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(user.email).then((value) {
          value.length == 0 ? userExists = false : userExists = true;
        });
      }
      if (userExists) {
        map['loggedInUserId'] = true;
        await FirebaseFirestore.instance
            .collection("admins")
            .where("userId", isEqualTo: sharedPreferences.getString("loggedInUserId"))
            .get()
            .then((value) => value.docs.length != 0 ? isAdmin = true : isAdmin = false);
        User user = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance
            .collection("directorsWithoutSportSchool")
            .where("id", isEqualTo: user.uid)
            .get()
            .then((value) {
          if (value.docs.length > 0) {
            hasToCreateTheSportSchool = true;
          }
        });
      } else {
        map['loggedInUserId'] = false;
      }
    }
    if (sharedPreferences.getString("chosenSportSchool") != null) {
      SportSchool sportSchool = SportSchool.sportSchoolFromMap(jsonDecode(sharedPreferences.get("chosenSportSchool")));
      var ref = await FirebaseFirestore.instance.collection("sportSchools").doc(sportSchool.id).get();
      if (ref.exists) {
        map['chosenSportSchool'] = true;
      }
    }
    if (sharedPreferences.getString("chosenSocialProfile") != null) {
      Map aux = jsonDecode(sharedPreferences.get("chosenSocialProfile"));
      SocialProfile profile = SocialProfile.socialProfileFromMap(aux);
      profile.id = aux['id'];
      var ref = await FirebaseFirestore.instance.collection("socialProfiles").doc(profile.id).get();
      if (ref.exists) {
        map['chosenSocialProfile'] = true;
      }
    }

    return map;
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('logo_mmsport');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}
