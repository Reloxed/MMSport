import 'package:flutter/material.dart';
import 'package:mmsport/screens/chats/chat_main.dart';
import 'package:mmsport/screens/chats/chat_room.dart';
import 'package:mmsport/screens/choose_social_profile.dart';
import 'package:mmsport/screens/choose_sport_school.dart';
import 'package:mmsport/screens/create_sport_school.dart';
import 'package:mmsport/screens/inscription_list_sport_school.dart';
import 'package:mmsport/screens/login.dart';
import 'package:mmsport/screens/register.dart';
import 'package:mmsport/screens/homes/home.dart';

void navigateToRegister(BuildContext context){
  Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
}

void navigateToCreateSchool(BuildContext context){
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => CreateSportSchool()), (Route<dynamic> route) => false);
}

void navigateToChooseSportSchool(BuildContext context){
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ChooseSportSchool()), (Route<dynamic> route) => false);
}

void navigateToChooseSocialProfile(BuildContext context){
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChooseSocialProfile()));
}

void navigateToHome(BuildContext context){
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Home()), (Route<dynamic> route) => false);
}

void logout(BuildContext context){
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Login()), (Route<dynamic> route) => false);
}

void navigateToChatMain(BuildContext context){
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatMain()));
}

void navigateToInscriptionListSportSchool(BuildContext context){
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => InscriptionListSportSchool()));
}

void navigateToChatRoom(BuildContext context){
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatRoom()));
}