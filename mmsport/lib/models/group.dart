import 'package:flutter/material.dart';
import 'package:mmsport/models/schedule.dart';
import 'package:mmsport/models/socialProfile.dart';

class Group{
  String name;
  String id;
  List<Schedule> schedule;
  String sportSchoolId;
  String trainerId;

  Group(String name, List<Schedule> schedule, String sportSchoolId, String trainerId){
    this.name = name;
    this.schedule = schedule;
    this.sportSchoolId = sportSchoolId;
    this.trainerId = trainerId;
  }

  Group.groupWithId(String name, List<Map<String, dynamic>> schedule, String sportSchoolId, String trainerId, String id){
    this.name = name;
    schedule.forEach((element) {
      this.schedule.add(new Schedule(element['dayOfTheWeek'], element['startTimeSchedule'], element['endTimeSchedule']));
    });
    this.sportSchoolId = sportSchoolId;
    this.trainerId = trainerId;
    this.id = id;
  }

  Group.groupWithoutId(String name, List<Schedule> schedule, String sportSchoolId, String trainerId){
    this.name = name;
    this.schedule = schedule;
    this.sportSchoolId = sportSchoolId;
    this.trainerId = trainerId;
  }

  static Group groupFromMapWithId(Map<String, dynamic> map){

    return new Group.groupWithId(map['name'], map['schedule'], map['sportSchoolId'], map['trainerId'], map['id']);
  }
}