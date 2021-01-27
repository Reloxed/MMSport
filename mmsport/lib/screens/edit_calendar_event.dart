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

class EditCalendarEvent extends StatefulWidget {
  @override
  _EditCalendarEventState createState() {
    return new _EditCalendarEventState();
  }
}

class _EditCalendarEventState extends State<EditCalendarEvent> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  DateTime selectedDay;
  TimeOfDay selectedStartTimeEvent;
  TimeOfDay selectedEndTimeEvent;
  String eventName;
  String _id;
  bool firstLoad = true;

  Future<Event> loadEvent() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Event _event = Event.eventFromMap(await jsonDecode(preferences.get("eventToEdit")));
    if (firstLoad) {
      selectedDay = _event.day;
      _dayController.text = formatDateTime(selectedDay);
      selectedStartTimeEvent = _event.startTimeEvent;
      _startTimeController.text = selectedStartTimeEvent.format(context);
      selectedEndTimeEvent = _event.endTimeEvent;
      _endTimeController.text = selectedEndTimeEvent.format(context);
      eventName = _event.eventName;
      _id = _event.id;
      firstLoad = false;
    }
    return _event;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: FutureBuilder<Event>(
            future: loadEvent(),
            builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
              if (snapshot.hasData) {
                return Scaffold(
                    appBar: AppBar(
                      title: Text("Editar evento"),
                      centerTitle: true,
                    ),
                    body: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Form(
                            key: _formKey,
                            autovalidateMode: AutovalidateMode.disabled,
                            child: Column(
                              children: <Widget>[
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      _eventName(),
                                      _selectDateField(),
                                      _selectStartTime(),
                                      _selectEndTime()
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[_editEvent()],
                                ),
                              ],
                            ))));
              } else {
                return Container();
              }
            }));
  }

  Widget _eventName() {
    IconData icon;
    icon = Icons.event_note;
    return Container(
      margin: EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        initialValue: eventName,
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
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: <Widget>[
          TextFormField(
            textCapitalization: TextCapitalization.words,
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
      initialDate: selectedDay,
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
      margin: EdgeInsets.symmetric(vertical: 10),
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
      margin: EdgeInsets.symmetric(vertical: 10),
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
      initialTime: selectedEndTimeEvent,
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

  Widget _editEvent() {
    return Container(
        margin: EdgeInsets.only(top: 16),
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: RaisedButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                loadingDialog(context);
                editEvent();
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.of(context).pop();
              }
            },
            elevation: 3.0,
            color: Colors.blueAccent,
            child: Text(
              "GUARDAR CAMBIOS",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ));
  }

  void editEvent() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    SportSchool _sportSchool = SportSchool.sportSchoolFromMap(await jsonDecode(preferences.get("chosenSportSchool")));
    Event newEvent = Event(eventName, selectedDay, selectedStartTimeEvent, selectedEndTimeEvent, _sportSchool.id);
    final databaseReference = FirebaseFirestore.instance;
    await databaseReference.collection("events").doc(_id).set({
      "eventName": newEvent.eventName,
      "day": formatDateTime(newEvent.day),
      "startTimeEvent": timeOfDayToString(newEvent.startTimeEvent, context),
      "endTimeEvent": timeOfDayToString(newEvent.endTimeEvent, context),
      "sportSchoolId": newEvent.sportSchoolId
    }, SetOptions(merge: true));
  }
}
