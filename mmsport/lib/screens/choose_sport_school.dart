import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/models/global_variables.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:mmsport/navigations/navigations.dart';

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

  // ignore: missing_return
  Future<QuerySnapshot> _loadFirebaseData() async {
    String firebaseUser = loggedInUserId;
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
        if (sportSchools.containsKey(newSportSchool)) {
          sportSchools[newSportSchool] += 1;
        } else {
          sportSchools[newSportSchool] = 0;
        }
      });
    }
  }

  @override
  void initState() {
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
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: ListView(
                      children: <Widget>[
                        Container(height: MediaQuery.of(context).size.height * 0.5, child: _carouselSlider())
                      ], /*_pageIndicator()*/
                    ))),
          )),
          floatingActionButton: FloatingActionButton(
            onPressed: null,
            tooltip: 'Inscribirme en una escuela',
            child: IconButton(
              onPressed: () {},
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
      onPressed: () {},
      icon: new IconTheme(
          data: new IconThemeData(
            color: Colors.white,
          ),
          child: Icon(Icons.power_settings_new)),
    );
  }

  Widget _carouselSlider() {
    return PageView.builder(
      //options: CarouselOptions(autoPlay: false, enlargeCenterPage: true),
      //items: _cardViews(),
      itemCount: sportSchools.length,
      //carouselController: controller(),
      itemBuilder: (BuildContext context, int index) {
        return _cardView(index);
      },
    );
  }

  CarouselController controller() {
    return new CarouselController();
  }

  Widget _cardView(int index) {
    return Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
        margin: EdgeInsets.all(16.0),
        child: InkWell(
          onTap: () {
            navigateFromChooseSportSchoolToChooseSocialProfile(context);
          },
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                    radius: 85,
                    backgroundImage: NetworkImage(sportSchools.keys.elementAt(index).urlLogo),
                    child: ClipOval(
                      child: Image.network(
                        sportSchools.keys.elementAt(index).urlLogo,
                        fit: BoxFit.cover,
                        width: 64,
                        height: 64,
                      ),
                    )),
              ),
              Text(
                sportSchools.keys.elementAt(index).name,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Text(
                sportSchools.values.elementAt(index).toString() + ' Perfiles sociales verificados',
                style: TextStyle(fontSize: 12.0),
              ),
              OutlineButton.icon(
                onPressed: null,
                icon: new IconTheme(
                    data: new IconThemeData(
                      color: Colors.white,
                    ),
                    child: Icon(Icons.add)),
                label: Text(
                  'Añadir Perfil Social',
                  style: TextStyle(fontSize: 16.0),
                ),
                highlightElevation: 3.0,
                textColor: Colors.blueAccent,
                color: Colors.blueAccent,
              )
            ],
          ),
        ));
  }
}
