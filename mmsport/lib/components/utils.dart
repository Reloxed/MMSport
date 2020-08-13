import 'package:flutter/material.dart';

TimeOfDay stringToTimeOfDay(String time){
  return TimeOfDay(hour:int.parse(time.split(":")[0]), minute: int.parse(time.split(":")[1]));
}