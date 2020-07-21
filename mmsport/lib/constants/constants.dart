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
}

void setSportSchoolToEnrollIn(SportSchool sportSchool) async{
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String socialProfileToJson = jsonEncode(sportSchool.sportSchoolToJson());
  preferences.setString("sportSchoolToEnrollIn", socialProfileToJson);
}