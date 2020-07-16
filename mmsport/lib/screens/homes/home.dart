import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'file:///F:/Universidad/MMSPORT/mmsport/lib/screens/homes/menu_helper.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Home();
  }
}

class _Home extends State<Home> {
  SportSchool chosenSportSchool;
  SocialProfile chosenSocialProfile;

  Future<Null> _loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux1 = await jsonDecode(preferences.get("chosenSportSchool"));
    Map aux2 = await jsonDecode(preferences.get("chosenSocialProfile"));
    setState(() {
      chosenSportSchool = SportSchool.sportSchoolFromMap(aux1);
      chosenSocialProfile = SocialProfile.socialProfileFromMap(aux2);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadData(),
        builder: (BuildContext context, AsyncSnapshot<Null> snapshot) {
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
                            CircleAvatar(radius: 40, backgroundImage: NetworkImage(chosenSportSchool.urlLogo)),
                            Container(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(chosenSportSchool.name, style: TextStyle(color: Colors.white, fontSize: 30)),
                                      Text(
                                          chosenSocialProfile.name +
                                              " " +
                                              chosenSocialProfile.firstSurname +
                                              " " +
                                              chosenSocialProfile.secondSurname,
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
            body: menuGrid(context, chosenSocialProfile.role),
          );
        });
  }


}
