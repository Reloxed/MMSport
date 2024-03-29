import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:mmsport/components/dialogs.dart';

class AcceptRejectSchools extends StatefulWidget {
  @override
  State createState() {
    return new _AcceptRejectSchoolsState();
  }
}

class _AcceptRejectSchoolsState extends State<AcceptRejectSchools> {
  Map<SportSchool, SocialProfile> schoolsPending = new Map();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<Map<SportSchool, SocialProfile>> getSchoolsAndDirectorsPending() async {
    List<SportSchool> sportSchools = [];
    await FirebaseFirestore.instance
        .collection("sportSchools")
        .where("status", isEqualTo: "PENDING")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        SportSchool sportSchoolAux = SportSchool.sportSchoolFromMap(element.data());
        sportSchoolAux.id = element.data()['id'];
        sportSchools.add(sportSchoolAux);
      });
    });
    for(SportSchool school in sportSchools){
      await FirebaseFirestore.instance
          .collection("socialProfiles")
          .where("sportSchoolId", isEqualTo: school.id)
          .where("role", isEqualTo: "DIRECTOR")
          .get()
          .then((value) {
        SocialProfile auxProfile = SocialProfile.socialProfileFromMap(value.docs[0].data());
        auxProfile.id = value.docs[0].data()['id'];
        schoolsPending.putIfAbsent(school, () => auxProfile);
      });
    }
    return schoolsPending;
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
          title: Text("Escuelas pendientes"),
        ),
        body: FutureBuilder(
          future: getSchoolsAndDirectorsPending(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    if (snapshot.hasData) {
                      return _listSchool(snapshot.data.keys.elementAt(index), snapshot.data.values.elementAt(index));
                    } else {
                      return Container(
                        child: Center(
                          child: Text("No hay escuelas para aceptar/rechazar"),
                        ),
                      );
                    }
                  });
            } else {
              return loading();
            }
          },
        ),
      ),
    );
  }

  Widget _listSchool(SportSchool sportSchool, SocialProfile socialProfile) {
    return Container(
      color: Colors.black12,
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              backgroundImage: NetworkImage(sportSchool.urlLogo),
              radius: 30,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("Nombre: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(sportSchool.name, style: TextStyle(fontSize: 15))
                ],
              ),
              Row(
                children: <Widget>[
                  Text("Dirección: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(sportSchool.address + " ", style: TextStyle(fontSize: 15))
                ],
              ),
              Row(
                children: <Widget>[
                  Text("Provincia: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(sportSchool.province + " ", style: TextStyle(fontSize: 15))
                ],
              ),
              Row(
                children: <Widget>[
                  Text("Municipio: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(sportSchool.town + " ", style: TextStyle(fontSize: 15))
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              backgroundImage: NetworkImage(socialProfile.urlImage),
              radius: 30,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text("Nombre: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(socialProfile.name, style: TextStyle(fontSize: 15))
                ],
              ),
              Row(
                children: <Widget>[
                  Text("Apellidos: ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(socialProfile.firstSurname + " ", style: TextStyle(fontSize: 15)),
                  socialProfile.secondSurname != null
                      ? Text(socialProfile.secondSurname + " ", style: TextStyle(fontSize: 15))
                      : Text("")
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
                  acceptProfileDialog(context, sportSchool, socialProfile);
                },
              ),
              IconButton(
                icon: Icon(Icons.thumb_down),
                onPressed: () {
                  rejectProfileDialog(context, sportSchool, socialProfile);
                },
              )
            ],
          )
        ],
      ),
    );
  }

  dynamic acceptProfileDialog(BuildContext context, SportSchool sportSchool, SocialProfile socialProfile) {
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
                    child: Text("Se va a aceptar la escuela y su director, ¿estás seguro?"),
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
                  Map<String, dynamic> aux = new Map();
                  aux.putIfAbsent("status", () => "ACCEPTED");
                  await FirebaseFirestore.instance
                      .collection("sportSchools")
                      .doc(sportSchool.id)
                      .set(aux, SetOptions(merge: true));
                  await FirebaseFirestore.instance
                      .collection("socialProfiles")
                      .doc(socialProfile.id)
                      .set(aux, SetOptions(merge: true));
                  Navigator.pop(context, true);
                  setState(() {
                    schoolsPending.clear();
                  });
                },
              )
            ],
          );
        });
  }

  dynamic rejectProfileDialog(BuildContext context, SportSchool sportSchool, SocialProfile socialProfile) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: new IconTheme(data: new IconThemeData(color: Colors.red), child: Icon(Icons.thumb_down)),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Center(
                    child: Text("Se va a rechazar la escuela y su director, ¿estás seguro?"),
                  )
                ],
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
            actions: <Widget>[
              FlatButton(
                color: Colors.white,
                textColor: Colors.blueAccent,
                child: Text("Cancelar"),
                onPressed: () async {
                  Navigator.pop(context, true);
                },
              ),
              FlatButton(
                color: Colors.white,
                textColor: Colors.blueAccent,
                child: Text("RECHAZAR", style: TextStyle(color: Colors.red),),
                onPressed: () async {
                  await FirebaseFirestore.instance.collection("sportSchools").doc(sportSchool.id).delete();
                  await FirebaseFirestore.instance.collection("socialProfiles").doc(socialProfile.id).delete();
                  Navigator.pop(context, true);
                  setState(() {
                    schoolsPending.clear();
                  });
                },
              )
            ],
          );
        });
  }
}
