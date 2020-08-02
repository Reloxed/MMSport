import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AcceptRejectProfiles extends StatefulWidget {
  @override
  State createState() {
    return new _AcceptRejectProfilesState();
  }
}

class _AcceptRejectProfilesState extends State<AcceptRejectProfiles> {
  SocialProfile chosenSocialProfile;
  List<SocialProfile> profilesPending = new List();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<List<SocialProfile>> getProfiles() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = await jsonDecode(preferences.get("chosenSocialProfile"));
    chosenSocialProfile = SocialProfile.socialProfileFromMap(aux);
    chosenSocialProfile.id = aux['id'];
    profilesPending.clear();
    await Firestore.instance.collection("socialProfiles")
        .where("sportSchoolId", isEqualTo: chosenSocialProfile.sportSchoolId)
        .where("status", isEqualTo: "PENDING").snapshots().listen((event) =>
        event.documents.forEach((element) {
          SocialProfile auxProfile = SocialProfile.socialProfileFromMap(element.data);
          auxProfile.id = element.data['id'];
          profilesPending.add(auxProfile);
        }));
    return profilesPending;
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Perfiles pendientes"),
        ),
        body: FutureBuilder(
          future: getProfiles(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    if(snapshot.hasData) {
                      return _listProfile(snapshot.data[index]);
                    } else {
                      return Container(
                        child: Center(
                          child: Text("No hay perfiles para aceptar/rechazar"),
                        ),
                      );
                    }
                  });
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Widget _listProfile(SocialProfile profile) {
    return Container(
      color: Colors.black12,
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              backgroundImage: NetworkImage(profile.urlImage),
              radius: 30,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("Nombre: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(profile.name, style: TextStyle(fontSize: 15))
                ],
              ),
              Row(
                children: <Widget>[
                  Text("Apellidos: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(profile.firstSurname + " ", style: TextStyle(fontSize: 15)),
                  Text(profile.secondSurname, style: TextStyle(fontSize: 15))
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.thumb_up),
                onPressed: () {
                  acceptProfileDialog(context, profile);
                },
              ),
              IconButton(
                icon: Icon(Icons.thumb_down),
                onPressed: () {
                  rejectProfileDialog(context, profile);
                },
              )
            ],
          )
        ],
      ),
    );
  }

  dynamic acceptProfileDialog(BuildContext context, SocialProfile profile) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: new IconTheme(data: new IconThemeData(color: Colors.green), child: Icon(Icons.thumb_up)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Center(child: Text("Se va a aceptar el perfil, ¿estás seguro?"),)
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.white,
                textColor: Colors.blueAccent,
                child: Text("Aceptar"),
                onPressed: () async {
                  Map<String, dynamic> aux = new Map();
                  aux.putIfAbsent("status", () => "ACCEPTED");
                  await Firestore.instance.collection("socialProfiles").document(profile.id).setData(aux, merge: true);
                  Navigator.pop(context, true);
                  setState(() {

                  });
                },
              )
            ],
          );
        });
  }

  dynamic rejectProfileDialog(BuildContext context, SocialProfile profile) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: new IconTheme(data: new IconThemeData(color: Colors.red), child: Icon(Icons.thumb_down)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Center(child: Text("Se va a rechazar el perfil, ¿estás seguro?"),)
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.white,
                textColor: Colors.blueAccent,
                child: Text("Rechazar"),
                onPressed: () async {
                  await Firestore.instance.collection("socialProfiles").document(profile.id).delete();
                  Navigator.pop(context, true);
                  setState(() {

                  });
                },
              )
            ],
          );
        });
  }
}