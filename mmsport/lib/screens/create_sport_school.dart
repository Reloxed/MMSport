import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/components/form_validators.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/models/sportSchool.dart';

class CreateSportSchool extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _CreateSportSchoolState();
  }
}

class _CreateSportSchoolState extends State<CreateSportSchool> {
  final _formKey = new GlobalKey<FormState>();
  final _formKey2 = new GlobalKey<FormState>();
  PageController _controller = PageController(initialPage: 0);

  String nameSportSchool;
  String addressSportSchool;
  String townSportSchool;
  String provinceSportSchool;
  String urlLogo;
  String nameProfile;
  String firstSurnameProfile;
  String secondSurnameProfile;
  String urlProfile;

  File imageSchool;
  File imageProfile;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            body: Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _controller,
                  children: <Widget>[_sportSchoolForm(), _directorProfileForm()],
                ))));
  }

  // Parent widget for the first page (school creation)

  Widget _sportSchoolForm() {
    return Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: ListView(
          children: <Widget>[
            _logoImage(),
            Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[_nameSportSchoolField(), _addressField(), _townField(), _provinceField()],
            )),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _nextButton(),
              ],
            ),
          ],
        ));
  }

  // School's logo

  Widget _logoImage() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 30.0),
        child: InkWell(
            onTap: () async {
              ImagePicker picker = ImagePicker();
              var _image = await picker.getImage(source: ImageSource.gallery);
              setState(() {
                imageSchool = File(_image.path);
              });
            },
            child: Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                  radius: 85,
                  child: ClipOval(
                      child: (imageSchool != null)
                          ? Image.file(
                              imageSchool,
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                            )
                          : Icon(Icons.camera_alt, size: 100.0))),
            )));
  }

  // School's name

  Widget _nameSportSchoolField() {
    IconData icon = Icons.fitness_center;
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
            obscureText: false,
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: "Nombre de la escuela", prefixIcon: Icon(icon)),
            onChanged: (value) => nameSportSchool = value,
          )
        ],
      ),
    );
  }

  // School's address

  Widget _addressField() {
    IconData icon = Icons.location_on;
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            keyboardType: TextInputType.streetAddress,
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              if (FormValidators.validateNotEmpty(v) == false)
                return "Este campo no puede estar vacío";
              else
                return null;
            },
            obscureText: false,
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: "Dirección (C/ ejemplo, nºX)", prefixIcon: Icon(icon)),
            onChanged: (value) => addressSportSchool = value,
          )
        ],
      ),
    );
  }

  // School's town

  Widget _townField() {
    IconData icon = Icons.location_city;
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
            obscureText: false,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Municipio", prefixIcon: Icon(icon)),
            onChanged: (value) => townSportSchool = value,
          )
        ],
      ),
    );
  }

  // School's province

  Widget _provinceField() {
    IconData icon = Icons.map;
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
            obscureText: false,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Provincia", prefixIcon: Icon(icon)),
            onChanged: (value) => provinceSportSchool = value,
          )
        ],
      ),
    );
  }

  // Button to validate first form and go to the second page.

  Widget _nextButton() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: RaisedButton(
          onPressed: () async {
            // ignore: unrelated_type_equality_checks
            if (_formKey.currentState.validate() && imageSchool != null) {
              _controller.animateToPage(1, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
            } else {
              if (imageSchool == null) {
                errorDialog(context, "El logotipo es obligatorio.");
              } else {
                errorDialog(context, "Hay errores, corríjalos.");
              }
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

  // Parent widget for the second page (director profile creation)

  Widget _directorProfileForm() {
    return Form(
        key: _formKey2,
        autovalidateMode: AutovalidateMode.disabled,
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
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              if (FormValidators.validateNotEmpty(v) == false)
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
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              if (FormValidators.validateNotEmpty(v) == false)
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
            textCapitalization: TextCapitalization.words,
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
            if (_formKey2.currentState.validate()) {
              if (imageProfile != null) {
                loadingDialog(context);
                _uploadAndCreate();
                Navigator.of(context, rootNavigator: true).pop();
                confirmDialogOnCreateSchool(
                    context, "Escuela y perfil creados, espere a la confirmación de la administración.");
              } else {
                errorDialog(context, "La fotografía es obligatoria para los directores.");
              }
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

  // Auxiliary method to create the sport school and its director social profile.

  void _uploadAndCreate() async {
    if (imageSchool != null) {
      await uploadPicSchool(context);
    }
    SportSchool sportSchool =
        new SportSchool(nameSportSchool, addressSportSchool, townSportSchool, provinceSportSchool, "PENDING", urlLogo);
    final databaseReference = FirebaseFirestore.instance;
    DocumentReference ref = await databaseReference.collection("sportSchools").add({
      "name": sportSchool.name,
      "address": sportSchool.address,
      "town": sportSchool.town,
      "province": sportSchool.province,
      "status": sportSchool.status,
      "urlLogo": sportSchool.urlLogo
    });
    String sportSchoolId = ref.id;
    await databaseReference
        .collection("sportSchools")
        .doc(ref.id)
        .set({"id": ref.id},SetOptions(merge: true));
    if (imageProfile != null) {
      await uploadPicProfile(context);
    }
    User firebaseUser = FirebaseAuth.instance.currentUser;
    SocialProfile socialProfile = new SocialProfile("", firebaseUser.uid, nameProfile, firstSurnameProfile,
        secondSurnameProfile, "DIRECTOR", "PENDING", urlProfile, sportSchoolId, "");
    DocumentReference ref2 = await databaseReference.collection("socialProfiles").add({
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
    await databaseReference
        .collection("socialProfiles")
        .doc(ref2.id)
        .set({"id": ref2.id}, SetOptions(merge: true));
    User user = FirebaseAuth.instance.currentUser;
    await databaseReference
        .collection("directorsWithoutSportSchool")
        .where("id", isEqualTo: user.uid)
        .get()
        .then((value) => value.docs.forEach((element) {
              databaseReference.collection("directorsWithoutSportSchool").doc(element.id).delete();
            }));
    registerNotification(firebaseUser.uid);
  }

  String getRandomString(int length) {
    const _chars = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  // Auxiliary method to upload image of school to FirebaseStorage
  Future uploadPicSchool(BuildContext context) async {
    String fileName = nameSportSchool;
    StorageReference storageReference = FirebaseStorage.instance.ref().child(fileName + getRandomString(12));
    StorageUploadTask uploadTask = storageReference.putFile(imageSchool);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    var url = await taskSnapshot.ref.getDownloadURL();
    urlLogo = url;
  }

  // Auxiliary method to upload image of profile to FirebaseStorage

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

  void registerNotification(String userId) {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging();
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message){
      Platform.isAndroid
          ? showNotification(message['notification'])
          : showNotification(message['aps']['alert']);
      return;
    });

    firebaseMessaging.getToken().then((token) {
      FirebaseFirestore.instance.collection("socialProfiles").where("userAccountId", isEqualTo: userId).get()
          .then((value) => value.docs.forEach((element) {
        SocialProfile profile = SocialProfile.socialProfileFromMap(element.data());
        profile.id = element.id;
        FirebaseFirestore.instance.collection("socialProfiles").doc(profile.id).update({'pushToken': token});
      }));
    });
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.ittsport.ittsportapp'
          : '',
      'MMSport',
      '',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }
}
