import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import "package:mmsport/models/global_variables.dart";
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/navigations/navigations.dart';

class ChooseSocialProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    _ChooseSocialProfileState state = new _ChooseSocialProfileState();
    return state;
  }
}

class _ChooseSocialProfileState extends State<ChooseSocialProfile> {
  List<SocialProfile> socialProfiles = new List();

  // ignore: missing_return
  Future<QuerySnapshot> _loadFirebaseData() async {
    await Firestore.instance
        .collection("socialProfiles")
        .where("userAccountId", isEqualTo: loggedInUserId)
        .where("sportSchoolId", isEqualTo: chosenSportSchoolId)
        .getDocuments()
        .then((value) => value.documents.forEach((element) {
              SocialProfile newProfile = SocialProfile.socialProfileFromMap(element.data);
              socialProfiles.add(newProfile);
            }));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: _loadFirebaseData(),
      builder: (context, snapshot) {
        return Material(
            child: Scaffold(
          appBar: AppBar(
            leading: new IconButton(
                icon: new Icon(Icons.arrow_back),
                onPressed: () {
                  chosenSportSchoolId = "";
                  navigateToChooseSportSchool(context);
                }),
            title: const Text("Perfiles sociales"),
            centerTitle: true,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Center(child: SizedBox(height: MediaQuery.of(context).size.height * 0.55, child: _pageView())),
            ),
          ),
        ));
      },
    );
  }

  Widget _cardView(int index) {
    return Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
        margin: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Align(
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.all(10.0),
                  child: CircleAvatar(
                      radius: 85,
                      child: ClipOval(
                        child: Image.network(
                          socialProfiles.elementAt(index).urlImage,
                          fit: BoxFit.cover,
                          width: 150,
                          height: 150,
                        ),
                      )),
                )),
            Container(
                margin: EdgeInsets.all(5.0),
                child: Text(
                  socialProfiles.elementAt(index).name,
                  style: TextStyle(fontSize: 20.0),
                )),
            Container(
                margin: EdgeInsets.all(5.0),
                child: Text(
                  socialProfiles.elementAt(index).firstSurname,
                  style: TextStyle(fontSize: 20.0),
                )),
            Container(
                margin: EdgeInsets.all(5.0),
                child: Text(
                  socialProfiles.elementAt(index).secondSurname,
                  style: TextStyle(fontSize: 20.0),
                ))
          ],
        ));
  }

  Widget _pageView() {
    return PageView.builder(
        itemCount: socialProfiles.length,
        itemBuilder: (BuildContext context, int index) {
          return _cardView(index);
        });
  }
}
