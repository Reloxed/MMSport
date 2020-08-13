import 'dart:convert';

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

  Group.groupWithIdFromFirebase(String name, List<Schedule> schedule, String sportSchoolId, String trainerId, String id){
    this.name = name;
    this.schedule = schedule;
    this.sportSchoolId = sportSchoolId;
    this.trainerId = trainerId;
    this.id = id;
  }

  Group.groupWithId(String name, List<dynamic> schedule, String sportSchoolId, String trainerId, String id){
    this.name = name;
    this.schedule = new List();
    schedule.forEach((element) {
      if(element != null){
        this.schedule.add(Schedule.scheduleFromMap(element));
      }
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

  static Group groupFromMapWithIdFromFirebase(Map<String, dynamic> map, List<Schedule> schedules){

    return new Group.groupWithIdFromFirebase(map['name'], schedules, map['sportSchoolId'], map['trainerId'], map['id']);
  }

  Map<String, dynamic> groupToJson() => {
    "id": id,
    "name": name,
    "schedule": schedule.map((i) => i.scheduleToJson()).toList(),
    "sportSchoolId": sportSchoolId,
    "trainerId": trainerId
  };
}