import 'package:flutter/material.dart';
import 'package:mmsport/components/terms_and_conditions.dart';
import 'package:mmsport/constants/constants.dart';
import 'package:mmsport/models/event.dart';
import 'package:mmsport/screens/reset_password.dart';
import 'package:mmsport/screens/acceptreject/accept_reject_profiles.dart';
import 'package:mmsport/screens/acceptreject/accept_reject_schools.dart';
import 'package:mmsport/screens/add_calendar_event.dart';
import 'package:mmsport/screens/calendar_event.dart';
import 'package:mmsport/screens/chats/chat_main.dart';
import 'package:mmsport/screens/chats/chat_room.dart';
import 'package:mmsport/screens/choose_social_profile.dart';
import 'package:mmsport/screens/choose_sport_school.dart';
import 'package:mmsport/screens/create_sport_school.dart';
import 'package:mmsport/screens/create_sport_school_group.dart';
import 'package:mmsport/screens/edit_calendar_event.dart';
import 'package:mmsport/screens/edit_social_profile.dart';
import 'package:mmsport/screens/enrollment_create_social_profile_sport_school.dart';
import 'package:mmsport/screens/enrollment_list_sport_school.dart';
import 'package:mmsport/screens/homes/home.dart';
import 'package:mmsport/screens/login.dart';
import 'package:mmsport/screens/register.dart';
import 'package:mmsport/screens/remove/remove_sport_schools.dart';
import 'package:mmsport/screens/remove/remove_social_profiles.dart';
import 'package:mmsport/screens/sport_school_group_details.dart';
import 'package:mmsport/screens/sport_school_groups_list.dart';

void navigateToRegister(BuildContext context) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
}

void navigateToCreateSchool(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => CreateSportSchool()), (Route<dynamic> route) => false);
}

void navigateToChooseSportSchool(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => ChooseSportSchool()), (Route<dynamic> route) => false);
}

void navigateToChooseSocialProfile(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChooseSocialProfile()));
}

void navigateToHome(BuildContext context) {
  Navigator.of(context)
      .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Home()), (Route<dynamic> route) => false);
}

void logout(BuildContext context) {
  Navigator.of(context)
      .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Login()), (Route<dynamic> route) => false);
}

void navigateToChatMain(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatMain()));
}

void navigateToEnrollmentListSportSchool(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => EnrollmentListSportSchool()));
}

void navigateToChatRoom(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatRoom()));
}

void navigateToEnrollmentCreateSocialProfileSportSchool(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => EnrollmentCreateSocialProfileSportSchool()));
}

void navigateToAcceptRejectProfiles(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AcceptRejectProfiles()));
}

void navigateToAcceptRejectSchools(BuildContext context){
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AcceptRejectSchools()));
}

Future<dynamic> navigateToCreateSportSchoolGroup(BuildContext context) {
  return Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateSportSchoolGroup()));
}

void navigateToListSportSchoolGroups(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ListSportSchoolGroups()));
}

void navigateToSportSchoolGroupDetails(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => SportSchoolGroupDetails())).then((value) => null);
}

void navigateToCalendarEvent(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => CalendarEvent()));
}

Future<dynamic> navigateToAddCalendarEvent(BuildContext context) {
  return Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddCalendarEvent()));
}

Future<dynamic> navigateToTermsAndConditions(BuildContext context) {
  return Navigator.of(context).push(MaterialPageRoute(builder: (context) => TermsAndConditionsDialog()));
}

Future<dynamic> navigateToEditCalendarEvent(BuildContext context, Event event) {
  setEventToEdit(event);
  return Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditCalendarEvent()));
}

Future<dynamic> navigateToResetPassword(BuildContext context) {
  return Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResetPassword()));
}

void navigateToRemoveSocialProfiles(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RemoveSocialProfiles())).then((value) => null);
}

void navigateToEditSocialProfile(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditSocialProfile())).then((value) => null);
}

void navigateToRemoveSportSchools(BuildContext context){
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RemoveSportSchools())).then((value) => null);
}
