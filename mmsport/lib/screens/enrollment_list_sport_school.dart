import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:mmsport/constants/constants.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:mmsport/navigations/navigations.dart';
import 'package:search_app_bar/filter.dart';

class EnrollmentListSportSchool extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _EnrollmentListSportSchoolState();
  }
}

class _EnrollmentListSportSchoolState extends State<EnrollmentListSportSchool> {
  final List<SportSchool> _sportSchools = [];
  List<SportSchool> _filtered = [];
  TextEditingController controller = new TextEditingController();
  bool firstLoad = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // ignore: missing_return
  Future<List<SportSchool>> getAll() async {
    if (firstLoad) {
      await Firestore.instance
          .collection("sportSchools")
          .getDocuments()
          .then((value) => value.documents.forEach((element) async {
                SportSchool newSportSchool = SportSchool.sportSchoolFromMap(element.data);
                _sportSchools.add(newSportSchool);
              }));
      _filtered.addAll(_sportSchools);
    }
    return _filtered;
  }

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(title: new Text('Escuelas disponibles'));
  }

  void onChanged(String value) {
    _filtered.clear();
    if (value.isEmpty) {
      firstLoad = false;
      _filtered.addAll(_sportSchools);
    } else {
      for (SportSchool s in _sportSchools) {
        if (s.name.toLowerCase().contains(value.toLowerCase()) ||
            s.address.toLowerCase().contains(value.toLowerCase()) ||
            s.town.toLowerCase().contains(value.toLowerCase()) ||
            s.province.toLowerCase().contains(value.toLowerCase())) {
          _filtered.add(s);
        }
      }
    }
    setState(() {
      firstLoad = false;
    });
  }

  // ignore: missing_return
  Future<void> _saveSharedPreferenceAndGoToForm(SportSchool sportSchoolSelected) {
    setSportSchoolToEnrollIn(sportSchoolSelected);
    navigateToEnrollmentCreateSocialProfileSportSchool(context);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            appBar: buildAppBar(context),
            key: _scaffoldKey,
            body: FutureBuilder<List<SportSchool>>(
              future: getAll(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SafeArea(
                      child: Column(children: <Widget>[
                    Container(
                      child: new Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Card(
                          child: ListTile(
                            leading: new Icon(Icons.search),
                            title: new TextField(
                              controller: controller,
                              decoration: new InputDecoration(hintText: 'Buscar', border: InputBorder.none),
                              onChanged: onChanged,
                            ),
                            trailing: new IconButton(
                              icon: new Icon(Icons.cancel),
                              onPressed: () {
                                controller.clear();
                                onChanged('');
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        child: ListView.builder(
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () => _saveSharedPreferenceAndGoToForm(snapshot.data[index]),
                          title: Text(
                            snapshot.data[index].name,
                            style: TextStyle(fontSize: 20.0),
                          ),
                          subtitle: Text(snapshot.data[index].town + ", " + snapshot.data[index].province,
                              style: TextStyle(fontSize: 16.0)),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(snapshot.data[index].urlLogo),
                            radius: 24.0,
                          ),
                        );
                      },
                      itemCount: snapshot.data.length,
                    ))
                  ]));
                } else {
                  return CircularProgressIndicator();
                }
              },
            )));
  }
}
