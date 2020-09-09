import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/components/utils.dart';
import 'package:mmsport/models/group.dart';
import 'package:mmsport/models/schedule.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateSportSchoolGroup extends StatefulWidget {
  @override
  _CreateSportSchoolGroupState createState() {
    return new _CreateSportSchoolGroupState();
  }
}

class _CreateSportSchoolGroupState extends State<CreateSportSchoolGroup> {
  final _formKey = GlobalKey<FormState>();

  List<String> daysOfTheWeek = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];
  String selectedDay;
  TimeOfDay selectedStartTimeSchedule = TimeOfDay.now();
  TimeOfDay selectedEndTimeSchedule = TimeOfDay.now();
  List<Schedule> schedules = [];
  List<String> schedulesDaysOfTheWeek = [];
  List<String> schedulesStartTimes = [];
  List<String> schedulesEndTimes = [];
  String groupName;
  SocialProfile selectedTrainer;

  Future<List<SocialProfile>> loadTrainers() async {
    List<SocialProfile> trainers = new List();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = jsonDecode(preferences.get("chosenSportSchool"));
    SportSchool sportSchool = SportSchool.sportSchoolFromMap(aux);
    await FirebaseFirestore.instance
        .collection("socialProfiles")
        .where('role', isEqualTo: 'TRAINER')
        .where('role', isEqualTo: 'DIRECTOR')
        .where('sportSchoolId', isEqualTo: sportSchool.id)
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        SocialProfile trainer = SocialProfile.socialProfileFromMap(element.data());
        trainer.id = element.id;
        trainers.add(trainer);
      });
    });
    return trainers;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Crear grupo"),
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
                        _groupNameField("Nombre del grupo"),
                        Container(
                          margin: const EdgeInsets.only(top: 4.0),
                          child: selectTrainer(),
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
                                          schedules.remove(schedules[index]);
                                        });
                                      },
                                    ),
                                  ));
                            },
                          ),
                        ),
                        addSchedule()
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[_button()],
                  ),
                ],
              ))),
    )));
  }

  Widget _groupNameField(String hintText) {
    IconData icon;
    icon = Icons.group;
    return Container(
      margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              if (v.isEmpty)
                return "Este campo no puede estar vacío";
              else
                return null;
            },
            obscureText: false,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: hintText, prefixIcon: Icon(icon)),
            onChanged: (value) => groupName = value,
          )
        ],
      ),
    );
  }

  Widget _button() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: RaisedButton(
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              createGroup();
            }
          },
          elevation: 3.0,
          color: Colors.blueAccent,
          child: Text(
            "CREAR GRUPO",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget selectTrainer() {
    if (selectedTrainer != null) {
      return Column(children: <Widget>[
        CircleAvatar(
          radius: 56,
          backgroundImage: NetworkImage(selectedTrainer.urlImage),
        ),
        selectedTrainer.secondSurname == null ?
        Text(
          selectedTrainer.name + " " + selectedTrainer.firstSurname,
          style: TextStyle(fontSize: 16, color: Colors.blueAccent),
        ) : Text(
          selectedTrainer.name + " " + selectedTrainer.firstSurname + " " + selectedTrainer.secondSurname,
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

  void showStartTimeSchedulePicker() async{

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
        if(fromTimeOfDayToDouble(selectedStartTimeSchedule) > fromTimeOfDayToDouble(selectedTime)){
          errorDialog(context, "La hora de fin debe de ser superior a la hora de inicio");
        }
        else{
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
        schedules.add(newSchedule);
      });
    }
  }

  void selectTrainerList() async{
    await Navigator.of(context)
        .push(new MaterialPageRoute<SocialProfile>(
        builder: (BuildContext context) {
          return new SelectTrainerGroupDialog(
            trainerSelected: this.selectedTrainer,
          );
        },
        fullscreenDialog: true))
        .then((value) => setState(() {
      if(value != null){
        selectedTrainer = value;
      }
    }));
  }

  void createGroup() async {
    if (selectedTrainer == null) {
      String message = "Debe de seleccionar un entrenador";
      errorDialog(context, message);
    } else if (schedules.isEmpty) {
      String message = "Debe de añadir los horarios del grupo";
      errorDialog(context, message);
    } else if (selectedTrainer != null && schedules.isNotEmpty) {
      loadingDialog(context);
      final databaseReference = FirebaseFirestore.instance;
      SharedPreferences preferences = await SharedPreferences.getInstance();
      Map aux = jsonDecode(preferences.get("chosenSportSchool"));
      SportSchool sportSchool = SportSchool.sportSchoolFromMap(aux);
      Group newGroup = Group(groupName, schedules, sportSchool.id, selectedTrainer.id);
      List<Map<String, dynamic>> groupSchedules = new List();
      for(Schedule actual in newGroup.schedule){
        groupSchedules.add(actual.scheduleToJson());
      }
      DocumentReference ref = await databaseReference.collection("groups").add({
        "name": newGroup.name,
        "schedule": groupSchedules,
        "sportSchoolId": newGroup.sportSchoolId,
        "trainerId": newGroup.trainerId
      });
      await databaseReference
          .collection("groups")
          .doc(ref.id)
          .set({"id": ref.id}, SetOptions(merge: true));
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
    }
  }
}