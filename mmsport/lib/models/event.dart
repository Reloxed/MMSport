

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mmsport/components/utils.dart';

@JsonSerializable(nullable: false)
class Event{
  String id;
  String eventName;
  DateTime day;
  TimeOfDay startTimeEvent;
  TimeOfDay endTimeEvent;
  String sportSchoolId;

  Event(String eventName, DateTime day, TimeOfDay startTimeEvent, TimeOfDay endTimeEvent, String sportSchoolId){
    this.eventName = eventName;
    this.day = day;
    this.startTimeEvent = startTimeEvent;
    this.endTimeEvent = endTimeEvent;
    this.sportSchoolId = sportSchoolId;
  }

  Event.eventWithId(String id, String eventName, DateTime day, TimeOfDay startTimeEvent, TimeOfDay endTimeEvent, String sportSchoolId){
    this.id = id;
    this.eventName = eventName;
    this.day = day;
    this.startTimeEvent = startTimeEvent;
    this.endTimeEvent = endTimeEvent;
    this.sportSchoolId = sportSchoolId;
  }

  static Event eventFromMap(Map<String, dynamic> map){

    return new Event.eventWithId(map['id'], map['eventName'], formatedToDateTime(map['day']), stringToTimeOfDay(map['startTimeEvent']) , stringToTimeOfDay(map['endTimeEvent']), map['sportSchoolId']);
  }

  Map<String, dynamic> eventToJson() => {
    "id" : id,
    "eventName" : eventName,
    "day": formatDateTime(day),
    "startTimeEvent": startTimeEvent.hour.toString() + ":" + startTimeEvent.minute.toString(),
    "endTimeEvent": endTimeEvent.hour.toString() + ":" + endTimeEvent.minute.toString(),
    "sportSchoolId" : sportSchoolId
  };
}