import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/constants/constants.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:mmsport/navigations/navigations.dart';
import 'package:mmsport/screens/choose_social_profile.dart';
import 'package:mmsport/screens/choose_sport_school.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu_helper.dart';
import 'package:mmsport/screens/homes/menu_helper.dart';
import 'package:mmsport/components/dialogs.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Home();
  }
}

class _Home extends State<Home> {
  SportSchool chosenSportSchool;
  SocialProfile chosenSocialProfile;
  bool isAdmin;

  Future<bool> _checkAdmin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userId = preferences.get("loggedInUserId");
    await FirebaseFirestore.instance
        .collection("admins")
        .where("userId", isEqualTo: userId)
        .get()
        .then((value) => value.docs.length != 0 ? isAdmin = true : isAdmin = false);
    return isAdmin;
  }

  Future<SportSchool> _loadSportSchool() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = await jsonDecode(preferences.get("chosenSportSchool"));
    chosenSportSchool = SportSchool.sportSchoolFromMap(aux);
    return chosenSportSchool;
  }

  Future<SocialProfile> _loadSocialProfile() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = await jsonDecode(preferences.get("chosenSocialProfile"));
    chosenSocialProfile = SocialProfile.socialProfileFromMap(aux);
    chosenSocialProfile.id = aux['id'];
    return chosenSocialProfile;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkAdmin(),
      builder: (context, adminSnapshot) {
        if (adminSnapshot.hasData) {
          if (adminSnapshot.data == true) {
            return Scaffold(
              appBar: AppBar(
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.all(10.0),
                  centerTitle: true,
                  title: Text(
                    "Menú de admin",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                actions: <Widget>[
                  _logoutButton(),
                ],
              ),
              body: menuGrid(context, "ADMIN"),
            );
          } else {
            return FutureBuilder<List<dynamic>>(
                future: Future.wait([_loadSportSchool(), _loadSocialProfile()]),
                builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshots) {
                  if (snapshots.hasData) {
                    return Scaffold(
                      appBar: PreferredSize(
                        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.15),
                        child: AppBar(
                          flexibleSpace: FlexibleSpaceBar(
                              titlePadding: EdgeInsets.all(10.0),
                              centerTitle: true,
                              title: Center(
                                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                                Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                                  CircleAvatar(radius: 28, backgroundImage: NetworkImage(snapshots.data[0].urlLogo)),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.64,
                                      child: Container(
                                          padding: EdgeInsets.all(10.0),
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  snapshots.data[0].name,
                                                  style: TextStyle(color: Colors.white, fontSize: 22),
                                                  overflow: TextOverflow.ellipsis,
                                                  softWrap: true,
                                                ),
                                                snapshots.data[1].secondSurname != null
                                                    ? Text(
                                                        snapshots.data[1].name +
                                                            " " +
                                                            snapshots.data[1].firstSurname +
                                                            " " +
                                                            snapshots.data[1].secondSurname,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontStyle: FontStyle.italic,
                                                            fontSize: 18),
                                                        overflow: TextOverflow.ellipsis,
                                                        softWrap: true)
                                                    : Text(
                                                        snapshots.data[1].name + " " + snapshots.data[1].firstSurname,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontStyle: FontStyle.italic,
                                                            fontSize: 18),
                                                        overflow: TextOverflow.ellipsis,
                                                        softWrap: true)
                                              ]))),
                                ]),
                                PopupMenuButton<int>(
                                    itemBuilder: (context) => [
                                          PopupMenuItem(
                                              value: 1,
                                              child: Row(children: <Widget>[
                                                Icon(Icons.accessibility),
                                                Text(" Cambiar perfil")
                                              ])),
                                          PopupMenuItem(
                                              value: 2,
                                              child: Row(
                                                  children: <Widget>[Icon(Icons.school), Text(" Cambiar escuela")])),
                                          PopupMenuItem(
                                              value: 3,
                                              child: Row(children: <Widget>[
                                                Icon(Icons.power_settings_new),
                                                Text(" Cerrar sesión")
                                              ])),
                                          PopupMenuItem(
                                              value: 4,
                                              child: Row(
                                                  children: <Widget>[Icon(Icons.security), Text(" Exportar usuario")]))
                                        ],
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                      size: 35.0,
                                    ),
                                    onSelected: (value) {
                                      if (value == 1) {
                                        changeSocialProfile();
                                      } else if (value == 2) {
                                        changeSportSchool();
                                      } else if (value == 3) {
                                        _logout();
                                      } else if (value == 4) {
                                        _exportUser(snapshots.data[1]);
                                      }
                                    })
                              ]))),
                        ),
                      ),
                      body: menuGrid(context, snapshots.data[1].role),
                    );
                  } else {
                    return loadingHome();
                  }
                });
          }
        } else {
          return loadingHome();
        }
      },
    );
  }

  void _logout() async {
    deleteLoggedInUserId();
    await FirebaseAuth.instance.signOut();
    logout(context);
  }

  void changeSocialProfile() async {
    deleteChosenSocialProfile();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ChooseSocialProfile()), (Route<dynamic> route) => false);
  }

  void changeSportSchool() async {
    deleteChosenSocialProfile();
    deleteChosenSportSchool();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => ChooseSportSchool()), (Route<dynamic> route) => false);
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

  dynamic _exportUser(SocialProfile socialProfile) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: new IconTheme(data: new IconThemeData(color: Colors.green), child: Icon(Icons.thumb_up)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Center(
                    child: Text("Se va a exportar la información de tu usuario, ¿estás seguro?"),
                  )
                ],
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
            actions: <Widget>[
              FlatButton(
                color: Colors.white,
                textColor: Colors.blueAccent,
                child: Text("CANCELAR"),
                onPressed: () async {
                  Navigator.pop(context, true);
                },
              ),
              FlatButton(
                color: Colors.white,
                textColor: Colors.blueAccent,
                child: Text("ACEPTAR"),
                onPressed: () async {
                  String json = "";
                  await FirebaseFirestore.instance
                      .collection("socialProfiles")
                      .where("userAccountId", isEqualTo: socialProfile.userAccountId)
                      .get()
                      .then((value) => value.docs.forEach((element) {
                            json += element.data.toString();
                          }));
                  User user = FirebaseAuth.instance.currentUser;
                  json += "email: " + user.email;
                  Navigator.pop(context, true);
                  _dataExported(json);
                },
              ),
            ],
          );
        });
  }

  dynamic _dataExported(String json) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: new IconTheme(data: new IconThemeData(color: Colors.green), child: Icon(Icons.thumb_up)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Center(
                    child: Text(json),
                  )
                ],
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
            actions: <Widget>[
              FlatButton(
                color: Colors.white,
                textColor: Colors.blueAccent,
                child: Text("CERRAR"),
                onPressed: () async {
                  Navigator.pop(context, true);
                },
              ),
            ],
          );
        });
  }
}
