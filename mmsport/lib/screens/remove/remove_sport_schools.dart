import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemoveSportSchools extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _RemoveSportSchoolsState();
  }
}

class _RemoveSportSchoolsState extends State<StatefulWidget> {
  List<SportSchool> _sportSchools;
  List<SportSchool> _filteredSportSchools;
  TextEditingController controller = new TextEditingController();
  bool firstLoad = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<List<SportSchool>> getSchools() async {
    if (firstLoad) {
      await Firestore.instance
          .collection("sportSchools")
          .where("status", isEqualTo: "ACCEPTED")
          .getDocuments()
          .then((value) => value.documents.forEach((element) {
                SportSchool sportSchool = SportSchool.sportSchoolFromMap(element.data);
                _sportSchools.add(sportSchool);
              }));
      _filteredSportSchools.addAll(_sportSchools);
    }
    return _filteredSportSchools;
  }


  @override
  void initState() {
    super.initState();
    _sportSchools = [];
    _filteredSportSchools = [];
  }

  void onChanged(String value) {
    _filteredSportSchools.clear();
    if (value.isEmpty) {
      firstLoad = false;
      _filteredSportSchools.addAll(_sportSchools);
    } else {
      for (SportSchool s in _sportSchools) {
        if (s.name.toLowerCase().contains(value.toLowerCase()) ||
            s.address.toLowerCase().contains(value.toLowerCase()) ||
            s.town.toLowerCase().contains(value.toLowerCase()) ||
            s.province.toLowerCase().contains(value.toLowerCase())) {
          _filteredSportSchools.add(s);
        }
      }
    }
    setState(() {
      firstLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Eliminar escuelas"),
        ),
        key: _scaffoldKey,
        body: FutureBuilder(
          future: getSchools(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SafeArea(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: new Padding(
                        padding: EdgeInsets.all(8.0),
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
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            SportSchool sportSchool = snapshot.data.elementAt(index);
                            return _listItem(sportSchool);
                          }),
                    )
                  ],
                ),
              );
            } else {
              return loading();
            }
          },
        ),
      ),
    );
  }

  Widget _listItem(SportSchool sportSchool) {
    return ListTile(
      onTap: () {
        confirmDelete(context, sportSchool);
      },
      title: Text(
        sportSchool.name,
        style: TextStyle(fontSize: 20.0),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        sportSchool.town + " " + sportSchool.province,
        style: TextStyle(fontSize: 20.0),
      ),
      leading: sportSchool.urlLogo != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(sportSchool.urlLogo),
              radius: 24.0,
            )
          : CircleAvatar(
              radius: 24,
              child: ClipOval(
                  child: Icon(
                Icons.location_city,
                size: 44,
              ))),
    );
  }

  dynamic confirmDelete(BuildContext context, SportSchool sportSchool) {
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
                    ListBody(children: <Widget>[Center(child: Text("Se va a eliminar esta escuela, ¿estás seguro?"))])),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
            actions: <Widget>[
              FlatButton(
                color: Colors.white,
                textColor: Colors.blueAccent,
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
              FlatButton(
                color: Colors.white,
                textColor: Colors.blueAccent,
                onPressed: () async {
                  setState(() {
                    firstLoad = false;
                  });
                  Navigator.of(context, rootNavigator: true).pop();
                  loadingDialog(context);
                  // Profiles
                  List<String> profilesToDelete = [];
                  await Firestore.instance
                      .collection("socialProfiles")
                      .where("sportSchoolId", isEqualTo: sportSchool.id)
                      .getDocuments()
                      .then((value) => value.documents.forEach((element) {
                            profilesToDelete.add(element.data['id']);
                          }));
                  for (String id in profilesToDelete) {
                    // Chats
                    await Firestore.instance
                        .collection("chatRooms")
                        .where("users", arrayContains: id)
                        .getDocuments()
                        .then((value) => value.documents.forEach((element) {
                              Firestore.instance.collection("chatRooms").document(element.documentID).delete();
                            }));
                    await Firestore.instance.collection("socialProfiles").document(id).delete();
                  }
                  // Groups
                  await Firestore.instance
                      .collection("groups")
                      .where("sportSchoolId", isEqualTo: sportSchool.id)
                      .getDocuments()
                      .then((value) => value.documents.forEach((element) {
                            Firestore.instance.collection("groups").document(element.documentID).delete();
                          }));
                  // Events
                  await Firestore.instance
                      .collection("events")
                      .where("sportSchoolId", isEqualTo: sportSchool.id)
                      .getDocuments()
                      .then((value) => value.documents.forEach((element) {
                            Firestore.instance.collection("events").document(element.documentID).delete();
                          }));
                  // Logo
                  StorageReference ref = await FirebaseStorage.instance.getReferenceFromUrl(sportSchool.urlLogo);
                  await ref.delete();
                  // School
                  await Firestore.instance.collection("sportSchools").document(sportSchool.id).delete();
                  setState(() {
                    for (int i = 0; i < _sportSchools.length; i++) {
                      if (_sportSchools[i].id == sportSchool.id) {
                        _sportSchools.removeAt(i);
                        break;
                      }
                    }
                    for (int i = 0; i < _filteredSportSchools.length; i++) {
                      if (_filteredSportSchools[i].id == sportSchool.id) {
                        _filteredSportSchools.removeAt(i);
                        break;
                      }
                    }
                  });
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Text("ENTENDIDO", style: TextStyle(color: Colors.red),),
              )
            ],
          );
        });
  }
}
