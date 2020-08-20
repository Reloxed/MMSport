import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

TimeOfDay stringToTimeOfDay(String time){
  return TimeOfDay(hour:int.parse(time.split(":")[0]), minute: int.parse(time.split(":")[1]));
}

String timeOfDayToString(TimeOfDay time, BuildContext context){
  return time.format(context);
}

double fromTimeOfDayToDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

String formatDateTime(DateTime time){
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  final String formatted = formatter.format(time);
  return formatted; // something like 2013-04-20
}

DateTime formatedToDateTime(String formatedDateTime){
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  return formatter.parse(formatedDateTime);
}