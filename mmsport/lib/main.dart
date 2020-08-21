import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:mmsport/screens/choose_social_profile.dart';
import 'package:mmsport/screens/choose_sport_school.dart';
import 'package:mmsport/screens/homes/home.dart';
import 'package:mmsport/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  bool isAdmin;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
                    return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      home: ChooseSportSchool(),
                    );
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
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: ChooseSportSchool(),
              );
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
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      bool userExists = false;
      if (user != null) {
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email: user.email).then((value) {
          value.length == 0 ? userExists = false : userExists = true;
        });
      }
      if (userExists) {
        map['loggedInUserId'] = true;
        await Firestore.instance
            .collection("admins")
            .where("userId", isEqualTo: sharedPreferences.getString("loggedInUserId"))
            .getDocuments()
            .then((value) => value.documents.length != 0 ? isAdmin = true : isAdmin = false);
      } else {
        map['loggedInUserId'] = false;
      }
    }
    if (sharedPreferences.getString("chosenSportSchool") != null) {
      SportSchool sportSchool = SportSchool.sportSchoolFromMap(jsonDecode(sharedPreferences.get("chosenSportSchool")));
      var ref = await Firestore.instance.collection("sportSchools").document(sportSchool.id).get();
      if (ref.exists) {
        map['chosenSportSchool'] = true;
      }
    }
    if (sharedPreferences.getString("chosenSocialProfile") != null) {
      Map aux = jsonDecode(sharedPreferences.get("chosenSocialProfile"));
      SocialProfile profile = SocialProfile.socialProfileFromMap(aux);
      profile.id = aux['id'];
      var ref = await Firestore.instance.collection("socialProfiles").document(profile.id).get();
      if (ref.exists) {
        map['chosenSocialProfile'] = true;
      }
    }

    return map;
  }
}
