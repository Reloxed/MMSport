import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/components/form_validators.dart';
import 'package:mmsport/navigations/navigations.dart';
import 'package:mmsport/components/dialogs.dart';
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
            body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                    key: _formKey,
                    autovalidate: false,
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
                          children: <Widget>[_button(), _registerYet()],
                        ),
                      ],
                    )))));
  }

  Widget _logoImage() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 50), child: Image.asset("assets/logo/Logo_MMSport_sin_fondo.png"));
    //return Image.asset("assets/logo/Logo_MMSport_sin_fondo.png");
  }

  Widget _emailTextField() {
    IconData icon = Icons.email;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: <Widget>[
          TextFormField(
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
              if (FormValidators.validateEmptyPassword(v) == false)
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
            onPressed: () async {
              try {
                if (_formKey.currentState.validate()) {
                  final FirebaseUser user =
                      (await _auth.signInWithEmailAndPassword(email: email, password: password)).user;

                  if (user != null) {
                    SharedPreferences preferences = await SharedPreferences.getInstance();
                    preferences.setString("loggedInUserId", user.uid);
                    await Firestore.instance
                        .collection("admins")
                        .where("userId", isEqualTo: user.uid)
                        .getDocuments()
                        .then((value) => value.documents.length != 0
                            ? navigateToHome(context)
                            : navigateToChooseSportSchool(context));
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

  Widget _registerYet() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(children: <Widget>[
              new Text(
                "¿Aún no te has registrado?",
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              new GestureDetector(
                onTap: () {
                  navigateToRegister(context);
                },
                child: new Text(
                  "¡Regístrate!",
                  style: TextStyle(fontSize: 15, color: Colors.black, decoration: TextDecoration.underline),
                ),
              )
            ])));
  }
}
