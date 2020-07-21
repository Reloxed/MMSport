import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'menu_helper.dart';
import 'package:mmsport/screens/homes/menu_helper.dart';


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
    chosenSocialProfile = SocialProfile.socialProfileFromMap(aux);
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
          if(snapshots.hasData){
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
                            CircleAvatar(radius: 40, backgroundImage: NetworkImage(snapshots.data[0].urlLogo)),
                            Container(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(snapshots.data[0].name, style: TextStyle(color: Colors.white, fontSize: 30)),
                                      Text(
                                          snapshots.data[1].name +
                                              " " +
                                              snapshots.data[1].firstSurname +
                                              " " +
                                              snapshots.data[1].secondSurname,
                                          style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))
                                    ])),
                          ]),
                          PopupMenuButton<int>(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                    value: 1,
                                    child: Row(children: <Widget>[Icon(Icons.accessibility), Text(" Cambiar perfil")])),
                                PopupMenuItem(
                                    value: 2,
                                    child: Row(children: <Widget>[Icon(Icons.school), Text(" Cambiar escuela")])),
                                PopupMenuItem(
                                    value: 3,
                                    child:
                                    Row(children: <Widget>[Icon(Icons.power_settings_new), Text(" Cerrar sesión")]))
                              ],
                              icon: Icon(Icons.more_vert, color: Colors.white, size: 35.0,),
                              onSelected: (value) {
                                if (value == 1) {
                                  // TODO: Cambiar escuela
                                } else if (value == 2) {
                                  // TODO: Cambiar perfil
                                } else if (value == 3) {
                                  // TODO: Cerrar sesión
                                }
                              })
                        ]))),
              ),
            ),
            body: menuGrid(context, snapshots.data[1].role),
          );} else {
            return CircularProgressIndicator();
          }
        });
  }


}
