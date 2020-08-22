import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/models/event.dart';
import 'package:mmsport/models/group.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:mmsport/navigations/navigations.dart';
import 'package:shared_preferences/shared_preferences.dart';

dynamic errorDialog(BuildContext context, String message) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext builder) {
        return AlertDialog(
          title: new IconTheme(
            data: new IconThemeData(
              color: Colors.red,
            ),
            child: Icon(Icons.error),
          ),
          content: SingleChildScrollView(child: ListBody(children: <Widget>[Center(child: Text(message))])),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
          actions: <Widget>[
            FlatButton(
              color: Colors.white,
              textColor: Colors.blueAccent,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("Entendido"),
            )
          ],
        );
      });
}

dynamic acceptDialogRegister(BuildContext context, String message) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext builder) {
        return AlertDialog(
          title: new IconTheme(
            data: new IconThemeData(
              color: Colors.green,
            ),
            child: Icon(Icons.thumb_up),
          ),
          content: SingleChildScrollView(child: ListBody(children: <Widget>[Center(child: Text(message))])),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
          actions: <Widget>[
            FlatButton(
              color: Colors.white,
              textColor: Colors.blueAccent,
              onPressed: () {
                logout(context);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("Entendido"),
            )
          ],
        );
      });
}

// Muestra un dialog con el loading, usado en los momentos que se guardan datos en la BBDD
dynamic loadingDialog(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext builder) {
        return AlertDialog(
          title: Image.asset("assets/logo/loading_gif.gif"),
          content: Text("Un momento, por favor...", style: TextStyle(fontSize: 20)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
        );
      });
}

// Muestra el loading directamente en la pantalla, por ejemplo dentro de un scaffold
dynamic loading() {
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset("assets/logo/loading_gif.gif"),
        Text("Un momento, por favor...", style: TextStyle(fontSize: 20))
      ],
    ),
  );
}

// Muestra una pantalla completa de loading, se usa en el home
dynamic loadingHome() {
  return Scaffold(
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset("assets/logo/loading_gif.gif"),
          Text("Un momento, por favor...", style: TextStyle(fontSize: 20))
        ],
      ),
    ),
  );
}

dynamic confirmDialogOnCreateSchool(BuildContext context, String message) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext builder) {
        return AlertDialog(
          title: new IconTheme(
            data: new IconThemeData(
              color: Colors.green,
            ),
            child: Icon(Icons.check),
          ),
          content: SingleChildScrollView(child: ListBody(children: <Widget>[Center(child: Text(message))])),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
          actions: <Widget>[
            FlatButton(
              color: Colors.white,
              textColor: Colors.blueAccent,
              onPressed: () {
                logout(context);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("Entendido"),
            )
          ],
        );
      });
}

Future<Void> confirmDialogOnDeleteEvent(BuildContext context, String message, Event event) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext builder) {
        return AlertDialog(
          title: new IconTheme(
            data: new IconThemeData(
              color: Colors.green,
            ),
            child: Icon(Icons.check),
          ),
          content: SingleChildScrollView(child: ListBody(children: <Widget>[Center(child: Text(message))])),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
          actions: <Widget>[
            FlatButton(
              color: Colors.white,
              textColor: Colors.blueAccent,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("No"),
            ),
            FlatButton(
              color: Colors.white,
              textColor: Colors.blueAccent,
              onPressed: () async {
                final databaseReference = Firestore.instance;
                await databaseReference
                    .collection("events")
                    .document(event.id)
                    .delete()
                    .then((value) => Navigator.of(context, rootNavigator: true).pop());
              },
              child: Text("Sí"),
            )
          ],
        );
      });
}

Future<bool> confirmDialogOnDeleteGroup(BuildContext context, String message, Group groupEdited) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext builder) {
        return AlertDialog(
          title: new IconTheme(
            data: new IconThemeData(
              color: Colors.green,
            ),
            child: Icon(Icons.check),
          ),
          content: SingleChildScrollView(child: ListBody(children: <Widget>[Center(child: Text(message))])),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
          actions: <Widget>[
            FlatButton(
              color: Colors.white,
              textColor: Colors.blueAccent,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text("NO"),
            ),
            FlatButton(
              color: Colors.white,
              textColor: Colors.blueAccent,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(true);
              },
              child: Text("SÍ"),
            )
          ],
        );
      });
}

class AddStudentsToGroupDialog extends StatefulWidget {
  final List<SocialProfile> studentsEdited;

  AddStudentsToGroupDialog({Key key, @required this.studentsEdited}) : super(key: key);

  @override
  AddStudentsToGroupDialogState createState() => new AddStudentsToGroupDialogState(studentsEdited);
}

class AddStudentsToGroupDialogState extends State<AddStudentsToGroupDialog> {
  List<SocialProfile> studentsToEnroll;
  List<SocialProfile> studentsFiltered;
  List<SocialProfile> studentsEdited;
  bool firstLoad;

  TextEditingController controller = new TextEditingController();

  AddStudentsToGroupDialogState(List<SocialProfile> studentsEdited) {
    this.studentsEdited = studentsEdited;
  }

  @override
  void initState() {
    super.initState();
    firstLoad = true;
    studentsToEnroll = [];
    studentsFiltered = [];
  }

  Future<List<SocialProfile>> loadStudentsToJoin() async {
    if (firstLoad) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      Map aux = jsonDecode(preferences.get("chosenSportSchool"));
      SportSchool sportSchool = SportSchool.sportSchoolFromMap(aux);
      await Firestore.instance
          .collection("socialProfiles")
          .where('role', isEqualTo: 'STUDENT')
          .where('sportSchoolId', isEqualTo: sportSchool.id)
          .getDocuments()
          .then((value) {
        value.documents.forEach((element) {
          SocialProfile newStudent = SocialProfile.socialProfileFromMap(element.data);
          newStudent.id = element.data['id'];
          SocialProfile first;
          first = studentsEdited.firstWhere((student) => student.id == newStudent.id, orElse: () => null);
          if (first == null) {
            studentsToEnroll.add(newStudent);
          }
        });
      });
      studentsFiltered.addAll(studentsToEnroll);
    }
    return studentsFiltered;
  }

  onSearchTextChanged(String text) {
    studentsFiltered.clear();
    if (text.isEmpty) {
      setState(() {
        firstLoad = false;
        studentsFiltered.addAll(studentsToEnroll);
      });
      return;
    }

    studentsToEnroll.forEach((element) {
      if (element.name.toLowerCase().contains(text.toLowerCase()) ||
          element.firstSurname.toLowerCase().contains(text.toLowerCase()) ||
          element.secondSurname.toLowerCase().contains(text.toLowerCase())) {
        studentsFiltered.add(element);
      }
    });

    setState(() {
      firstLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: FutureBuilder<List<SocialProfile>>(
            future: loadStudentsToJoin(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Scaffold(
                    appBar: new AppBar(
                      title: const Text('Añada los alumnos'),
                      actions: [
                        new IconButton(
                          onPressed: () {
                            Navigator.of(context).pop(studentsEdited);
                          },
                          icon: Icon(Icons.check),
                          color: Colors.white,
                        )
                      ],
                    ),
                    body: Center(
                      child: SafeArea(
                        child: Column(
                          children: <Widget>[
                            Container(
                                child: new Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Card(
                                      child: ListTile(
                                        leading: new Icon(Icons.search),
                                        title: new TextField(
                                          controller: controller,
                                          decoration: new InputDecoration(hintText: 'Buscar', border: InputBorder.none),
                                          onChanged: onSearchTextChanged,
                                        ),
                                        trailing: new IconButton(
                                          icon: new Icon(Icons.cancel),
                                          onPressed: () {
                                            controller.clear();
                                            onSearchTextChanged('');
                                          },
                                        ),
                                      ),
                                    ))),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) {
                                    return CheckboxListTile(
                                        selected: studentsEdited.contains(snapshot.data[index]),
                                        value: studentsEdited.contains(snapshot.data[index]),
                                        onChanged: (bool value) {
                                          if (value) {
                                            setState(() {
                                              firstLoad = false;
                                              studentsEdited.add(snapshot.data[index]);
                                            });
                                          } else {
                                            setState(() {
                                              firstLoad = false;
                                              studentsEdited.remove(snapshot.data[index]);
                                            });
                                          }
                                        },
                                        title: snapshot.data[index].secondSurname == null
                                            ? Text(
                                                snapshot.data[index].name + " " + snapshot.data[index].firstSurname,
                                                style: TextStyle(fontSize: 16.0),
                                              )
                                            : Text(
                                                snapshot.data[index].name +
                                                    " " +
                                                    snapshot.data[index].firstSurname +
                                                    " " +
                                                    snapshot.data[index].secondSurname,
                                                style: TextStyle(fontSize: 16.0),
                                              ),
                                        secondary: snapshot.data[index].urlImage != null
                                            ? CircleAvatar(
                                                radius: 20,
                                                child: ClipOval(
                                                  child: Image.network(
                                                    snapshot.data[index].urlImage,
                                                    fit: BoxFit.cover,
                                                    width: 92,
                                                    height: 92,
                                                  ),
                                                ))
                                            : CircleAvatar(
                                                radius: 20,
                                                child: ClipOval(
                                                    child: Icon(
                                                  Icons.person,
                                                  size: 24,
                                                ))));
                                  }),
                            )
                          ],
                        ),
                      ),
                    ));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }
}

class SelectTrainerGroupDialog extends StatefulWidget {
  final SocialProfile trainerSelected;

  SelectTrainerGroupDialog({Key key, @required this.trainerSelected}) : super(key: key);

  @override
  SelectTrainerGroupDialogState createState() => new SelectTrainerGroupDialogState(trainerSelected);
}

class SelectTrainerGroupDialogState extends State<SelectTrainerGroupDialog> {
  List<SocialProfile> groupTrainers = [];
  SocialProfile trainerSelected;
  bool firstLoad = true;

  SelectTrainerGroupDialogState(SocialProfile trainerSelected) {
    this.trainerSelected = trainerSelected;
  }

  @override
  void initState() {
    super.initState();
  }

  Future<List<SocialProfile>> loadTrainers() async {
    if (firstLoad) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      Map aux = jsonDecode(preferences.get("chosenSportSchool"));
      SportSchool sportSchool = SportSchool.sportSchoolFromMap(aux);
      Map auxDirector = jsonDecode(preferences.get("chosenSocialProfile"));
      SocialProfile director = SocialProfile.socialProfileFromMap(auxDirector);
      director.id = auxDirector["id"];
      await Firestore.instance
          .collection("socialProfiles")
          .where('role', isEqualTo: 'TRAINER')
          .where('status', isEqualTo: 'ACCEPTED')
          .where('sportSchoolId', isEqualTo: sportSchool.id)
          .getDocuments()
          .then((value) {
        value.documents.forEach((element) {
          SocialProfile newTrainer = SocialProfile.socialProfileFromMap(element.data);
          newTrainer.id = element.data['id'];
          if (trainerSelected != null) {
            if (trainerSelected.id == newTrainer.id) {
              trainerSelected = newTrainer;
            }
          }
          groupTrainers.add(newTrainer);
        });
        groupTrainers.add(director);
      });
    }
    return groupTrainers;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: FutureBuilder<List<SocialProfile>>(
            future: loadTrainers(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Scaffold(
                    appBar: new AppBar(
                      title: const Text('Seleccione al entrenador'),
                      actions: [
                        new IconButton(
                          onPressed: () {
                            Navigator.of(context).pop(trainerSelected);
                          },
                          icon: Icon(Icons.check),
                          color: Colors.white,
                        )
                      ],
                    ),
                    body: Center(
                      child: SafeArea(
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (context, index) {
                                    return RadioListTile<SocialProfile>(
                                      value: snapshot.data[index],
                                      groupValue: trainerSelected,
                                      selected: identical(trainerSelected, snapshot.data[index]),
                                      onChanged: (SocialProfile value) {
                                        setState(() {
                                          firstLoad = false;
                                          trainerSelected = value;
                                        });
                                      },
                                      title: snapshot.data[index].secondSurname == null
                                          ? Text(
                                              snapshot.data[index].name + " " + snapshot.data[index].firstSurname,
                                              style: TextStyle(fontSize: 16.0),
                                            )
                                          : Text(
                                              snapshot.data[index].name +
                                                  " " +
                                                  snapshot.data[index].firstSurname +
                                                  " " +
                                                  snapshot.data[index].secondSurname,
                                              style: TextStyle(fontSize: 16.0),
                                            ),
                                      secondary: snapshot.data[index].urlImage != null
                                          ? CircleAvatar(
                                              radius: 20,
                                              child: ClipOval(
                                                child: Image.network(
                                                  snapshot.data[index].urlImage,
                                                  fit: BoxFit.cover,
                                                  width: 92,
                                                  height: 92,
                                                ),
                                              ))
                                          : CircleAvatar(
                                              radius: 20,
                                              child: ClipOval(
                                                  child: Icon(
                                                Icons.person,
                                                size: 24,
                                              ))),
                                    );
                                  }),
                            )
                          ],
                        ),
                      ),
                    ));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }
}
