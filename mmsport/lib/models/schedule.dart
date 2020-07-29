import 'package:flutter/material.dart';

class Schedule{
  String dayOfTheWeek;
  TimeOfDay startTimeSchedule;
  TimeOfDay endTimeSchedule;

  Schedule(String dayOfTheWeek, TimeOfDay startTimeSchedule, TimeOfDay endTimeSchedule){
    this.dayOfTheWeek = dayOfTheWeek;
    this.startTimeSchedule = startTimeSchedule;
    this.endTimeSchedule = endTimeSchedule;
  }

  static Schedule scheduleFromMapWithId(Map<String, dynamic> map){

    return new Group.groupWithId(map['name'], map['schedule'], map['sportSchoolId'], map['trainerId'], map['id']);
  }
}