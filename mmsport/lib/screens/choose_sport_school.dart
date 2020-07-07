import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ChooseSportSchool extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ChooseSportSchoolState();
  }
}

class _ChooseSportSchoolState extends State<ChooseSportSchool> {
  final _formKey = new GlobalKey<FormState>();
  PageController _controller = PageController(initialPage: 0);

  String nameSportSchool;
  String addressSportSchool;
  String townSportSchool;
  String provinceSportSchool;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Mis escuelas'),
              centerTitle: true,
              actions: <Widget>[
                _logoutButton(),
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 50.0),
              child: Center(
                child: _carouselSlider(),
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
        ),));
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

  Widget _carouselSlider(){

  }

  Widget _cardViews(){

  }
}
