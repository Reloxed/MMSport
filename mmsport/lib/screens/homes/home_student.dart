import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeStudent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeStudent();
  }
}

class _HomeStudent extends State<HomeStudent> {
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
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(chosenSportSchool.name),
            CircleAvatar(
              radius: 85,
              backgroundImage: NetworkImage(chosenSportSchool.urlLogo),
            ),
            Text(chosenSocialProfile.name +
                " " +
                chosenSocialProfile.firstSurname +
                " " +
                chosenSocialProfile.secondSurname),
          ],
        ),
      ],
    );
  }
}
