import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/models/schedule.dart';
import 'package:mmsport/models/socialProfile.dart';
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
  SocialProfile trainer;

  Future<List<SocialProfile>> loadTrainers() async{
    List<SocialProfile> trainers = new List();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String sportSchoolId = preferences.get("chosenSportSchool");
    await Firestore.instance
        .collection("socialProfiles")
        .where('role', isEqualTo: 'TRAINER').where('sportSchoolId', isEqualTo: sportSchoolId)
        .getDocuments().then((value) {
      value.documents.forEach((element) async {
        SocialProfile trainer = SocialProfile.socialProfileFromMap(element.data);
        trainer.id = element.documentID;
        trainers.add(trainer);
      });
    });
    return trainers;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
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
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return ListTile(
                                  title: Text(
                                    schedules[index].dayOfTheWeek,
                                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                      "De " +
                                          schedules[index].startTimeSchedule.toString() +
                                          " a " +
                                          schedules[index].endTimeSchedule.toString(),
                                      style: TextStyle(fontSize: 16.0)),
                                  trailing: Ink(
                                    decoration: const ShapeDecoration(
                                      color: Colors.lightBlue,
                                      shape: BeveledRectangleBorder(),
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.delete),
                                      color: Colors.white,
                                      onPressed: () {
                                        setState(() {
                                          schedules.removeAt(index);
                                          schedulesDaysOfTheWeek.removeAt(index);
                                          schedulesStartTimes.removeAt(index);
                                          schedulesEndTimes.removeAt(index);
                                        });
                                      },
                                    ),
                                  ));
                            },
                            itemCount: schedules.length,
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
      child: Column(
        children: <Widget>[
          TextFormField(
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
            if (_formKey.currentState.validate()) {}
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
    if (trainer != null) {
      return Column(children: <Widget>[
        CircleAvatar(
          radius: 56,
          backgroundImage: NetworkImage(trainer.urlImage),
        ),
        Text(
          trainer.name + " " + trainer.firstSurname + " " + trainer.secondSurname,
          style: TextStyle(fontSize: 16, color: Colors.blueAccent),
        ),
      ]);
    } else {
      return RaisedButton(
        onPressed: () => {showSchedulePickers()},
        elevation: 3.0,
        color: Colors.blueAccent,
        child: Text(
          "SELECCIONAR ENTRENADOR",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      );
    }
  }

  Widget addSchedule(){
    return Container(
        margin: EdgeInsets.all(4.0),
        child: OutlineButton.icon(
          onPressed: () =>
              showSchedulePickers()
          ,
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
        context: context,
        title: "Selecciona el día",
        items: daysOfTheWeek,
        selectedItem: daysOfTheWeek[0],
        onChanged: (value) => setState(() => selectedDay = value),
        onConfirmed: () => {showStartTimeSchedulePicker()});
  }

  void showTrainersPicker(){
      FutureBuilder(
        future: loadTrainers(),
        builder: ,
      );
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
        schedules.add(newSchedule);
      });
    }
  }

  double fromTimeOfDayToDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;
}
