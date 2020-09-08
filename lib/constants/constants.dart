import 'package:mmsport/models/event.dart';
import 'package:mmsport/models/group.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void setChosenSocialProfile(SocialProfile socialProfile) async{
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String socialProfileToJson = jsonEncode(socialProfile.socialProfileToJson());
  preferences.setString("chosenSocialProfile", socialProfileToJson);
}

void deleteChosenSocialProfile() async{
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.remove("chosenSocialProfile");
}

void setChosenSportSchool(SportSchool sportSchool) async{
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String socialProfileToJson = jsonEncode(sportSchool.sportSchoolToJson());
  preferences.setString("chosenSportSchool", socialProfileToJson);
}

void deleteChosenSportSchool() async{
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.remove("chosenSportSchool");
}

void setLoggedInUserId(SportSchool sportSchool) async{
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String socialProfileToJson = jsonEncode(sportSchool.sportSchoolToJson());
  preferences.setString("loggedInUserId", socialProfileToJson);
}

void deleteLoggedInUserId() async{
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.remove("loggedInUserId");
  preferences.remove("chosenSportSchool");
  preferences.remove("chosenSocialProfile");
}

void setSportSchoolToEnrollIn(SportSchool sportSchool) async{
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String socialProfileToJson = jsonEncode(sportSchool.sportSchoolToJson());
  preferences.setString("sportSchoolToEnrollIn", socialProfileToJson);
}

void setSportSchoolGroupToView(Group group) async{
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String socialProfileToJson = jsonEncode(group.groupToJson());
  preferences.setString("sportSchoolGroupToView", socialProfileToJson);
}

void setEventToEdit(Event event) async{
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String eventToJson = jsonEncode(event.eventToJson());
  preferences.setString("eventToEdit", eventToJson);
}