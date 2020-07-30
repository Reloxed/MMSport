import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/models/group.dart';
import 'package:mmsport/models/schedule.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SportSchoolGroupDetails extends StatefulWidget {
  @override
  _SportSchoolGroupDetailsState createState() {
    return new _SportSchoolGroupDetailsState();
  }
}

class _SportSchoolGroupDetailsState extends State<SportSchoolGroupDetails> {
  final _formKey = GlobalKey<FormState>();
  bool _editMode = false;

  List<SocialProfile> filteredStudents;
  TextEditingController filterController = new TextEditingController();
  String filter;

  List<String> daysOfTheWeek = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];
  String selectedDay;
  TimeOfDay selectedStartTimeSchedule = TimeOfDay.now();
  TimeOfDay selectedEndTimeSchedule = TimeOfDay.now();
  List<Schedule> schedulesEdited = [];
  Group groupEdited;
  List<SocialProfile> studentsEdited;
  SocialProfile selectedTrainerEdited;
  List<SocialProfile> studentsToEnroll;
  List<SocialProfile> studentsToEnrollSelected = [];

  @override
  void initState() {
    super.initState();
    filterController.addListener(() {
      setState(() {
        filter = filterController.text;
      });
    });
  }

  Future<List<SocialProfile>> loadTrainers() async {
    List<SocialProfile> trainers = new List();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String sportSchoolId = preferences.get("chosenSportSchool");
    await Firestore.instance
        .collection("socialProfiles")
        .where('role', isEqualTo: 'TRAINER')
        .where('sportSchoolId', isEqualTo: sportSchoolId)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) async {
        SocialProfile trainer = SocialProfile.socialProfileFromMap(element.data);
        trainer.id = element.documentID;
        trainers.add(trainer);
      });
    });
    return trainers;
  }

  Future<Group> loadGroup() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Group group = Group.groupFromMapWithId(preferences.get("chosenGroup"));
    return group;
  }

  Future<List<Schedule>> loadSchedule() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Group group = Group.groupFromMapWithId(preferences.get("chosenGroup"));
    return group.schedule;
  }

  Future<SocialProfile> loadTrainer() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Group group = Group.groupFromMapWithId(preferences.get("chosenGroup"));
    SocialProfile trainer;
    await Firestore.instance.collection("socialProfiles").document(group.trainerId).get().then((value) {
      trainer = SocialProfile.socialProfileFromMap(value.data);
    });

    return trainer;
  }

  Future<List<SocialProfile>> loadStudents() async {
    List<SocialProfile> students;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Group group = Group.groupFromMapWithId(preferences.get("chosenGroup"));
    await Firestore.instance
        .collection("socialProfiles")
        .where('role', isEqualTo: 'STUDENT')
        .where('groupId', isEqualTo: group.id)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) async {
        SocialProfile newStudent = SocialProfile.socialProfileFromMap(element.data);
        students.add(newStudent);
      });
    });

    return students;
  }

  Future<List<SocialProfile>> loadStudentsToJoin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Group group = Group.groupFromMapWithId(preferences.get("chosenGroup"));
    await Firestore.instance
        .collection("socialProfiles")
        .where('role', isEqualTo: 'STUDENT')
        .where('sportSchoolId', isEqualTo: group.sportSchoolId)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) async {
        SocialProfile newStudent = SocialProfile.socialProfileFromMap(element.data);
        SocialProfile first = studentsToEnroll.firstWhere((element) => element.id == newStudent.id);
        if (newStudent.groupId != group.id && first == null) {
          studentsToEnroll.add(newStudent);
        }
      });
    });
    filteredStudents = studentsToEnroll;

    return studentsToEnroll;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: FutureBuilder(
      future: Future.wait([loadGroup(), loadTrainer(), loadStudents(), loadSchedule()]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshots) {
        studentsToEnrollSelected = [];
        if (snapshots.hasData) {
          Group group = snapshots.data[0];
          SocialProfile groupTrainer = snapshots.data[1];
          List<SocialProfile> groupStudents = snapshots.data[2];
          List<Schedule> schedules = snapshots.data[3];
          if (_editMode) {
            groupEdited = group;
            selectedTrainerEdited = groupTrainer;
            studentsEdited = groupStudents;
            schedulesEdited = schedules;
            return Scaffold(
                body: Center(
                  child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Form(
                          key: _formKey,
                          autovalidate: false,
                          child: Column(
                            children: <Widget>[
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    _groupNameField("Nombre del grupo", groupEdited),
                                    Container(
                                      margin: const EdgeInsets.only(top: 4.0),
                                      child: selectTrainer(),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 4.0),
                                      child: ListView.builder(
                                        itemCount: schedulesEdited.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                              title: Text(
                                                schedulesEdited[index].dayOfTheWeek,
                                                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                  "De " +
                                                      schedulesEdited[index].startTimeSchedule.format(context) +
                                                      " a " +
                                                      schedulesEdited[index].endTimeSchedule.format(context),
                                                  style: TextStyle(fontSize: 16.0)),
                                              trailing: Ink(
                                                decoration: const ShapeDecoration(
                                                  color: Colors.red,
                                                  shape: BeveledRectangleBorder(),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.delete),
                                                  color: Colors.white,
                                                  onPressed: () {
                                                    setState(() {
                                                      schedulesEdited.remove(schedulesEdited[index]);
                                                    });
                                                  },
                                                ),
                                              ));
                                        },
                                      ),
                                    ),
                                    addSchedule(),
                                    Container(
                                      margin: const EdgeInsets.only(top: 4.0),
                                      child: studentsList(studentsEdited),
                                    ),
                                    addSStudentsButton(),
                                  ],
                                ),
                              ),
                            ],
                          ))),
                ),
                floatingActionButton: SpeedDial(
                  curve: Curves.bounceIn,
                  animatedIcon: AnimatedIcons.menu_close,
                  animatedIconTheme: IconThemeData(size: 22.0),
                  children: [
                    SpeedDialChild(
                        onTap: () async {
                          editGroup();
                          setState(() {
                            _editMode = false;
                          });
                        },
                        child: Icon(
                          Icons.save,
                          color: Colors.white,
                        ),
                        label: 'Guardar',
                        backgroundColor: Colors.blueAccent),
                    SpeedDialChild(
                        onTap: () {
                          setState(() {
                            _editMode = false;
                          });
                        },
                        child: Icon(
                          Icons.clear,
                          color: Colors.white,
                        ),
                        label: 'Cancelar',
                        backgroundColor: Colors.red),
                  ],
                ));
          } else {
            return Scaffold(
              body: Center(
                  child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Center(
                    child: Column(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(group.name, style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold)),
                        Container(
                          margin: const EdgeInsets.only(top: 4.0),
                          child: Column(children: <Widget>[
                            CircleAvatar(
                              radius: 56,
                              backgroundImage: NetworkImage(groupTrainer.urlImage),
                            ),
                            Text(
                              groupTrainer.name + " " + groupTrainer.firstSurname + " " + groupTrainer.secondSurname,
                              style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                            )
                          ]),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4.0),
                          child: ListView.builder(
                            itemCount: schedules.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  schedules[index].dayOfTheWeek,
                                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                    "De " +
                                        schedules[index].startTimeSchedule.format(context) +
                                        " a " +
                                        schedules[index].endTimeSchedule.format(context),
                                    style: TextStyle(fontSize: 16.0)),
                              );
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4.0),
                          child: studentsList(groupStudents),
                        ),
                      ],
                    ),
                  ],
                )),
              )),
              floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _editMode = true;
                    });
                  },
                  tooltip: 'Editar',
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  )),
            );
          }
        } else {
          return Container();
        }
      },
    ));
  }

  Widget studentsList(List<SocialProfile> students) {
    if (_editMode) {
      if (students.length == 0) {
        return Center(
          child: Text("No hay ningún alumno en este grupo", style: TextStyle(fontSize: 24.0)),
        );
      } else {
        return ListView.builder(
          itemCount: students.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (students[index].urlImage != null) {
              return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(students[index].urlImage),
                    radius: 16.0,
                  ),
                  title: Text(
                    students[index].name,
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(students[index].firstSurname + " " + students[index].secondSurname,
                      style: TextStyle(fontSize: 16.0)),
                  trailing: Ink(
                    decoration: const ShapeDecoration(
                      color: Colors.red,
                      shape: BeveledRectangleBorder(),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          students.remove(students[index]);
                        });
                      },
                    ),
                  ));
            } else {
              return ListTile(
                  leading: CircleAvatar(
                    //TODO
                    child: Icon(Icons.account_circle),
                    radius: 16.0,
                  ),
                  title: Text(
                    students[index].name,
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(students[index].firstSurname + " " + students[index].secondSurname,
                      style: TextStyle(fontSize: 16.0)),
                  trailing: Ink(
                    decoration: const ShapeDecoration(
                      color: Colors.red,
                      shape: BeveledRectangleBorder(),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          students.remove(students[index]);
                        });
                      },
                    ),
                  ));
            }
          },
        );
      }
    } else {
      if (students.length == 0) {
        return Center(
          child: Text("No hay ningún alumno en este grupo", style: TextStyle(fontSize: 24.0)),
        );
      } else {
        return ListView.builder(
          itemCount: students.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (students[index].urlImage != null) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(students[index].urlImage),
                  radius: 16.0,
                ),
                title: Text(
                  students[index].name,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(students[index].firstSurname + " " + students[index].secondSurname,
                    style: TextStyle(fontSize: 16.0)),
              );
            } else {
              return ListTile(
                leading: CircleAvatar(
                  //TODO
                  child: Icon(Icons.account_circle),
                  radius: 16.0,
                ),
                title: Text(
                  students[index].name,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(students[index].firstSurname + " " + students[index].secondSurname,
                    style: TextStyle(fontSize: 16.0)),
              );
            }
          },
        );
      }
    }
  }

  Widget _groupNameField(String hintText, Group group) {
    IconData icon;
    icon = Icons.group;
    return Container(
      child: Column(
        children: <Widget>[
          TextFormField(
            initialValue: groupEdited.name,
            validator: (v) {
              if (v.isEmpty)
                return "Este campo no puede estar vacío";
              else
                return null;
            },
            obscureText: false,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: hintText, prefixIcon: Icon(icon)),
            onChanged: (value) => groupEdited.name = value,
          )
        ],
      ),
    );
  }

  Widget selectTrainer() {
    if (selectedTrainerEdited != null) {
      return Column(children: <Widget>[
        CircleAvatar(
          radius: 56,
          backgroundImage: NetworkImage(selectedTrainerEdited.urlImage),
        ),
        Text(
          selectedTrainerEdited.name +
              " " +
              selectedTrainerEdited.firstSurname +
              " " +
              selectedTrainerEdited.secondSurname,
          style: TextStyle(fontSize: 16, color: Colors.blueAccent),
        ),
        RaisedButton(
          onPressed: () => {selectTrainerList()},
          elevation: 3.0,
          color: Colors.blueAccent,
          child: Text(
            "CAMBIAR ENTRENADOR",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        )
      ]);
    } else {
      return RaisedButton(
        onPressed: () => {selectTrainerList()},
        elevation: 3.0,
        color: Colors.blueAccent,
        child: Text(
          "SELECCIONAR ENTRENADOR",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      );
    }
  }

  Widget addSchedule() {
    return Container(
        margin: EdgeInsets.all(4.0),
        child: OutlineButton.icon(
          onPressed: () => showSchedulePickers(),
          icon: new IconTheme(
              data: new IconThemeData(
                color: Colors.blueAccent,
              ),
              child: Icon(Icons.add)),
          label: Text(
            'Añadir horario',
            style: TextStyle(fontSize: 20.0),
          ),
          borderSide: BorderSide(color: Colors.blueAccent, style: BorderStyle.solid, width: 2.0),
          textColor: Colors.blueAccent,
          highlightElevation: 3.0,
        ));
  }

  Widget addSStudentsButton() {
    return Container(
        margin: EdgeInsets.all(4.0),
        child: OutlineButton.icon(
          onPressed: () => showSchedulePickers(),
          icon: new IconTheme(
              data: new IconThemeData(
                color: Colors.blueAccent,
              ),
              child: Icon(Icons.add)),
          label: Text(
            'Añadir alumnos',
            style: TextStyle(fontSize: 20.0),
          ),
          borderSide: BorderSide(color: Colors.blueAccent, style: BorderStyle.solid, width: 2.0),
          textColor: Colors.blueAccent,
          highlightElevation: 3.0,
        ));
  }

  void addStudentsList() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        context: context,
        isScrollControlled: true,
        builder: (builder) {
          return FutureBuilder(
            future: loadStudentsToJoin(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length > 0) {
                  return new Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    color: Colors.transparent, //could change this to Color(0xFF737373),
                    //so you don't have to change MaterialApp canvasColor
                    child: Column(
                      children: <Widget>[
                        new Padding(
                          padding: new EdgeInsets.only(top: 20.0),
                        ),
                        new TextField(
                          decoration: new InputDecoration(
                            labelText: "Search something",
                          ),
                          controller: filterController,
                        ),
                        new Expanded(
                            child: Container(
                                decoration: new BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(25.0), topRight: const Radius.circular(25.0))),
                                child: new Center(child: ListView.builder(itemBuilder: (context, index) {
                                  if (filter.isEmpty || filter == null) {
                                    return CheckboxListTile(
                                      selected: studentsToEnrollSelected.contains(snapshot.data[index]),
                                      value: studentsToEnrollSelected.contains(snapshot.data[index]),
                                      onChanged: (bool value) {
                                        if (value) {
                                          setState(() {
                                            studentsToEnrollSelected.add(snapshot.data[index]);
                                          });
                                        } else {
                                          setState(() {
                                            studentsToEnrollSelected.remove(snapshot.data[index]);
                                          });
                                        }
                                      },
                                      title: Text(
                                        snapshot.data[index].name +
                                            " " +
                                            snapshot.data[index].firstSurname +
                                            " " +
                                            snapshot.data[index].secondSurname,
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                      secondary: CircleAvatar(
                                        backgroundImage: NetworkImage(snapshot.data[index].urlImage),
                                        radius: 16.0,
                                      ),
                                    );
                                  } else {
                                    String completedName = snapshot.data[index].name +
                                        " " +
                                        snapshot.data[index].firstSurname +
                                        " " +
                                        snapshot.data[index].secondSurname;
                                    if (completedName.toLowerCase().contains(filter)) {
                                      return CheckboxListTile(
                                        selected: studentsToEnrollSelected.contains(snapshot.data[index]),
                                        value: studentsToEnrollSelected.contains(snapshot.data[index]),
                                        onChanged: (bool value) {
                                          if (value) {
                                            setState(() {
                                              studentsToEnrollSelected.add(snapshot.data[index]);
                                            });
                                          } else {
                                            setState(() {
                                              studentsToEnrollSelected.remove(snapshot.data[index]);
                                            });
                                          }
                                        },
                                        title: Text(
                                          snapshot.data[index].name +
                                              " " +
                                              snapshot.data[index].firstSurname +
                                              " " +
                                              snapshot.data[index].secondSurname,
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                        secondary: CircleAvatar(
                                          backgroundImage: NetworkImage(snapshot.data[index].urlImage),
                                          radius: 16.0,
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  }
                                }))))
                      ],
                    ),
                  );
                } else {
                  return new Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    color: Colors.transparent, //could change this to Color(0xFF737373),
                    //so you don't have to change MaterialApp canvasColor
                    child: new Container(
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(25.0), topRight: const Radius.circular(25.0))),
                        child: Center(
                          child: Text(
                            "No hay alumnos en la escuela",
                            style: TextStyle(fontSize: 16.0),
                          ),
                        )),
                  );
                }
              } else {
                return new Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  color: Colors.transparent, //could change this to Color(0xFF737373),
                  //so you don't have to change MaterialApp canvasColor
                  child: new Container(
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(25.0), topRight: const Radius.circular(25.0))),
                      child: Center(child: CircularProgressIndicator())),
                );
              }
            },
          );
        });
  }

  void showSchedulePickers() {
    showDayOfTheWeekPicker();
  }

  void showDayOfTheWeekPicker() {
    showMaterialScrollPicker(
        buttonTextColor: Colors.blueAccent,
        context: context,
        title: "Selecciona el día",
        items: daysOfTheWeek,
        selectedItem: daysOfTheWeek[0],
        onChanged: (value) => setState(() => selectedDay = value),
        onConfirmed: () => {showStartTimeSchedulePicker()});
  }

  void showStartTimeSchedulePicker() {
    showMaterialTimePicker(
        title: "Hora inicio",
        context: context,
        selectedTime: selectedStartTimeSchedule,
        onChanged: (value) => setState(() => selectedStartTimeSchedule = value),
        onConfirmed: () => {showEndTimeSchedulePicker()});
  }

  void showEndTimeSchedulePicker() {
    showMaterialTimePicker(
        title: "Hora fin",
        context: context,
        selectedTime: selectedEndTimeSchedule,
        onChanged: (value) => setState(() => selectedEndTimeSchedule = value),
        onConfirmed: () => {addNewSchedule()});
  }

  void addNewSchedule() {
    if (fromTimeOfDayToDouble(selectedStartTimeSchedule) > fromTimeOfDayToDouble(selectedEndTimeSchedule)) {
      String message = "Horario erróneo";
      setState(() {
        errorDialog(context, message);
      });
    } else {
      Schedule newSchedule = new Schedule(selectedDay, selectedStartTimeSchedule, selectedEndTimeSchedule);
      setState(() {
        schedulesEdited.add(newSchedule);
      });
    }
  }

  void selectTrainerList() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        context: context,
        isScrollControlled: true,
        builder: (builder) {
          return FutureBuilder(
            future: loadTrainers(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length > 0) {
                  return new Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    color: Colors.transparent, //could change this to Color(0xFF737373),
                    //so you don't have to change MaterialApp canvasColor
                    child: new Container(
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(25.0), topRight: const Radius.circular(25.0))),
                        child: new Center(child: ListView.builder(itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              setState(() {
                                selectedTrainerEdited = snapshot.data[index];
                              });
                              Navigator.of(context).pop();
                            },
                            title: Text(
                              snapshot.data[index].name +
                                  " " +
                                  snapshot.data[index].firstSurname +
                                  " " +
                                  snapshot.data[index].secondSurname,
                              style: TextStyle(fontSize: 16.0),
                            ),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(snapshot.data[index].urlImage),
                              radius: 16.0,
                            ),
                          );
                        }))),
                  );
                } else {
                  return new Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    color: Colors.transparent, //could change this to Color(0xFF737373),
                    //so you don't have to change MaterialApp canvasColor
                    child: new Container(
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(25.0), topRight: const Radius.circular(25.0))),
                        child: Center(
                          child: Text(
                            "No hay entrenadores en la escuela",
                            style: TextStyle(fontSize: 16.0),
                          ),
                        )),
                  );
                }
              } else {
                return new Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  color: Colors.transparent, //could change this to Color(0xFF737373),
                  //so you don't have to change MaterialApp canvasColor
                  child: new Container(
                      decoration: new BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(25.0), topRight: const Radius.circular(25.0))),
                      child: Center(child: CircularProgressIndicator())),
                );
              }
            },
          );
        });
  }

  double fromTimeOfDayToDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

  void editGroup() async {
    if (selectedTrainerEdited == null) {
      String message = "Debe de seleccionar un entrenador";
      errorDialog(context, message);
    } else if (schedulesEdited.isEmpty) {
      String message = "Debe de añadir los horarios del grupo";
      errorDialog(context, message);
    } else if (selectedTrainerEdited != null && schedulesEdited.isNotEmpty) {
      groupEdited.schedule = schedulesEdited;
      groupEdited.trainerId = selectedTrainerEdited.id;
      final databaseReference = Firestore.instance;
      await databaseReference.collection("groups").document(groupEdited.id).setData(
          {"name": groupEdited.name, "schedule": groupEdited.schedule, "trainerId": groupEdited.trainerId},
          merge: true).whenComplete(() async {
        for (SocialProfile actualStudent in studentsEdited) {
          await databaseReference
              .collection("socialProfiles")
              .document(actualStudent.id)
              .setData({"groupId": groupEdited.id}, merge: true);
        }
      });
    }
  }
}
