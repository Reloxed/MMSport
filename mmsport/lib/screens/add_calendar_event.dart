import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/components/form_validators.dart';
import 'package:mmsport/components/utils.dart';
import 'package:mmsport/models/event.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCalendarEvent extends StatefulWidget {
  @override
  _AddCalendarEventState createState() {
    return new _AddCalendarEventState();
  }
}

class _AddCalendarEventState extends State<AddCalendarEvent> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  DateTime selectedDay;
  TimeOfDay selectedStartTimeEvent;
  TimeOfDay selectedEndTimeEvent;
  String eventName;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            appBar: AppBar(
              title: Text("Crear evento"),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                    key: _formKey,
                    autovalidate: false,
                    child: Column(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[_eventName(), _selectDateField(), _selectStartTime(), _selectEndTime()],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[_createEvent()],
                        ),
                      ],
                    )))));
  }

  Widget _eventName() {
    IconData icon;
    icon = Icons.event_note;
    return Container(
      margin: EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        validator: (v) {
          if (FormValidators.validateEmptyText(v) == false)
            return "Este campo no puede estar vacío";
          else
            return null;
        },
        decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Evento", prefixIcon: Icon(icon)),
        onChanged: (value) => eventName = value,
      ),
    );
  }

  Widget _selectDateField() {
    IconData icon = Icons.today;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _dayController,
            readOnly: true,
            onTap: () {
              showDateTimeDialog(context);
            },
            validator: (v) {
              if (FormValidators.validateEmptyText(v) == false)
                return "Debe de indicar el día del evento";
              else
                return null;
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Día del evento",
                prefixIcon: IconButton(
                  icon: Icon(icon),
                  onPressed: () {
                    showDateTimeDialog(context);
                  },
                )),
          )
        ],
      ),
    );
  }

  Future<void> showDateTimeDialog(BuildContext context) async {
    DateTime selectedTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: new DateTime(DateTime.now().year + 2),
      helpText: "Seleccione el día del evento",
      cancelText: "Cancelar",
      confirmText: "Confirmar",
    );

    if (selectedTime != null) {
      setState(() {
        selectedDay = selectedTime;
        _dayController.text = formatDateTime(selectedDay);
      });
    }
  }

  Widget _selectStartTime() {
    IconData icon = Icons.timer;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _startTimeController,
            readOnly: true,
            onTap: () {
              showStartTimeDialog(context);
            },
            validator: (v) {
              if (FormValidators.validateEmptyText(v) == false)
                return "Debe de indicar la hora de inicio";
              else
                return null;
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Hora inicio",
                prefixIcon: IconButton(
                  icon: Icon(icon),
                  onPressed: () {
                    showStartTimeDialog(context);
                  },
                )),
          )
        ],
      ),
    );
  }

  Future<void> showStartTimeDialog(BuildContext context) async {
    TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
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
      if (selectedEndTimeEvent != null) {
        if (fromTimeOfDayToDouble(selectedEndTimeEvent) < fromTimeOfDayToDouble(selectedTime)) {
          errorDialog(context, "La hora de fin debe de ser superior a la hora de inicio");
        } else {
          setState(() {
            selectedStartTimeEvent = selectedTime;
            _startTimeController.text = selectedStartTimeEvent.format(context);
          });
        }
      } else {
        setState(() {
          selectedStartTimeEvent = selectedTime;
          _startTimeController.text = selectedStartTimeEvent.format(context);
        });
      }
    }
  }

  Widget _selectEndTime() {
    IconData icon = Icons.timer_off;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _endTimeController,
            readOnly: true,
            onTap: () {
              showEndTimeDialog(context);
            },
            validator: (v) {
              if (FormValidators.validateEmptyText(v) == false)
                return "Debe de seleccionar la hora de fin";
              else
                return null;
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Hora fin",
                prefixIcon: IconButton(
                  icon: Icon(icon),
                  onPressed: () {
                    showEndTimeDialog(context);
                  },
                )),
          )
        ],
      ),
    );
  }

  Future<void> showEndTimeDialog(BuildContext context) async {
    TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
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
      if (selectedStartTimeEvent != null) {
        if (fromTimeOfDayToDouble(selectedTime) < fromTimeOfDayToDouble(selectedStartTimeEvent)) {
          errorDialog(context, "La hora de fin debe de ser superior a la hora de inicio");
        } else {
          setState(() {
            selectedEndTimeEvent = selectedTime;
            _endTimeController.text = selectedEndTimeEvent.format(context);
          });
        }
      } else {
        setState(() {
          selectedEndTimeEvent = selectedTime;
          _endTimeController.text = selectedEndTimeEvent.format(context);
        });
      }
    }
  }

  Widget _createEvent() {
    return Container(
        margin: EdgeInsets.only(top: 16),
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: RaisedButton(
            onPressed: () {
              loadingDialog(context);
              createEvent();
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context).pop();
            },
            elevation: 3.0,
            color: Colors.blueAccent,
            child: Text(
              "CREAR EVENTO",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ));
  }

  void createEvent() async {
    if (_formKey.currentState.validate()) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      SportSchool _sportSchool = SportSchool.sportSchoolFromMap(await jsonDecode(preferences.get("chosenSportSchool")));
      Event newEvent = Event(eventName, selectedDay, selectedStartTimeEvent, selectedEndTimeEvent, _sportSchool.id);
      final databaseReference = Firestore.instance;
      await databaseReference.collection("events").add({
        "eventName": newEvent.eventName,
        "day": formatDateTime(newEvent.day),
        "startTimeEvent": timeOfDayToString(newEvent.startTimeEvent, context),
        "endTimeEvent": timeOfDayToString(newEvent.endTimeEvent, context),
        "sportSchoolId": newEvent.sportSchoolId
      });
    }
  }
}
