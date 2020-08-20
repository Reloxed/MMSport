import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoveSocialProfiles extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _RemoveSocialProfilesState();
  }
}

class _RemoveSocialProfilesState extends State<RemoveSocialProfiles> {
  List<SocialProfile> _students = [];
  List<SocialProfile> _filteredStudents = [];
  List<SocialProfile> _trainers = [];
  List<SocialProfile> _filteredTrainers = [];
  TextEditingController controller = new TextEditingController();
  int focusedTab = 0;
  bool firstLoad = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<List<SocialProfile>> getStudents() async {
    if (firstLoad) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      Map aux = await jsonDecode(preferences.get("chosenSocialProfile"));
      SocialProfile loggedProfile = SocialProfile.socialProfileFromMap(aux);
      loggedProfile.id = aux['id'];
      await Firestore.instance
          .collection("socialProfiles")
          .where("role", isEqualTo: "STUDENT")
          .where("sportSchoolId", isEqualTo: loggedProfile.sportSchoolId)
          .getDocuments()
          .then((value) => value.documents.forEach((element) {
                SocialProfile newProfile = SocialProfile.socialProfileFromMap(element.data);
                newProfile.id = element.data['id'];
                _students.add(newProfile);
              }));
      _filteredStudents.addAll(_students);
    }
    return _filteredStudents;
  }

  Future<List<SocialProfile>> getTrainers() async {
    if (firstLoad) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      Map aux = await jsonDecode(preferences.get("chosenSocialProfile"));
      SocialProfile loggedProfile = SocialProfile.socialProfileFromMap(aux);
      loggedProfile.id = aux['id'];
      await Firestore.instance
          .collection("socialProfiles")
          .where("role", isEqualTo: "TRAINER")
          .where("sportSchoolId", isEqualTo: loggedProfile.sportSchoolId)
          .getDocuments()
          .then((value) => value.documents.forEach((element) {
                SocialProfile newProfile = SocialProfile.socialProfileFromMap(element.data);
                newProfile.id = element.data['id'];
                _trainers.add(newProfile);
              }));
      _filteredTrainers.addAll(_trainers);
    }
    return _filteredTrainers;
  }

  void onChanged(String value) {
    _filteredTrainers.clear();
    _filteredStudents.clear();
    if (value.isEmpty) {
      firstLoad = false;
      _filteredStudents.addAll(_students);
      _filteredTrainers.addAll(_trainers);
    } else {
      if (focusedTab == 0) {
        for (SocialProfile s in _students) {
          if (s.secondSurname != null) {
            if (s.name.toLowerCase().contains(value.toLowerCase()) ||
                s.firstSurname.toLowerCase().contains(value.toLowerCase()) ||
                s.secondSurname.toLowerCase().contains(value.toLowerCase())) {
              _filteredStudents.add(s);
            }
          } else {
            if (s.name.toLowerCase().contains(value.toLowerCase()) ||
                s.firstSurname.toLowerCase().contains(value.toLowerCase())) {
              _filteredStudents.add(s);
            }
          }
        }
      } else if (focusedTab == 1) {
        for (SocialProfile s in _trainers) {
          if (s.secondSurname != null) {
            if (s.name.toLowerCase().contains(value.toLowerCase()) ||
                s.firstSurname.toLowerCase().contains(value.toLowerCase()) ||
                s.secondSurname.toLowerCase().contains(value.toLowerCase())) {
              _filteredTrainers.add(s);
            }
          } else {
            if (s.name.toLowerCase().contains(value.toLowerCase()) ||
                s.firstSurname.toLowerCase().contains(value.toLowerCase())) {
              _filteredTrainers.add(s);
            }
          }
        }
      }
    }
    setState(() {
      firstLoad = false;
    });
  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
        title: new Text('Eliminar perfiles'),
        bottom: TabBar(tabs: <Widget>[
          Container(
              child: Tab(
            text: "Alumnos",
          )),
          Container(
              child: Tab(
            text: "Entrenadores",
          ))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: buildAppBar(context),
        key: _scaffoldKey,
        body: FutureBuilder<List<dynamic>>(
          future: Future.wait([getStudents(), getTrainers()]),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SafeArea(
                  child: TabBarView(
                children: <Widget>[
                  // Students
                  Column(children: <Widget>[
                    Container(
                        child: new Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: ListTile(
                                leading: new Icon(Icons.search),
                                title: new TextField(
                                  controller: controller,
                                  decoration: new InputDecoration(hintText: 'Buscar', border: InputBorder.none),
                                  onChanged: onChanged,
                                ),
                                trailing: new IconButton(
                                  icon: new Icon(Icons.cancel),
                                  onPressed: () {
                                    controller.clear();
                                    onChanged('');
                                  },
                                ),
                              ),
                            ))),
                    Expanded(
                        child: ListView.builder(
                            itemCount: snapshot.data[0].length,
                            itemBuilder: (context, index) {
                              focusedTab = 0;
                              // Students
                              SocialProfile profile = snapshot.data[0].elementAt(index);
                              return _listItem(profile);
                            }))
                  ]),
                  // Trainers
                  Column(children: <Widget>[
                    Container(
                        child: new Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: ListTile(
                                leading: new Icon(Icons.search),
                                title: new TextField(
                                  controller: controller,
                                  decoration: new InputDecoration(hintText: 'Buscar', border: InputBorder.none),
                                  onChanged: onChanged,
                                ),
                                trailing: new IconButton(
                                  icon: new Icon(Icons.cancel),
                                  onPressed: () {
                                    controller.clear();
                                    onChanged('');
                                  },
                                ),
                              ),
                            ))),
                    Expanded(
                        child: ListView.builder(
                            itemCount: snapshot.data[1].length,
                            itemBuilder: (context, index) {
                              focusedTab = 1;
                              SocialProfile profile = snapshot.data[1].elementAt(index);
                              return _listItem(profile);
                            }))
                  ])
                ],
              ));
            } else {
              return loading();
            }
          },
        ),
      ),
    ));
  }

  Widget _listItem(SocialProfile profile) {
    return ListTile(
      onTap: () {
        confirmDelete(context, profile);
      },
      title: Text(
        profile.name,
        style: TextStyle(fontSize: 20.0),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: profile.secondSurname != null
          ? Text(
              profile.firstSurname + " " + profile.secondSurname,
              style: TextStyle(fontSize: 20.0),
            )
          : Text(
              profile.firstSurname,
              style: TextStyle(fontSize: 20.0),
            ),
      leading: profile.urlImage != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(profile.urlImage),
              radius: 24.0,
            )
          : CircleAvatar(
              radius: 24,
              child: ClipOval(
                  child: Icon(
                Icons.person,
                size: 44,
              ))),
    );
  }

  dynamic confirmDelete(BuildContext context, SocialProfile profile) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext builder) {
          return AlertDialog(
            title: new IconTheme(
              data: new IconThemeData(
                color: Colors.black38,
              ),
              child: Icon(Icons.delete),
            ),
            content: SingleChildScrollView(
                child:
                    ListBody(children: <Widget>[Center(child: Text("Se va a eliminar este perfil, ¿estás seguro?"))])),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
            actions: <Widget>[
              FlatButton(
                color: Colors.white,
                textColor: Colors.blueAccent,
                onPressed: () async {
                  setState(() {
                    firstLoad = false;
                  });
                  Navigator.of(context, rootNavigator: true).pop();
                  loadingDialog(context);
                  await Firestore.instance
                      .collection("chatRooms")
                      .where("users", arrayContains: profile.id)
                      .getDocuments()
                      .then((value) => value.documents.forEach((element) {
                            Firestore.instance
                                .collection("chatRooms")
                                .document(element.documentID)
                                .collection("messages")
                                .getDocuments()
                                .then((value) => value.documents.forEach((element2) {
                                      Firestore.instance
                                          .collection("chatRooms")
                                          .document(element.documentID)
                                          .collection("messages")
                                          .document(element2.documentID)
                                          .delete();
                                    }));
                            Firestore.instance.collection("chatRooms").document(element.documentID).delete();
                          }));
                  if (profile.urlImage != null) {
                    StorageReference ref = await FirebaseStorage.instance.getReferenceFromUrl(profile.urlImage);
                    await ref.delete();
                  }
                  await Firestore.instance.collection("socialProfiles").document(profile.id).delete();
                  setState(() {
                    if (profile.role == "STUDENT") {
                      for (int i = 0; i < _students.length; i++) {
                        if (_students[i].id == profile.id) {
                          _students.removeAt(i);
                          break;
                        }
                      }
                      for (int i = 0; i < _filteredStudents.length; i++) {
                        if (_filteredStudents[i].id == profile.id) {
                          _filteredStudents.removeAt(i);
                          break;
                        }
                      }
                    } else if (profile.role == "TRAINER") {
                      for (int i = 0; i < _trainers.length; i++) {
                        if (_trainers[i].id == profile.id) {
                          _trainers.removeAt(i);
                          break;
                        }
                      }
                      for (int i = 0; i < _filteredTrainers.length; i++) {
                        if (_filteredTrainers[i].id == profile.id) {
                          _filteredTrainers.removeAt(i);
                          break;
                        }
                      }
                    }
                  });
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Text("Entendido"),
              ),
              FlatButton(
                color: Colors.white,
                textColor: Colors.blueAccent,
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              )
            ],
          );
        });
  }
}
