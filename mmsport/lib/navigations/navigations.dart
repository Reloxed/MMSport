
import 'package:flutter/material.dart';
import 'package:mmsport/screens/choose_sport_school.dart';
import 'package:mmsport/screens/create_sport_school.dart';
import 'package:mmsport/screens/register.dart';

void navigateFromLoginToRegister(BuildContext context){
  Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
}

void navigateFromRegisterToCreateSchool(BuildContext context){
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => CreateSportSchool()), (Route<dynamic> route) => false);
}

void navigateFromLoginToChooseSportSchool(BuildContext context){
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ChooseSportSchool()), (Route<dynamic> route) => false);
}