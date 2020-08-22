import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/components/utils.dart';
import 'package:mmsport/models/event.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:mmsport/navigations/navigations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarEvent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    _CalendarEventState state = new _CalendarEventState();
    return state;
  }
}

class _CalendarEventState extends State<CalendarEvent> {
  Map<DateTime, List<Event>> _events = new Map<DateTime, List<Event>>();
  List<Event> _selectedEvents = new List();
  DateTime _selectedDay;
  bool firstLoad = true;
  bool onBack = false;

  void _handleNewDate(date) {
    setState(() {
      firstLoad = false;
      onBack = false;
      String formattedDate = formatDateTime(date);
      _selectedDay = formatedToDateTime(formattedDate);
      _selectedEvents = _events[_selectedDay] ?? [];
    });
  }

  Future<Map<DateTime, List<Event>>> loadEvents() async {
    if (firstLoad) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      SportSchool _sportSchool = SportSchool.sportSchoolFromMap(await jsonDecode(preferences.get("chosenSportSchool")));
      await Firestore.instance
          .collection("events")
          .where('sportSchoolId', isEqualTo: _sportSchool.id)
          .getDocuments()
          .then((value) {
        value.documents.forEach((element) async {
          Event newEvent = Event.eventFromMap(element.data);
          newEvent.id = element.documentID;
          if (_events[newEvent.day] == null) {
            _events[newEvent.day] = new List<Event>();
            _events[newEvent.day].add(newEvent);
          } else {
            _events[newEvent.day].add(newEvent);
          }
        });
      });
      String formattedDateNow = formatDateTime(DateTime.now());
      _selectedDay = formatedToDateTime(formattedDateNow);
      _selectedEvents = _events[_selectedDay] ?? [];
    } else if (onBack) {
      _events = new Map();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      SportSchool _sportSchool = SportSchool.sportSchoolFromMap(await jsonDecode(preferences.get("chosenSportSchool")));
      await Firestore.instance
          .collection("events")
          .where('sportSchoolId', isEqualTo: _sportSchool.id)
          .getDocuments()
          .then((value) {
        value.documents.forEach((element) async {
          Event newEvent = Event.eventFromMap(element.data);
          newEvent.id = element.documentID;
          if (_events[newEvent.day] == null) {
            _events[newEvent.day] = new List<Event>();
            _events[newEvent.day].add(newEvent);
          } else {
            _events[newEvent.day].add(newEvent);
          }
          _selectedEvents = _events[_selectedDay] ?? [];
        });
      });
    }
    return _events;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<DateTime, List<Event>>>(
        future: loadEvents(),
        builder: (BuildContext context, AsyncSnapshot<Map<DateTime, List<Event>>> snapshots) {
          if (snapshots.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Eventos"),
                centerTitle: true,
              ),
              body: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      child: Calendar(
                        isExpanded: true,
                        startOnMonday: true,
                        weekDays: ["L", "M", "X", "J", "V", "S", "D"],
                        events: _events,
                        onDateSelected: (date) => _handleNewDate(date),
                        isExpandable: true,
                        selectedColor: Colors.pink,
                        todayColor: Colors.blueAccent,
                        eventColor: Colors.green,
                        dayOfWeekStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 11),
                      ),
                    ),
                    _buildEventList()
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  navigateToAddCalendarEvent(context).then((value) {
                    setState(() {
                      onBack = true;
                    });
                  });
                },
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            );
          } else {
            return loadingHome();
          }
        });
  }

  Widget _buildEventList() {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) => Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1.5, color: Colors.black12),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
          child: ListTile(
            title: Text(_selectedEvents[index].eventName),
            subtitle: Text("De " +
                timeOfDayToString(_selectedEvents[index].startTimeEvent, context) +
                " a " +
                timeOfDayToString(_selectedEvents[index].endTimeEvent, context)),
            trailing: trailingButtons(_selectedEvents[index]),
          ),
        ),
        itemCount: _selectedEvents.length,
      ),
    );
  }

  Widget trailingButtons(Event event) {
    DateTime now = DateTime.now();
    int diffDays = now.difference(event.day).inDays;
    if (diffDays <= 0 && event.day.day != now.day) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              navigateToEditCalendarEvent(context, event).then((value) {
                setState(() {
                  onBack = true;
                });
              });
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              confirmDialogOnDeleteEvent(context, "¿Estás seguro de que quieres eliminar el grupo?", event)
                  .then((value) {
                if (_events[_selectedDay].contains(event)) {
                  _events[_selectedDay].remove(event);
                }
                setState(() {
                  onBack = true;
                });
              });
            },
          )
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
      );
    }
  }
}
