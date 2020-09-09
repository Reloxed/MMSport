import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mmsport/components/utils.dart';

@JsonSerializable(nullable: false)
class Schedule{
  String dayOfTheWeek;
  TimeOfDay startTimeSchedule;
  TimeOfDay endTimeSchedule;

  Schedule(String dayOfTheWeek, TimeOfDay startTimeSchedule, TimeOfDay endTimeSchedule){
    this.dayOfTheWeek = dayOfTheWeek;
    this.startTimeSchedule = startTimeSchedule;
    this.endTimeSchedule = endTimeSchedule;
  }

  static Schedule scheduleFromMap(Map<String, dynamic> map){

    return new Schedule(map['dayOfTheWeek'], stringToTimeOfDay(map['startTimeSchedule']) , stringToTimeOfDay(map['endTimeSchedule']));
  }

  Map<String, dynamic> scheduleToJson() => {
    "dayOfTheWeek": dayOfTheWeek,
    "startTimeSchedule": startTimeSchedule.hour.toString() + ":" + startTimeSchedule.minute.toString(),
    "endTimeSchedule": endTimeSchedule.hour.toString() + ":" + endTimeSchedule.minute.toString(),
  };
}