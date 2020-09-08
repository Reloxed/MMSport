import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/components/form_validators.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/navigations/navigations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditSocialProfile extends StatefulWidget {
  @override
  State createState() {
    return new _EditSocialProfileState();
  }
}

class _EditSocialProfileState extends State<EditSocialProfile> {
  final _formKey = new GlobalKey<FormState>();
  SocialProfile chosenSocialProfile;

  String nameProfile;
  String firstSurnameProfile;
  String secondSurnameProfile;
  String urlProfile;

  File imageProfile;

  Future<SocialProfile> getChosenProfile() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Map aux = jsonDecode(preferences.get("chosenSocialProfile"));
    chosenSocialProfile = SocialProfile.socialProfileFromMap(aux);
    chosenSocialProfile.id = aux['id'];
    return chosenSocialProfile;
  }

  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            appBar: AppBar(
              title: Text("Editar mi perfil"),
              centerTitle: true,
            ),
            body: FutureBuilder(
              future: getChosenProfile(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  nameProfile = snapshot.data.name;
                  firstSurnameProfile = snapshot.data.firstSurname;
                  secondSurnameProfile = snapshot.data.secondSurname;
                  urlProfile = snapshot.data.urlImage;
                  return Container(
                      padding: EdgeInsets.symmetric(horizontal: 30), child: _directorProfileForm(snapshot.data));
                } else {
                  return loading();
                }
              },
            )));
  }

  Widget _directorProfileForm(SocialProfile socialProfile) {
    return Form(
        key: _formKey,
        autovalidate: false,
        child: ListView(
          children: <Widget>[
            _profileImage(socialProfile.urlImage),
            Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _nameProfileField(socialProfile.name),
                    _firstSurnameProfileField(socialProfile.firstSurname),
                    _secondSurnameProfileField(socialProfile.secondSurname),
                  ],
                )),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _finishButton(socialProfile),
              ],
            ),
          ],
        ));
  }

// Profile image for the director

  Widget _profileImage(String urlImage) {
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
                          : urlImage != null
                          ? Image.network(
                        urlImage,
                        fit: BoxFit.cover,
                        width: 150,
                        height: 150,
                      )
                          : Icon(Icons.camera_alt, size: 100.0))),
            )));
  }

// Director's name

  Widget _nameProfileField(String name) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              if (FormValidators.validateNotEmpty(v) == false)
                return "Este campo no puede estar vacío";
              else
                return null;
            },
            initialValue: name,
            obscureText: false,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Nombre"),
            onChanged: (value) => nameProfile = value,
          )
        ],
      ),
    );
  }

// Director's first surname

  Widget _firstSurnameProfileField(String firstSurname) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              if (FormValidators.validateNotEmpty(v) == false)
                return "Este campo no puede estar vacío";
              else
                return null;
            },
            initialValue: firstSurname,
            obscureText: false,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Primer apellido"),
            onChanged: (value) => firstSurnameProfile = value,
          )
        ],
      ),
    );
  }

// Director's second surname

  Widget _secondSurnameProfileField(String secondSurname) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              return null;
            },
            initialValue: secondSurname != null ? secondSurname : "",
            obscureText: false,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Segundo apellido"),
            onChanged: (value) => secondSurnameProfile = value,
          )
        ],
      ),
    );
  }

// Button to finish the process

  Widget _finishButton(SocialProfile oldProfile) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: RaisedButton(
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              loadingDialog(context);
              _uploadAndCreate(oldProfile);
              Navigator.of(context, rootNavigator: true).pop();
              navigateToHome(context);
            } else {
              errorDialog(context, "Hay errores, corríjalos.");
            }
          },
          elevation: 3.0,
          color: Colors.blueAccent,
          child: Text(
            "FINALIZAR",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _uploadAndCreate(SocialProfile oldProfile) async {
    if (imageProfile != null) {
      StorageReference ref = await FirebaseStorage.instance.getReferenceFromUrl(oldProfile.urlImage);
      await ref.delete();
      await uploadPicProfile(context);
    }
    await Firestore.instance.collection("socialProfiles").document(oldProfile.id).setData({
      "name": nameProfile,
      "firstSurname": firstSurnameProfile,
      "secondSurname": secondSurnameProfile,
      "urlImage": urlProfile,
    }, merge: true);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    SocialProfile newProfile = SocialProfile(
        oldProfile.id,
        oldProfile.userAccountId,
        nameProfile,
        firstSurnameProfile,
        secondSurnameProfile,
        oldProfile.role,
        oldProfile.status,
        urlProfile,
        oldProfile.sportSchoolId,
        oldProfile.groupId);
    String newProfileToJson = jsonEncode(newProfile.socialProfileToJson());
    preferences.setString("chosenSocialProfile", newProfileToJson);
  }

  String getRandomString(int length) {
    const _chars = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  Future uploadPicProfile(BuildContext context) async {
    String fileName;
    if (secondSurnameProfile != null) {
      fileName = nameProfile + firstSurnameProfile + secondSurnameProfile;
    } else {
      fileName = nameProfile + firstSurnameProfile;
    }
    StorageReference storageReference = FirebaseStorage.instance.ref().child(fileName + getRandomString(12));
    StorageUploadTask uploadTask = storageReference.putFile(imageProfile);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    var url = await taskSnapshot.ref.getDownloadURL();
    urlProfile = url;
  }
}
