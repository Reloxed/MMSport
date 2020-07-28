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
}