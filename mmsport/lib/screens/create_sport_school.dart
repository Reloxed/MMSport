

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateSportSchool extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return new _CreateSportSchoolState();
  }

}

class _CreateSportSchoolState extends State<CreateSportSchool>{
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
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: PageView(
              controller: _controller,
              children: <Widget>[
                _sportSchoolForm(),
              ],
            )
        )
    ));
  }

  Widget _sportSchoolForm(){
    return ListView(
      children: <Widget>[
        _logoImage(),
        Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _nameSportSchoolField(),
                _addressField(),
                _townField(),
                _provinceField()
              ],
            )
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _nextButton(),
          ],
        ),
      ],
    );
  }

  Widget _logoImage() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Image.asset("assets/logo/Logo_MMSport_sin_fondo.png"));
  }

  Widget _nameSportSchoolField(){
    IconData icon = Icons.fitness_center;
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (v) {
              if (v.isEmpty)
                return "Este campo no puede estar vacío";
              else
                return null;
            },
            obscureText: false,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Nombre de la escuela",
                prefixIcon: Icon(icon)),
            onChanged: (value) => nameSportSchool = value,
          )
        ],
      ),
    );
  }

  Widget _addressField(){
    IconData icon = Icons.location_on;
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (v) {
              if (v.isEmpty)
                return "Este campo no puede estar vacío";
              else
                return null;
            },
            obscureText: false,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Dirección (C/ ejemplo, nºX)",
                prefixIcon: Icon(icon)),
            onChanged: (value) => addressSportSchool = value,
          )
        ],
      ),
    );
  }

  Widget _townField(){
    IconData icon = Icons.location_city;
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (v) {
              if (v.isEmpty)
                return "Este campo no puede estar vacío";
              else
                return null;
            },
            obscureText: false,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Municipio",
                prefixIcon: Icon(icon)),
            onChanged: (value) => townSportSchool = value,
          )
        ],
      ),
    );
  }

  Widget _provinceField(){
    IconData icon = Icons.map;
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (v) {
              if (v.isEmpty)
                return "Este campo no puede estar vacío";
              else
                return null;
            },
            obscureText: false,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Provincia",
                prefixIcon: Icon(icon)),
            onChanged: (value) => provinceSportSchool = value,
          )
        ],
      ),
    );
  }

  Widget _nextButton() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: RaisedButton(
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              _controller.animateTo(1);
            }
          },
          elevation: 3.0,
          color: Colors.blueAccent,
          child: Text(
            "SIGUIENTE",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }

}
