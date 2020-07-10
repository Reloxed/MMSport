import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/models/global_variables.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ChooseSportSchool extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    _ChooseSportSchoolState state = new _ChooseSportSchoolState();
    return state;
  }
}

class _ChooseSportSchoolState extends State<ChooseSportSchool> {
  final _formKey = new GlobalKey<FormState>();
  PageController _controller = PageController(initialPage: 0);
  List<SocialProfile> profiles = new List();
  Map<SportSchool, int> sportSchools = new Map();
  int _currentPage = 0;

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
    _loadFirebaseData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: _loadFirebaseData(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> profilesSnapshot) {
        if (!profilesSnapshot.hasData) {
          //loading
        }
        return Material(
            child: Scaffold(
          appBar: AppBar(
            title: const Text('Mis escuelas'),
            centerTitle: true,
            actions: <Widget>[
              _logoutButton(),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                children: [Center(child: _carouselSlider()), _pageIndicator()],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: null,
            tooltip: 'Inscribirme en una escuela',
            child: IconButton(
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
      icon: new IconTheme(
          data: new IconThemeData(
            color: Colors.white,
          ),
          child: Icon(Icons.power_settings_new)),
    );
  }

  Widget _carouselSlider() {
    return CarouselSlider(
      options: CarouselOptions(autoPlay: false, enlargeCenterPage: true),
      items: _cardViews(),
    );
  }

  Widget _pageIndicator() {
    return SmoothPageIndicator(
      controller: controller(),
      count: sportSchools.length,
      effect: WormEffect(
          spacing: 8.0,
          radius: 4.0,
          dotWidth: 24.0,
          dotHeight: 16.0,
          paintStyle: PaintingStyle.stroke,
          strokeWidth: 1.5,
          dotColor: Colors.grey,
          activeDotColor: Colors.blueAccent),
    );
  }

  PageController controller() {
    return new PageController(initialPage: 0);
  }

  List<Widget> _cardViews() {
    List<Widget> cardViews = new List();
    for (SportSchool actualSportSchool in sportSchools.keys) {
      cardViews.add(
        Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
          margin: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                    radius: 85,
                    backgroundImage: NetworkImage(actualSportSchool.urlLogo),
                    child: ClipOval(
                      child: Image.network(
                        actualSportSchool.urlLogo,
                        fit: BoxFit.cover,
                        width: 64,
                        height: 64,
                      ),
                    )),
              ),
              Text(
                actualSportSchool.name,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              Text(
                sportSchools[actualSportSchool].toString() + ' Perfiles sociales verificados',
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
        ),
      );
    }

    return cardViews;
  }
}
