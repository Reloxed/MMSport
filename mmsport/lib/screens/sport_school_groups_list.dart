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
    Map profileLogged = await jsonDecode(preferences.get("chosenSocialProfile"));
    SocialProfile logged = SocialProfile.socialProfileFromMap(profileLogged);
    List<Group> allGroups = new List();
    if (logged.role == 'DIRECTOR') {
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
    } else if (logged.role == 'TRAINER') {
      await Firestore.instance
          .collection("groups")
          .where('sportSchoolId', isEqualTo: _sportSchool.id)
          .where('trainerId', isEqualTo: logged.id)
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
            appBar: AppBar(
              title: Text("Mis grupos"),
              centerTitle: true,
            ),
            body: snapshots.data[0].length > 0
                ? Container(
                    child: ListView.builder(
                    itemBuilder: (context, index) {
                      if (snapshots.data[0].values.elementAt(index).secondSurname == null) {
                        return ListTile(
                            onTap: () {
                              setSportSchoolGroupToView(snapshots.data[0].keys.elementAt(index));
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) => SportSchoolGroupDetails()))
                                  .then((value) => setState(() {}));
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
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) => SportSchoolGroupDetails()))
                                  .then((value) => setState(() {}));
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
                  ))
                : Container(
                    child: Center(
                      child: Text("No se encontraron grupos", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    ),
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: null,
              tooltip: 'Inscribirme en una escuela',
              child: IconButton(
                onPressed: () => navigateToCreateSportSchoolGroup(context).then((value) {
                  setState(() {

                  });
                }),
                icon: new IconTheme(
                    data: new IconThemeData(
                      color: Colors.white,
                    ),
                    child: Icon(Icons.add)),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    ));
  }
}
