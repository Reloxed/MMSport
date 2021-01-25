import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
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
  bool isStudent = true;

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
    await FirebaseFirestore.instance
        .collection("socialProfiles")
        .where('role', isEqualTo: 'TRAINER')
        .where('sportSchoolId', isEqualTo: sportSchool.id)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        SocialProfile trainer = SocialProfile.socialProfileFromMap(element.data());
        trainer.id = element.id;
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
    if (logged.role == 'DIRECTOR' || logged.role == 'TRAINER') {
      isStudent = false;
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
    await FirebaseFirestore.instance.collection("socialProfiles").doc(group.trainerId).get().then((value) {
      trainer = SocialProfile.socialProfileFromMap(value.data());
      trainer.id = value.id;
    });

    return trainer;
  }

  Future<List<SocialProfile>> _loadStudents() async {
    List<SocialProfile> students = new List();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Group group = Group.groupFromMapWithId(jsonDecode(preferences.get("sportSchoolGroupToView")));
    await FirebaseFirestore.instance
        .collection("socialProfiles")
        .where('role', isEqualTo: 'STUDENT')
        .where('groupId', isEqualTo: group.id)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        SocialProfile newStudent = SocialProfile.socialProfileFromMap(element.data());
        newStudent.id = element.id;
        students.add(newStudent);
      });
    });
    studentsGroupWithouEdit = students;
    return students;
  }

  Future<List<SocialProfile>> loadStudentsToJoin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Group group = Group.groupFromMapWithId(jsonDecode(preferences.get("sportSchoolGroupToView")));
    await FirebaseFirestore.instance
        .collection("socialProfiles")
        .where('role', isEqualTo: 'STUDENT')
        .where('sportSchoolId', isEqualTo: group.sportSchoolId)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        SocialProfile newStudent = SocialProfile.socialProfileFromMap(element.data());
        newStudent.id = element.id;
        SocialProfile first;
        first = studentsToEnroll.firstWhere((element) => element.id == newStudent.id, orElse: () => null);
        if (newStudent.groupId != group.id && first == null) {
          studentsToEnroll.add(newStudent);
        }
      });
    });

    return studentsToEnroll;
  }

  Widget _editModePopUp() => PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text("Guardar"),
          ),
          PopupMenuItem(
            value: 2,
            child: Text("Cancelar"),
          ),
          PopupMenuItem(
            value: 3,
            child: Text("Eliminar"),
          ),
        ],
        onSelected: (value) {
          if (value == 1) {
            editGroup();
          }
          if (value == 2) {
            setState(() {
              _editMode = false;
            });
          }
          if (value == 3) {
            deleteGroup();
          }
        },
      );

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
                actions: [_editModePopUp()],
              ),
              body: CustomScrollView(slivers: <Widget>[
                SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _groupNameField("Nombre del grupo", groupEdited),
                        Container(
                          margin: EdgeInsets.only(top: 8.0, bottom: 4.0, right: 24.0, left: 24.0),
                          child: selectTrainer(),
                        ),
                        addSchedule(),
                      ],
                    ),
                  );
                }, childCount: 1)),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                    childCount: schedulesEdited.length,
                  ),
                ),
                SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                  return Center(
                    child: addSStudentsButton(),
                  );
                }, childCount: 1)),
                SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (studentsEdited[index].urlImage != null) {
                              return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(studentsEdited[index].urlImage),
                                    radius: 16.0,
                                  ),
                                  title: Text(
                                    studentsEdited[index].name,
                                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: studentsEdited[index].secondSurname == null
                                      ? Text(studentsEdited[index].firstSurname, style: TextStyle(fontSize: 16.0))
                                      : Text(
                                          studentsEdited[index].firstSurname +
                                              " " +
                                              studentsEdited[index].secondSurname,
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
                                          studentsEdited.remove(studentsEdited[index]);
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
                                    studentsEdited[index].name,
                                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: studentsEdited[index].secondSurname == null
                                      ? Text(studentsEdited[index].firstSurname, style: TextStyle(fontSize: 16.0))
                                      : Text(
                                          studentsEdited[index].firstSurname +
                                              " " +
                                              studentsEdited[index].secondSurname,
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
                                          studentsEdited.remove(studentsEdited[index]);
                                        });
                                      },
                                    ),
                                  ));
                            }
                          },
                          childCount: studentsEdited.length,
                        ),
                      ),
              ]),
            );
          } else {
            return Scaffold(
                appBar: AppBar(
                  title: Text(group.name),
                  centerTitle: true,
                ),
                body: CustomScrollView(slivers: <Widget>[
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    return Container(
                      margin: const EdgeInsets.only(top: 16.0),
                      child: Column(children: <Widget>[
                        CircleAvatar(
                          radius: 56,
                          backgroundImage: NetworkImage(groupTrainer.urlImage),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8.0, bottom: 16.0),
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
                    );
                  }, childCount: 1)),
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
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
                  }, childCount: schedules.length)),

                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                        );
                      }, childCount: 1)),

                  isStudent == true
                      ? SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            return Container();
                          }),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            if (groupStudents[index].urlImage != null) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(groupStudents[index].urlImage),
                                  radius: 16.0,
                                ),
                                title: Text(
                                  groupStudents[index].name,
                                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                ),
                                subtitle: groupStudents[index].secondSurname == null
                                    ? Text(groupStudents[index].firstSurname, style: TextStyle(fontSize: 16.0))
                                    : Text(groupStudents[index].firstSurname + " " + groupStudents[index].secondSurname,
                                    style: TextStyle(fontSize: 16.0)),
                              );
                            } else {
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Icon(Icons.person),
                                  radius: 16.0,
                                ),
                                title: Text(
                                  groupStudents[index].name,
                                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                ),
                                subtitle: groupStudents[index].secondSurname == null
                                    ? Text(groupStudents[index].firstSurname, style: TextStyle(fontSize: 16.0))
                                    : Text(groupStudents[index].firstSurname + " " + groupStudents[index].secondSurname,
                                    style: TextStyle(fontSize: 16.0)),
                              );
                            }
                          }, childCount: groupStudents.length,),
                        ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                        );
                      }, childCount: 1)),
                ]),
                /*body: Center(
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
                )),*/
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
      return Container();
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
        if (isStudent) {
          return Container();
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
  }

  Widget _groupNameField(String hintText, Group group) {
    IconData icon;
    icon = Icons.group;
    return Container(
      margin: EdgeInsets.only(top: 32.0, bottom: 4.0, right: 24.0, left: 24.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            textCapitalization: TextCapitalization.words,
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
        margin: EdgeInsets.only(bottom: 4.0, top: 16.0),
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
        margin: EdgeInsets.only(bottom: 4.0, top: 16.0),
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
    if (selectedTime != null) {
      setState(() {
        selectedStartTimeSchedule = selectedTime;
      });
      showEndTimeSchedulePicker();
    }
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
      final databaseReference = FirebaseFirestore.instance;
      List<String> studentsIds = new List();
      await databaseReference
          .collection("socialProfiles")
          .where("groupId", isEqualTo: groupEdited.id)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          studentsIds.add(element.data()["id"]);
        });
      });
      studentsIds.forEach((element) async {
        await databaseReference.collection("socialProfiles").doc(element).set({"groupId": ""}, SetOptions(merge: true));
      });
      await databaseReference.collection("groups").doc(groupEdited.id).delete();
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
      final databaseReference = FirebaseFirestore.instance;
      List<Map<String, dynamic>> groupSchedules = new List();
      for (Schedule actual in groupEdited.schedule) {
        groupSchedules.add(actual.scheduleToJson());
      }
      await databaseReference.collection("groups").doc(groupEdited.id).set(
          {"name": groupEdited.name, "schedule": groupSchedules, "trainerId": groupEdited.trainerId},
          SetOptions(merge: true)).whenComplete(() async {
        for (SocialProfile actualStudent in studentsEdited) {
          await databaseReference
              .collection("socialProfiles")
              .doc(actualStudent.id)
              .set({"groupId": groupEdited.id}, SetOptions(merge: true));
        }
        for (SocialProfile actualStudent in studentsGroupWithouEdit) {
          SocialProfile first =
              studentsEdited.firstWhere((element) => element.id == actualStudent.id, orElse: () => null);
          if (first == null) {
            await databaseReference
                .collection("socialProfiles")
                .doc(actualStudent.id)
                .set({"groupId": ""}, SetOptions(merge: true));
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
