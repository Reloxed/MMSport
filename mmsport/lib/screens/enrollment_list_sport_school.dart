import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:mmsport/constants/constants.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:mmsport/navigations/navigations.dart';
import 'package:search_app_bar/filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnrollmentListSportSchool extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _EnrollmentListSportSchoolState();
  }
}

class _EnrollmentListSportSchoolState extends State<EnrollmentListSportSchool> {
  final List<SportSchool> _sportSchools = [];
  List<SportSchool> _filtered = [];
  SearchBar searchBar;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // ignore: missing_return
  Future<SportSchool> getAll() async {
    if (_sportSchools.isEmpty) {
      await Firestore.instance
          .collection("sportSchools")
          .getDocuments()
          .then((value) =>
          value.documents.forEach((element) {
            SportSchool newSportSchool = SportSchool.sportSchoolFromMap(element.data);
            _sportSchools.add(newSportSchool);
          }));
      _filtered = _sportSchools;
    } else {
      //EASIER HAVING THE ID ATTRIBUTE ON THE MODEL
      await Firestore.instance
          .collection("sportSchools")
          .getDocuments()
          .then((value) =>
          value.documents.forEach((element) {
            SportSchool newSportSchool = SportSchool.sportSchoolFromMap(element.data);
            SportSchool existingSportSchool = _sportSchools.firstWhere(
                    (element) =>
                newSportSchool.name == element.name && newSportSchool.province == element.province &&
                    newSportSchool.address == element.address && newSportSchool.town == element.town &&
                    newSportSchool.urlLogo == element.urlLogo && newSportSchool.status == element.status);
            if (existingSportSchool == null) {
              _sportSchools.add(newSportSchool);
            }
          }));
    }
  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(title: new Text('Buscar'), actions: [searchBar.getSearchAction(context)]);
  }

  void onChanged(String value) {
    setState(() {
      _filtered = _sportSchools
          .where((s) =>
      Filters.startsWith(s.name.toLowerCase(), value.toLowerCase()) ||
          Filters.startsWith(s.province.toLowerCase(), value.toLowerCase()) ||
          Filters.startsWith(s.town.toLowerCase(), value.toLowerCase()))
          .toList();
    });
  }

  _EnrollmentListSportSchoolState() {
    searchBar = new SearchBar(
      inBar: false,
      hintText: "Buscar...",
      onChanged: (String value) {
        onChanged(value);
      },
      setState: setState,
      onCleared: () {
        _filtered = _sportSchools;
      },
      buildDefaultAppBar: buildAppBar,
    );
  }

  // ignore: missing_return
  Future<void> _saveSharedPreferenceAndGoToForm(SportSchool sportSchoolSelected){

    setSportSchoolToEnrollIn(sportSchoolSelected);
    navigateToEnrollmentCreateSocialProfileSportSchool(context);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            appBar: searchBar.build(context),
            key: _scaffoldKey,
            body: FutureBuilder<SportSchool>(
              future: getAll(),
              builder: (context, snapshot) {
                return ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () =>_saveSharedPreferenceAndGoToForm(_filtered[index]),
                      title: Text(
                        _filtered[index].name,
                        style: TextStyle(fontSize: 20.0),
                      ),
                      subtitle: Text(_filtered[index].town + ", " + _filtered[index].province,
                          style: TextStyle(fontSize: 16.0)),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(_filtered[index].urlLogo),
                        radius: 24.0,
                      ),
                    );
                  },
                  itemCount: _filtered.length,
                );
              },
            )));
  }
}
