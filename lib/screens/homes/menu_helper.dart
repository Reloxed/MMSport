import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/constants/constants.dart';
import 'package:mmsport/models/group.dart';
import 'package:mmsport/models/schedule.dart';
import 'package:mmsport/navigations/navigations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget menuGrid(BuildContext context, String role) {
  return GridView.count(
    padding: EdgeInsets.all(20.0),
    crossAxisSpacing: 20.0,
    mainAxisSpacing: 20.0,
    crossAxisCount: 2,
    children: _menuItems(context, role),
  );
}

// ignore: missing_return
List<Widget> _menuItems(BuildContext context, String role) {
  if (role == "STUDENT") {
    return [
      _menuItem("Chats", Icons.chat, "STUDENT", 1, context),
      _menuItem("Mi grupo", Icons.group, "STUDENT", 2, context),
      _menuItem("Calendario", Icons.calendar_today, "STUDENT", 3, context),
      _menuItem("Editar perfil", Icons.person, "STUDENT", 4, context)
    ];
  } else if (role == "TRAINER") {
    return [
      _menuItem("Chats", Icons.chat, "TRAINER", 1, context),
      _menuItem("Mis grupos", Icons.group, "TRAINER", 2, context),
      _menuItem("Calendario", Icons.calendar_today, "TRAINER", 3, context),
      _menuItem("Editar perfil", Icons.person, "TRAINER", 4, context),
    ];
  } else if (role == "DIRECTOR") {
    return [
      _menuItem("Chats", Icons.chat, "DIRECTOR", 1, context),
      _menuItem("Mis grupos", Icons.group, "DIRECTOR", 2, context),
      _menuItem("Calendario", Icons.calendar_today, "DIRECTOR", 3, context),
      _menuItem("Aceptar/rechazar perfiles", Icons.check, "DIRECTOR", 4, context),
      _menuItem("Eliminar perfiles", Icons.delete, "DIRECTOR", 5, context),
      _menuItem("Editar perfil", Icons.person, "DIRECTOR", 6, context)
    ];
  } else if (role == "ADMIN") {
    return [
      _menuItem("Aceptar/rechazar escuelas", Icons.check, "ADMIN", 1, context),
      _menuItem("Eliminar escuelas", Icons.delete, "ADMIN", 2, context)
    ];
  }
}

Widget _menuItem(String text, IconData icon, String role, int i, BuildContext context) {
  return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 6)]),
      child: InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 40.0,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 25.0),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        onTap: () {
          // ignore: unnecessary_statements
          _navigatorHelper(role, i, context);
        },
      ));
}

void _navigatorHelper(String role, int i, BuildContext context) async {
  if (i == 1 && role != "ADMIN") {
    navigateToChatMain(context);
  } else if (i == 1 && role == "ADMIN") {
    navigateToAcceptRejectSchools(context);
  } else if (i == 2 && role == "ADMIN") {
    navigateToRemoveSportSchools(context);
  } else if (i == 2 && role == "DIRECTOR") {
    navigateToListSportSchoolGroups(context);
  } else if (i == 2 && role == "TRAINER") {
    navigateToListSportSchoolGroups(context);
  } else if (i == 2 && role == "STUDENT") {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = await jsonDecode(preferences.get("chosenSocialProfile"));
    await FirebaseFirestore.instance.collection("socialProfiles").doc(aux['id']).get().then((value) {
      if (value.data()['groupId'] != null && value.data()['groupId'] != "") {
        FirebaseFirestore.instance.collection("groups").doc(value.data()['groupId'].toString()).get().then((element) {
          List<Schedule> groupSchedule = [];
          element.data()['schedule'].forEach((codedSchedule) {
            groupSchedule.add(Schedule.scheduleFromMap(codedSchedule));
          });
          Group group = Group.groupFromMapWithIdFromFirebase(element.data(), groupSchedule);
          setSportSchoolGroupToView(group);
          navigateToSportSchoolGroupDetails(context);
        });
      }
      else {
        errorDialog(context, "El alumno no está en ningún grupo actualmente");
      }
    });
  } else if (i == 3 && (role == "TRAINER" || role == "STUDENT")) {
  } else if (i == 3 && role == "DIRECTOR") {
    navigateToCalendarEvent(context);
  } else if (i == 4 && role == "DIRECTOR") {
    navigateToAcceptRejectProfiles(context);
  } else if (i == 4 && (role == "TRAINER" || role == "STUDENT")) {
    navigateToEditSocialProfile(context);
  } else if (i == 6 && role == "DIRECTOR") {
    navigateToEditSocialProfile(context);
  } else if (i == 5 && role == "DIRECTOR") {
    navigateToRemoveSocialProfiles(context);
  }
}