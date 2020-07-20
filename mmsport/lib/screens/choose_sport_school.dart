import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:mmsport/navigations/navigations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ChooseSportSchool extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    _ChooseSportSchoolState state = new _ChooseSportSchoolState();
    return state;
  }
}

class _ChooseSportSchoolState extends State<ChooseSportSchool> {
  List<SocialProfile> profiles = new List();
  Map<SportSchool, int> sportSchools = new Map();
  List<String> sportSchoolIds = new List();
  double currentPage = 0.0;
  PageController _pageController = PageController();

  // ignore: missing_return
  Future<QuerySnapshot> _loadFirebaseData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String firebaseUser = preferences.get("loggedInUserId");
    await Firestore.instance
        .collection("socialProfiles")
        .where('userAccountId', isEqualTo: firebaseUser)
        .getDocuments()
        .then((value) => value.documents.forEach((element) {
              SocialProfile newProfile = SocialProfile.socialProfileFromMap(element.data);
              profiles.add(newProfile);
            }));
    for (SocialProfile actualProfile in profiles) {
      await Firestore.instance.collection('sportSchools').document(actualProfile.sportSchoolId).get().then((document) {
        SportSchool newSportSchool = SportSchool.sportSchoolFromMap(document.data);
        newSportSchool.id = actualProfile.sportSchoolId;
        if (sportSchoolIds.contains(newSportSchool.id)) {
          sportSchools[newSportSchool] += 1;
        } else if (!sportSchoolIds.contains(newSportSchool.id)) {
          sportSchools[newSportSchool] = 1;
          sportSchoolIds.add(newSportSchool.id);
        }
      });
    }
  }

  @override
  void initState() {
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: _loadFirebaseData(),
      builder: (context, profilesSnapshot) {
        if (!profilesSnapshot.hasData) {}
        return Material(
            child: Scaffold(
          appBar: AppBar(
            title: const Text('Mis escuelas'),
            centerTitle: true,
            actions: <Widget>[
              _logoutButton(),
            ],
          ),
          body: Center(
              child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Center(
                child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(height: MediaQuery.of(context).size.height * 0.5, child: _pageView()),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.all(16.0),
                            child: _smoothPageIndicator(),
                          ),
                        )
                      ],
                    ))),
          )),
          floatingActionButton: FloatingActionButton(
            onPressed: null,
            tooltip: 'Inscribirme en una escuela',
            child: IconButton(
              onPressed: () {
                navigateToInscriptionListSportSchool(context);
              },
              icon: new IconTheme(
                  data: new IconThemeData(
                    color: Colors.white,
                  ),
                  child: Icon(Icons.add)),
            ),
          ),
        ));
      },
    );
  }

  Widget _logoutButton() {
    return IconButton(
      onPressed: () {
        _logout();
      },
      icon: new IconTheme(
          data: new IconThemeData(
            color: Colors.white,
          ),
          child: Icon(Icons.power_settings_new)),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    logout(context);
  }

  Widget _pageView() {
    return PageView.builder(
      itemCount: sportSchools.length,
      controller: _pageController,
      itemBuilder: (BuildContext context, int index) {
        return _cardView(index);
      },
    );
  }

  Widget _smoothPageIndicator() {
    return SmoothPageIndicator(
      controller: _pageController, // PageController
      count: sportSchools.keys.length,
      effect: WormEffect(dotColor: Colors.grey, activeDotColor: Colors.blueAccent), // your preferred effect
    );
  }

  Widget _cardView(int index) {
    return Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
        child: InkWell(
          onTap: () async {
            SharedPreferences preferences = await SharedPreferences.getInstance();
            String sportSchoolToJson = jsonEncode(sportSchools.keys.elementAt(index).sportSchoolToJson());
            preferences.setString("chosenSportSchool", sportSchoolToJson);
            navigateToChooseSocialProfile(context);
          },
          child: Column(
            children: [
              Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(4.0, 16.0, 4.0, 4.0),
                    child: CircleAvatar(
                        radius: 65,
                        child: ClipOval(
                          child: Image.network(
                            sportSchools.keys.elementAt(index).urlLogo,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          ),
                        )),
                  )),
              Container(
                  margin: EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 0.0),
                  child: Text(
                    sportSchools.keys.elementAt(index).name,
                    style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
                  )),
              Container(
                  margin: EdgeInsets.fromLTRB(2.0, 8.0, 4.0, 0.0),
                  child: Text(
                    sportSchools.values.elementAt(index).toString() + ' Perfiles sociales verificados',
                    style: TextStyle(fontSize: 14.0),
                  )),
              Expanded(
                  child: Align(
                      alignment: Alignment.center,
                      child: Container(
                          margin: EdgeInsets.all(4.0),
                          child: OutlineButton.icon(
                            onPressed: () {
                              navigateToChooseSocialProfile(context);
                            },
                            icon: new IconTheme(
                                data: new IconThemeData(
                                  color: Colors.blueAccent,
                                ),
                                child: Icon(Icons.add)),
                            label: Text(
                              'Añadir Perfil Social',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            borderSide: BorderSide(color: Colors.blueAccent, style: BorderStyle.solid, width: 2.0),
                            textColor: Colors.blueAccent,
                            highlightElevation: 3.0,
                          ))))
            ],
          ),
        ));
  }
}
