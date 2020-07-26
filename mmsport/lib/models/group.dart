import 'package:flutter/material.dart';
import 'package:mmsport/models/schedule.dart';

class Group{
  String name;
  List<Schedule> schedule;
  String sportSchoolId;
  String trainerId;
  List<String> studentsList;

  Group(String name, List<Schedule> schedule, String sportSchoolId, String trainerId){
    this.name = name;
    this.schedule = schedule;
    this.sportSchoolId = sportSchoolId;
    this.trainerId = trainerId;
    this.studentsList = new List();
  }
}