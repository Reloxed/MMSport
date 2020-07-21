import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnrollmentCreateSocialProfileSportSchool extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _EnrollmentCreateSocialProfileSportSchoolState();
  }
}

class _EnrollmentCreateSocialProfileSportSchoolState extends State<EnrollmentCreateSocialProfileSportSchool> {
  final _formKey = new GlobalKey<FormState>();

  String nameProfile;
  String firstSurnameProfile;
  String secondSurnameProfile;
  String urlProfile;
  File imageProfile;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: _studentProfileForm())));
  }

  // Parent widget for the second page (director profile creation)

  Widget _studentProfileForm() {
    return Form(
        key: _formKey,
        autovalidate: false,
        child: ListView(
          children: <Widget>[
            _profileImage(),
            Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _nameProfileField(),
                    _firstSurnameProfileField(),
                    _secondSurnameProfileField(),
                  ],
                )),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _finishButton(),
              ],
            ),
          ],
        ));
  }

  // Profile image for the director

  Widget _profileImage() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 30.0),
        child: InkWell(
            onTap: () async {
              ImagePicker picker = ImagePicker();
              var _image = await picker.getImage(source: ImageSource.gallery);
              setState(() {
                imageProfile = File(_image.path);
              });
            },
            child: Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                  radius: 85,
                  child: ClipOval(
                      child: (imageProfile != null)
                          ? Image.file(
                        imageProfile,
                        fit: BoxFit.cover,
                        width: 150,
                        height: 150,
                      )
                          : Icon(Icons.camera_alt, size: 100.0))),
            )));
  }

  // Director's name

  Widget _nameProfileField() {
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
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Nombre"),
            onChanged: (value) => nameProfile = value,
          )
        ],
      ),
    );
  }

  // Director's first surname

  Widget _firstSurnameProfileField() {
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
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Primer apellido"),
            onChanged: (value) => firstSurnameProfile = value,
          )
        ],
      ),
    );
  }

  // Director's second surname

  Widget _secondSurnameProfileField() {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (v) {
              return null;
            },
            obscureText: false,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Segundo apellido"),
            onChanged: (value) => secondSurnameProfile = value,
          )
        ],
      ),
    );
  }

  // Button to finish the process

  Widget _finishButton() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: RaisedButton(
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              _uploadAndCreate();
            }
          },
          elevation: 3.0,
          color: Colors.blueAccent,
          child: Text(
            "INSCRIBIRSE",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Auxiliary method to create the sport school and its director social profile.

  void _uploadAndCreate() async {
    final databaseReference = Firestore.instance;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String jsonString =  preferences.getString("sportSchoolToEnrollIn");
    SportSchool sportSchool = SportSchool.sportSchoolFromMap(jsonDecode(jsonString));
    String sportSchoolId = sportSchool.id;
    if(imageProfile != null) {
      await uploadPicProfile(context);
    }
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    SocialProfile socialProfile = new SocialProfile("", firebaseUser.uid, nameProfile, firstSurnameProfile,
        secondSurnameProfile, "STUDENT", "PENDING", urlProfile, sportSchoolId, "");
    DocumentReference ref = await databaseReference.collection("socialProfiles").add({
      "userAccountId": socialProfile.userAccountId,
      "name": socialProfile.name,
      "firstSurname": socialProfile.firstSurname,
      "secondSurname": socialProfile.secondSurname,
      "role": socialProfile.role,
      "status": socialProfile.status,
      "urlImage": socialProfile.urlImage,
      "sportSchoolId": socialProfile.sportSchoolId,
      "groupId": socialProfile.groupId
    });
    await databaseReference.collection("socialProfiles").document(ref.documentID).setData({"id": ref.documentID}, merge: true);
  }

  String getRandomString(int length){
    const _chars = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  // Auxiliary method to upload image of profile to FirebaseStorage

  Future uploadPicProfile(BuildContext context) async {
    String fileName = nameProfile + firstSurnameProfile + secondSurnameProfile;
    StorageReference storageReference = FirebaseStorage.instance.ref().child(fileName + getRandomString(12));
    StorageUploadTask uploadTask = storageReference.putFile(imageProfile);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    var url = await taskSnapshot.ref.getDownloadURL();
    urlProfile = url;
  }
}