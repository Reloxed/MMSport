import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/constants/constants.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:mmsport/navigations/navigations.dart';
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

  Future<SportSchool> _loadSportSchool() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = await jsonDecode(preferences.get("chosenSportSchool"));
    chosenSportSchool = SportSchool.sportSchoolFromMap(aux);
    return chosenSportSchool;
  }

  Future<SocialProfile> _loadSocialProfile() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = await jsonDecode(preferences.get("chosenSocialProfile"));
    if(aux['role'] == "ADMIN"){
      chosenSocialProfile.role = "ADMIN";
    } else {
      chosenSocialProfile = SocialProfile.socialProfileFromMap(aux);
      chosenSocialProfile.id = aux['id'];
    }
    return chosenSocialProfile;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                        snapshots.data[1].role == "ADMIN"
                            ? Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                                CircleAvatar(radius: 40, backgroundImage: NetworkImage(snapshots.data[1].urlImage)),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.58,
                                    child: Container(
                                        padding: EdgeInsets.all(10.0),
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                snapshots.data[1].role,
                                                style: TextStyle(color: Colors.white, fontSize: 30),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                              ),
                                            ]))),
                              ])
                            : Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                                CircleAvatar(radius: 40, backgroundImage: NetworkImage(snapshots.data[0].urlLogo)),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.58,
                                    child: Container(
                                        padding: EdgeInsets.all(10.0),
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                snapshots.data[0].name,
                                                style: TextStyle(color: Colors.white, fontSize: 30),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                              ),
                                              snapshots.data[1].secondSurname != null ?
                                              Text(
                                                  snapshots.data[1].name +
                                                      " " +
                                                      snapshots.data[1].firstSurname +
                                                      " " +
                                                      snapshots.data[1].secondSurname,
                                                  style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                                                  overflow: TextOverflow.ellipsis,
                                                  softWrap: true):
                                              Text(
                                                  snapshots.data[1].name +
                                                      " " +
                                                      snapshots.data[1].firstSurname,
                                                  style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                                                  overflow: TextOverflow.ellipsis,
                                                  softWrap: true)
                                            ]))),
                              ]),
                        PopupMenuButton<int>(
                            itemBuilder: (context) => [
                                  PopupMenuItem(
                                      value: 1,
                                      child:
                                          Row(children: <Widget>[Icon(Icons.accessibility), Text(" Cambiar perfil")])),
                                  PopupMenuItem(
                                      value: 2,
                                      child: Row(children: <Widget>[Icon(Icons.school), Text(" Cambiar escuela")])),
                                  PopupMenuItem(
                                      value: 3,
                                      child: Row(
                                          children: <Widget>[Icon(Icons.power_settings_new), Text(" Cerrar sesión")]))
                                ],
                            icon: Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 35.0,
                            ),
                            onSelected: (value) {
                              if (value == 1) {
                                // TODO: Cambiar escuela
                              } else if (value == 2) {
                                // TODO: Cambiar perfil
                              } else if (value == 3) {
                                _logout();
                              }
                            })
                      ]))),
                ),
              ),
              body: menuGrid(context, snapshots.data[1].role),
            );
          } else {
            return Container();
          }
        });
  }

  void _logout() async {
    deleteLoggedInUserId();
    await FirebaseAuth.instance.signOut();
    logout(context);
  }
}
