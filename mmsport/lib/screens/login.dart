import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/components/form_validators.dart';
import 'package:mmsport/models/socialProfile.dart';
import 'package:mmsport/navigations/navigations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() {
    return new _LoginState();
  }
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  String email;
  String password;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      children: <Widget>[
                        _logoImage(),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _emailTextField(),
                              _passwordTextField(),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[_button(), _forgotPassword(), _registerYet()],
                        ),
                      ],
                    )))));
  }

  Widget _logoImage() {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 50.0), child: Image.asset("assets/logo/Logo_MMSport_sin_fondo.png"));
  }

  Widget _emailTextField() {
    IconData icon = Icons.email;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: <Widget>[
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (FormValidators.validateEmptyEmail(v) == false)
                return "Este campo no puede estar vacío";
              else if (FormValidators.validateValidEmail(v) == false) {
                return "El email no es válido";
              } else
                return null;
            },
            decoration:
                InputDecoration(border: OutlineInputBorder(), labelText: "Correo electrónico", prefixIcon: Icon(icon)),
            onChanged: (value) => email = value,
          )
        ],
      ),
    );
  }

  Widget _passwordTextField() {
    IconData icon = Icons.lock;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (v) {
              if (FormValidators.validateEmptyText(v) == false)
                return "Este campo no puede estar vacío";
              else if (FormValidators.validateShortPassword(v) == false)
                return "La contraseña tiene que tener más de 5 caracteres";
              else
                return null;
            },
            obscureText: true,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Contraseña", prefixIcon: Icon(icon)),
            onChanged: (value) => password = value,
          )
        ],
      ),
    );
  }

  Widget _button() {
    return Container(
        margin: EdgeInsets.only(top: 16),
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            onPressed: () async {
              try {
                if (_formKey.currentState.validate()) {
                  final User user =
                      (await _auth.signInWithEmailAndPassword(email: email, password: password)).user;

                  if (user != null) {
                    if (user.emailVerified) {
                      bool withoutSportSchoolCreated = false;
                      SharedPreferences preferences = await SharedPreferences.getInstance();
                      preferences.setString("loggedInUserId", user.uid);
                      await FirebaseFirestore.instance
                          .collection("directorsWithoutSportSchool")
                          .where("id", isEqualTo: user.uid)
                          .get()
                          .then((value) {
                        if (value.docs.length > 0) {
                          navigateToCreateSchool(context);
                          withoutSportSchoolCreated = true;
                        }
                      });
                      if (!withoutSportSchoolCreated) {
                        await FirebaseFirestore.instance
                            .collection("admins")
                            .where("userId", isEqualTo: user.uid)
                            .get()
                            .then((value) => value.docs.length != 0
                                ? navigateToHome(context)
                                : navigateToChooseSportSchool(context));
                        registerNotification(user.uid);
                      }
                    } else {
                      await user.sendEmailVerification();
                      errorDialog(
                          context, "Necesita verificar su cuenta. Le hemos vuelto a enviar otro correo de verificación.");
                    }
                  }
                }
              } catch (e) {
                String message;
                if (e.code == "ERROR_USER_NOT_FOUND") {
                  message = "El usuario no existe";
                } else if (e.code == "ERROR_WRONG_PASSWORD") {
                  message = "La contraseña no es correcta";
                } else {
                  message = "Ha ocurrido un error";
                }
                setState(() {
                  errorDialog(context, message);
                });
              }
            },
            elevation: 3.0,
            color: Colors.blueAccent,
            child: Text(
              "INICIAR SESIÓN",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ));
  }

  Widget _forgotPassword() {
    return Container(
        margin: EdgeInsets.only(bottom: 12),
        child: FlatButton(
          child: Text(
            "Olvidé mi contraseña",
            style: TextStyle(color: Colors.blueAccent, fontSize: 14.0),
          ),
          onPressed: () {
            navigateToResetPassword(context);
          },
        ));
  }

  Widget _registerYet() {
    return Container(
        margin: EdgeInsets.only(top: 16.0),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(children: <Widget>[
              new Text(
                "¿Aún no te has registrado?",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              FlatButton(
                onPressed: () {
                  navigateToRegister(context);
                },
                child: new Text(
                  "¡Regístrate!",
                  style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                ),
              )
            ])));
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

  }
}
