import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/constants/constants.dart';
import 'package:mmsport/models/group.dart';
import 'package:mmsport/models/schedule.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:mmsport/navigations/navigations.dart';
import 'package:mmsport/screens/sport_school_group_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListSportSchoolGroups extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ListSportSchoolGroupsState();
  }
}

class _ListSportSchoolGroupsState extends State<ListSportSchoolGroups> {

  Future<SportSchool> _getSportSchool() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    SportSchool sportSchool = SportSchool.sportSchoolFromMap(jsonDecode(preferences.get("chosenSportSchool")));
    return sportSchool;
  }

  Future<SocialProfile> _getSocialProfileLogued() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = jsonDecode(preferences.get("chosenSocialProfile"));
    SocialProfile socialProfile = SocialProfile.socialProfileFromMap(aux);
    socialProfile.id = aux['id'];
    return socialProfile;
  }

  // ignore: missing_return
  Future<Map<Group, SocialProfile>> _getAllGroups() async {
    Map<Group, SocialProfile> res = new Map<Group, SocialProfile>();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    SportSchool _sportSchool = SportSchool.sportSchoolFromMap(await jsonDecode(preferences.get("chosenSportSchool")));
    List<Group> allGroups = new List();
    await Firestore.instance
        .collection("groups")
        .where('sportSchoolId', isEqualTo: _sportSchool.id)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) async {
        List<Schedule> groupSchedule = [];
        element.data['schedule'].forEach((codedSchedule) {
          groupSchedule.add(Schedule.scheduleFromMap(codedSchedule));
        });
        Group newGroup = Group.groupFromMapWithIdFromFirebase(element.data, groupSchedule);
        allGroups.add(newGroup);
      });
    });
    for (Group element in allGroups) {
      await Firestore.instance.collection('socialProfiles').document(element.trainerId).get().then((document) {
        if (document.exists) {
          SocialProfile newTrainer = SocialProfile.socialProfileFromMap(document.data);
          newTrainer.id = document.documentID;
          res[element] = newTrainer;
        }
      });
    }
    return res;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: FutureBuilder<List<dynamic>>(
      future: Future.wait([_getAllGroups(), _getSocialProfileLogued(), _getSportSchool()]),
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
                          CircleAvatar(radius: 40, backgroundImage: NetworkImage(snapshots.data[2].urlLogo)),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.58,
                              child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          snapshots.data[2].name,
                                          style: TextStyle(color: Colors.white, fontSize: 30),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ),
                                        Text(
                                            snapshots.data[1].name +
                                                " " +
                                                snapshots.data[1].firstSurname +
                                                " " +
                                                snapshots.data[1].secondSurname,
                                            style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true)
                                      ]))),
                        ]),
                      ]))),
                ),
              ),
              body: Container(
                  child: ListView.builder(
                itemBuilder: (context, index) {
                  if (snapshots.data[0].values.elementAt(index).secondSurname == null) {
                    return ListTile(
                        onTap: () {
                          setSportSchoolGroupToView(snapshots.data[0].keys.elementAt(index));
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SportSchoolGroupDetails())).then((value) => setState(
                              (){}
                          ));
                        },
                        title: Text(
                          snapshots.data[0].keys.elementAt(index).name,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        subtitle: Text(
                            'Entrenador: ' +
                                snapshots.data[0].values.elementAt(index).name +
                                ' ' +
                                snapshots.data[0].values.elementAt(index).firstSurname,
                            style: TextStyle(fontSize: 16.0)));
                  } else {
                    return ListTile(
                        onTap: () {
                          setSportSchoolGroupToView(snapshots.data[0].keys.elementAt(index));
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SportSchoolGroupDetails())).then((value) => setState(
                                  (){}
                          ));
                        },
                        title: Text(
                          snapshots.data[0].keys.elementAt(index).name,
                          style: TextStyle(fontSize: 20.0),
                        ),
                        subtitle: Text(
                            'Entrenador: ' +
                                snapshots.data[0].values.elementAt(index).name +
                                ' ' +
                                snapshots.data[0].values.elementAt(index).firstSurname +
                                ' ' +
                                snapshots.data[0].values.elementAt(index).secondSurname,
                            style: TextStyle(fontSize: 16.0)));
                  }
                },
                itemCount: snapshots.data[0].length,
              )));
        } else {
          return Container();
        }
      },
    ));
  }
}
