import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:mmsport/navigations/navigations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mmsport/components/dialogs.dart';

class ChooseSocialProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    _ChooseSocialProfileState state = new _ChooseSocialProfileState();
    return state;
  }
}

class _ChooseSocialProfileState extends State<ChooseSocialProfile> {
  List<SocialProfile> socialProfiles = new List();

  // ignore: missing_return
  Future<List<SocialProfile>> _loadFirebaseData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map map = jsonDecode(preferences.get("chosenSportSchool"));
    SportSchool chosenSportSchool = SportSchool.sportSchoolFromMap(map);
    await Firestore.instance
        .collection("socialProfiles")
        .where("userAccountId", isEqualTo: preferences.get("loggedInUserId"))
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
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.0),
                child: Center(
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55, child: _pageView(context, snapshot.data))),
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
        margin: EdgeInsets.all(16.0),
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
                              radius: 85,
                              child: ClipOval(
                                child: Image.network(
                                  socialProfile.urlImage,
                                  fit: BoxFit.cover,
                                  width: 150,
                                  height: 150,
                                ),
                              ))
                          : CircleAvatar(
                              radius: 85,
                              child: ClipOval(
                                child: Icon(
                                  Icons.person,
                                  size: 150,
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
        itemBuilder: (context, int index) {
          return _cardView(snapshot.elementAt(index));
        });
  }
}
