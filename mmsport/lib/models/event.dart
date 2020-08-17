

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mmsport/components/utils.dart';

@JsonSerializable(nullable: false)
class Event{
  DateTime day;
  TimeOfDay startTimeEvent;
  TimeOfDay endTimeEvent;

  Event(DateTime day, TimeOfDay startTimeEvent, TimeOfDay endTimeEvent){
    this.day = day;
    this.startTimeEvent = startTimeEvent;
    this.endTimeEvent = endTimeEvent;
  }

  static Event scheduleFromMap(Map<String, dynamic> map){

    return new Event(map['day'], stringToTimeOfDay(map['startTimeEvent']) , stringToTimeOfDay(map['endTimeEvent']));
  }

  Map<String, dynamic> eventToJson() => {
    "day": day.toIso8601String(),
    "startTimeEvent": startTimeEvent.hour.toString() + ":" + startTimeEvent.minute.toString(),
    "endTimeEvent": endTimeEvent.hour.toString() + ":" + endTimeEvent.minute.toString(),
  };
}