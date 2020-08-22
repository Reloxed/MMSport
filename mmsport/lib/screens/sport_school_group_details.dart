import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/components/utils.dart';
import 'package:mmsport/constants/constants.dart';
import 'package:mmsport/models/group.dart';
import 'package:mmsport/models/schedule.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
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
  bool notAllowedToEdit = true;

  List<String> daysOfTheWeek = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];
  String selectedDay;
  TimeOfDay selectedStartTimeSchedule = TimeOfDay.now();
  TimeOfDay selectedEndTimeSchedule = TimeOfDay.now();
  List<Schedule> schedulesEdited;
  Group groupEdited;
  List<SocialProfile> studentsEdited;
  SocialProfile selectedTrainerEdited;
  List<SocialProfile> studentsToEnroll = [];
  List<SocialProfile> studentsGroupWithouEdit = [];

  @override
  void initState() {
    super.initState();
  }

  Future<List<SocialProfile>> loadTrainers() async {
    List<SocialProfile> trainers = new List();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = jsonDecode(preferences.get("chosenSportSchool"));
    SportSchool sportSchool = SportSchool.sportSchoolFromMap(aux);
    await Firestore.instance
        .collection("socialProfiles")
        .where('role', isEqualTo: 'TRAINER')
        .where('sportSchoolId', isEqualTo: sportSchool.id)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        SocialProfile trainer = SocialProfile.socialProfileFromMap(element.data);
        trainer.id = element.documentID;
        trainers.add(trainer);
      });
    });
    return trainers;
  }

  Future<Group> _loadGroup() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map profileLogged = await jsonDecode(preferences.get("chosenSocialProfile"));
    SocialProfile logged = SocialProfile.socialProfileFromMap(profileLogged);
    if (logged.role == 'DIRECTOR') {
      notAllowedToEdit = false;
    }
    Group group = Group.groupFromMapWithId(jsonDecode(preferences.get("sportSchoolGroupToView")));
    return group;
  }

  Future<List<Schedule>> _loadSchedule() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Group group = Group.groupFromMapWithId(jsonDecode(preferences.get("sportSchoolGroupToView")));
    return group.schedule;
  }

  Future<SocialProfile> _loadTrainer() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Group group = Group.groupFromMapWithId(jsonDecode(preferences.get("sportSchoolGroupToView")));
    SocialProfile trainer;
    await Firestore.instance.collection("socialProfiles").document(group.trainerId).get().then((value) {
      trainer = SocialProfile.socialProfileFromMap(value.data);
      trainer.id = value.documentID;
    });

    return trainer;
  }

  Future<List<SocialProfile>> _loadStudents() async {
    List<SocialProfile> students = new List();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Group group = Group.groupFromMapWithId(jsonDecode(preferences.get("sportSchoolGroupToView")));
    await Firestore.instance
        .collection("socialProfiles")
        .where('role', isEqualTo: 'STUDENT')
        .where('groupId', isEqualTo: group.id)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        SocialProfile newStudent = SocialProfile.socialProfileFromMap(element.data);
        newStudent.id = element.documentID;
        students.add(newStudent);
      });
    });
    studentsGroupWithouEdit = students;
    return students;
  }

  Future<List<SocialProfile>> loadStudentsToJoin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Group group = Group.groupFromMapWithId(jsonDecode(preferences.get("sportSchoolGroupToView")));
    await Firestore.instance
        .collection("socialProfiles")
        .where('role', isEqualTo: 'STUDENT')
        .where('sportSchoolId', isEqualTo: group.sportSchoolId)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        SocialProfile newStudent = SocialProfile.socialProfileFromMap(element.data);
        newStudent.id = element.documentID;
        SocialProfile first;
        first = studentsToEnroll.firstWhere((element) => element.id == newStudent.id, orElse: () => null);
        if (newStudent.groupId != group.id && first == null) {
          studentsToEnroll.add(newStudent);
        }
      });
    });

    return studentsToEnroll;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: FutureBuilder<List<dynamic>>(
      future: Future.wait([_loadGroup(), _loadTrainer(), _loadStudents(), _loadSchedule()]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshots) {
        if (snapshots.hasData) {
          Group group = snapshots.data[0];
          SocialProfile groupTrainer = snapshots.data[1];
          List<SocialProfile> groupStudents = snapshots.data[2];
          List<Schedule> schedules = snapshots.data[3];
          if (_editMode) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Editar grupo"),
                ),
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
                        backgroundColor: Colors.deepOrange),
                    SpeedDialChild(
                        onTap: () async {
                          deleteGroup();
                        },
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        label: 'Eliminar',
                        backgroundColor: Colors.red),
                  ],
                ));
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: Text(group.name),
                  centerTitle: true,
                ),
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
                          Container(
                            margin: const EdgeInsets.only(top: 4.0),
                            child: Column(children: <Widget>[
                              CircleAvatar(
                                radius: 56,
                                backgroundImage: NetworkImage(groupTrainer.urlImage),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 4.0),
                                child: groupTrainer.secondSurname == null
                                    ? Text(
                                        groupTrainer.name + " " + groupTrainer.firstSurname,
                                        style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                                      )
                                    : Text(
                                        groupTrainer.name +
                                            " " +
                                            groupTrainer.firstSurname +
                                            " " +
                                            groupTrainer.secondSurname,
                                        style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                                      ),
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
                floatingActionButton: editButton(schedules, groupStudents, groupTrainer, group));
          }
        } else {
          return loadingHome();
        }
      },
    ));
  }

  Widget editButton(
      List<Schedule> schedules, List<SocialProfile> groupStudents, SocialProfile groupTrainer, Group group) {
    if (notAllowedToEdit) {
      return SizedBox.shrink();
    } else {
      return FloatingActionButton(
          onPressed: () {
            setState(() {
              _editMode = true;
              schedulesEdited = schedules;
              studentsEdited = groupStudents;
              selectedTrainerEdited = groupTrainer;
              groupEdited = group;
            });
          },
          tooltip: 'Editar',
          child: Icon(
            Icons.edit,
            color: Colors.white,
          ));
    }
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
                  subtitle: students[index].secondSurname == null
                      ? Text(students[index].firstSurname, style: TextStyle(fontSize: 16.0))
                      : Text(students[index].firstSurname + " " + students[index].secondSurname,
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
                    child: Icon(Icons.person),
                    radius: 16.0,
                  ),
                  title: Text(
                    students[index].name,
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: students[index].secondSurname == null
                      ? Text(students[index].firstSurname, style: TextStyle(fontSize: 16.0))
                      : Text(students[index].firstSurname + " " + students[index].secondSurname,
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
      if (students.length == 0 || students == null) {
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
                subtitle: students[index].secondSurname == null
                    ? Text(students[index].firstSurname, style: TextStyle(fontSize: 16.0))
                    : Text(students[index].firstSurname + " " + students[index].secondSurname,
                        style: TextStyle(fontSize: 16.0)),
              );
            } else {
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.person),
                  radius: 16.0,
                ),
                title: Text(
                  students[index].name,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                subtitle: students[index].secondSurname == null
                    ? Text(students[index].firstSurname, style: TextStyle(fontSize: 16.0))
                    : Text(students[index].firstSurname + " " + students[index].secondSurname,
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
      margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
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
        selectedTrainerEdited.secondSurname == null
            ? Text(
                selectedTrainerEdited.name + " " + selectedTrainerEdited.firstSurname,
                style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              )
            : Text(
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
          onPressed: () => addStudentsList(),
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

  Future addStudentsList() async {
    await Navigator.of(context)
        .push(new MaterialPageRoute<List<SocialProfile>>(
            builder: (BuildContext context) {
              return new AddStudentsToGroupDialog(
                studentsEdited: this.studentsEdited,
              );
            },
            fullscreenDialog: true))
        .then((value) => setState(() {
              if (value != null) {
                studentsEdited = value;
              }
            }));
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

  void showStartTimeSchedulePicker() async {
    TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      cancelText: 'CANCELAR',
      confirmText: 'CONFIRMAR',
      helpText: 'Seleccione la hora de inicio',
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    setState(() {
      selectedStartTimeSchedule = selectedTime;
    });
    showEndTimeSchedulePicker();
  }

  void showEndTimeSchedulePicker() async {
    TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      cancelText: 'CANCELAR',
      confirmText: 'CONFIRMAR',
      helpText: 'Seleccione la hora de fin',
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    if (selectedTime != null) {
      if (fromTimeOfDayToDouble(selectedStartTimeSchedule) > fromTimeOfDayToDouble(selectedTime)) {
        errorDialog(context, "La hora de fin debe de ser superior a la hora de inicio");
      } else {
        setState(() {
          selectedEndTimeSchedule = selectedTime;
        });
        addNewSchedule();
      }
    }
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

  void selectTrainerList() async {
    await Navigator.of(context)
        .push(new MaterialPageRoute<SocialProfile>(
            builder: (BuildContext context) {
              return new SelectTrainerGroupDialog(
                trainerSelected: this.selectedTrainerEdited,
              );
            },
            fullscreenDialog: true))
        .then((value) => setState(() {
              if (value != null) {
                selectedTrainerEdited = value;
              }
            }));
  }

  void deleteGroup() async {
    bool confirm =
        await confirmDialogOnDeleteGroup(context, "¿Está seguro de que quiere eliminar el grupo?", groupEdited);
    if (confirm) {
      final databaseReference = Firestore.instance;
      List<String> studentsIds = new List();
      await databaseReference
          .collection("socialProfiles")
          .where("groupId", isEqualTo: groupEdited.id)
          .getDocuments()
          .then((value) {
        value.documents.forEach((element) {
          studentsIds.add(element.data["id"]);
        });
      });
      studentsIds.forEach((element) async {
        await databaseReference.collection("socialProfiles").document(element).setData({"groupId": ""}, merge: true);
      });
      await databaseReference.collection("groups").document(groupEdited.id).delete();
      Navigator.pop(context);
    }
  }

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
      List<Map<String, dynamic>> groupSchedules = new List();
      for (Schedule actual in groupEdited.schedule) {
        groupSchedules.add(actual.scheduleToJson());
      }
      await databaseReference.collection("groups").document(groupEdited.id).setData(
          {"name": groupEdited.name, "schedule": groupSchedules, "trainerId": groupEdited.trainerId},
          merge: true).whenComplete(() async {
        for (SocialProfile actualStudent in studentsEdited) {
          await databaseReference
              .collection("socialProfiles")
              .document(actualStudent.id)
              .setData({"groupId": groupEdited.id}, merge: true);
        }
        for (SocialProfile actualStudent in studentsGroupWithouEdit) {
          SocialProfile first =
              studentsEdited.firstWhere((element) => element.id == actualStudent.id, orElse: () => null);
          if (first == null) {
            await databaseReference
                .collection("socialProfiles")
                .document(actualStudent.id)
                .setData({"groupId": ""}, merge: true);
          }
        }
      });
      setSportSchoolGroupToView(groupEdited);
      setState(() {
        _editMode = false;
      });
    }
  }
}
