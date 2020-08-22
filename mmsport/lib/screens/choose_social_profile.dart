import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:mmsport/constants/constants.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:mmsport/navigations/navigations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ChooseSocialProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    _ChooseSocialProfileState state = new _ChooseSocialProfileState();
    return state;
  }
}

class _ChooseSocialProfileState extends State<ChooseSocialProfile> {
  List<SocialProfile> socialProfiles = new List();
  PageController _pageController = PageController();

  // ignore: missing_return
  Future<List<SocialProfile>> _loadFirebaseData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map map = jsonDecode(preferences.get("chosenSportSchool"));
    SportSchool chosenSportSchool = SportSchool.sportSchoolFromMap(map);
    await Firestore.instance
        .collection("socialProfiles")
        .where("userAccountId", isEqualTo: preferences.get("loggedInUserId"))
        .where("status", isEqualTo: "ACCEPTED")
        .where("sportSchoolId", isEqualTo: chosenSportSchool.id)
        .getDocuments()
        .then((value) => value.documents.forEach((element) {
              SocialProfile newProfile = SocialProfile.socialProfileFromMap(element.data);
              newProfile.id = element.documentID;
              socialProfiles.add(newProfile);
            }));
    return socialProfiles;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SocialProfile>>(
      future: _loadFirebaseData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Material(
              child: Scaffold(
            appBar: AppBar(
              leading: new IconButton(
                  icon: new Icon(Icons.arrow_back),
                  onPressed: () async {
                    SharedPreferences preferences = await SharedPreferences.getInstance();
                    preferences.remove("chosenSportSchool");
                    navigateToChooseSportSchool(context);
                  }),
              title: const Text("Perfiles sociales"),
              centerTitle: true,
              actions: <Widget>[
                _logoutButton()
              ],
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.0),
                child: Center(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: _pageView(context, snapshot.data)),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                margin: EdgeInsets.all(16.0),
                                child: _smoothPageIndicator(snapshot.data),
                              ),
                            )
                          ],
                        ))),
              ),
            ),
          ));
        } else {
          return loadingHome();
        }
      },
    );
  }

  Widget _cardView(SocialProfile socialProfile) {
    return Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
        child: InkWell(
            onTap: () async {
              SharedPreferences preferences = await SharedPreferences.getInstance();
              String socialProfileToJson = jsonEncode(socialProfile.socialProfileToJson());
              preferences.setString("chosenSocialProfile", socialProfileToJson);
              navigateToHome(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.all(10.0),
                      child: socialProfile.urlImage != null
                          ? CircleAvatar(
                              radius: 65,
                              child: ClipOval(
                                child: Image.network(
                                  socialProfile.urlImage,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                ),
                              ))
                          : CircleAvatar(
                              radius: 65,
                              child: ClipOval(
                                child: Icon(
                                  Icons.person,
                                  size: 120,
                                )
                              )),
                    )),
                Container(
                    margin: EdgeInsets.all(5.0),
                    child: Text(
                      socialProfile.name,
                      style: TextStyle(fontSize: 20.0),
                    )),
                Container(
                    margin: EdgeInsets.all(5.0),
                    child: Text(
                      socialProfile.firstSurname,
                      style: TextStyle(fontSize: 20.0),
                    )),
                socialProfile.secondSurname != null
                    ? Container(
                        margin: EdgeInsets.all(5.0),
                        child: Text(
                          socialProfile.secondSurname,
                          style: TextStyle(fontSize: 20.0),
                        ))
                    : Container(child: Text(""))
              ],
            )));
  }

  Widget _pageView(BuildContext context, List<SocialProfile> snapshot) {
    return PageView.builder(
        itemCount: snapshot.length,
        controller: _pageController,
        itemBuilder: (context, int index) {
          return _cardView(snapshot.elementAt(index));
        });
  }

  Widget _smoothPageIndicator(List<SocialProfile> snapshot) {
    return SmoothPageIndicator(
      controller: _pageController, // PageController
      count: snapshot.length,
      effect: WormEffect(dotColor: Colors.grey, activeDotColor: Colors.blueAccent), // your preferred effect
    );
  }

  Widget _logoutButton() {
    return IconButton(
      onPressed: () {
        _logout();
      },
      icon: new IconTheme(
          data: new IconThemeData(
            color: Colors.white,
          ),
          child: Icon(Icons.power_settings_new)),
    );
  }

  void _logout() async {
    deleteLoggedInUserId();
    await FirebaseAuth.instance.signOut();
    logout(context);
  }
}
