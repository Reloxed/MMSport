import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/components/form_validators.dart';
import 'package:mmsport/components/privacy_policy.dart';
import 'package:mmsport/components/terms_and_conditions.dart';
import 'package:mmsport/navigations/navigations.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() {
    return new _RegisterState();
  }
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String email;
  String password;

  String hasSchoolSport = "";

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.blue,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
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
                              _emailField("Correo electrónico"),
                              _passwordField("Contraseña"),
                              _confirmPasswordField("Confirmar contraseña"),
                              Container(
                                margin: const EdgeInsets.only(top: 24.0),
                                child: Text(
                                  "¿Eres director de una escuela deportiva?",
                                  style: TextStyle(fontSize: 20.0),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 4.0),
                                child: FormBuilderRadioGroup(
                                  decoration: InputDecoration(),
                                  initialValue: "",
                                  name: "has_school_sport",
                                  onChanged: _handleRadioValueChange,
                                  validator: _checkSelectedRadioButton,
                                  options: ["Sí", "No"]
                                      .map((lang) => FormBuilderFieldOption(
                                            value: lang,
                                            child: Text(
                                              '$lang',
                                              style: TextStyle(fontSize: 16.0),
                                            ),
                                          ))
                                      .toList(growable: false),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[termsAndConditions(), _button()],
                        ),
                      ],
                    )))));
  }

  Widget _logoImage() {
    return Container(margin: EdgeInsets.only(bottom: 50), child: Image.asset("assets/logo/Logo_MMSport_sin_fondo.png"));
  }

  Widget _emailField(String hintText) {
    IconData icon;
    icon = Icons.email;
    return Container(
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
            obscureText: false,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: hintText, prefixIcon: Icon(icon)),
            onChanged: (value) => email = value,
          )
        ],
      ),
    );
  }

  Widget _passwordField(String hintText) {
    IconData icon;
    icon = Icons.lock;
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _password,
            validator: (v) {
              if (FormValidators.validateEmptyText(v) == false)
                return "Este campo no puede estar vacío";
              else if (FormValidators.validateShortPassword(v) == false)
                return "La contraseña tiene que tener más de 5 caracteres";
              else
                return null;
            },
            obscureText: true,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: hintText, prefixIcon: Icon(icon)),
            onChanged: (value) => password = value,
          )
        ],
      ),
    );
  }

  Widget _confirmPasswordField(String hintText) {
    IconData icon;
    icon = Icons.check;
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _confirmPassword,
            validator: (v) {
              if (FormValidators.validateEmptyText(v) == false)
                return "Este campo no puede estar vacío";
              else if (v != _password.text)
                return "Las contraseñas no coinciden";
              else
                return null;
            },
            obscureText: true,
            decoration: InputDecoration(border: OutlineInputBorder(), labelText: hintText, prefixIcon: Icon(icon)),
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
                loadingDialog(context);
                final User newUser = (await _auth.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                ))
                    .user;

                if (newUser != null) {
                  if (hasSchoolSport == "Sí") {
                    await FirebaseFirestore.instance.collection("directorsWithoutSportSchool").add({"id": newUser.uid});
                    Navigator.of(context, rootNavigator: true).pop();
                  } else {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                  try {
                    await newUser.sendEmailVerification();
                    if (hasSchoolSport == "Sí") {
                      await acceptDialogRegister(context,
                          "Le hemos enviado un email para verificar la cuenta. Recuerde que antes de iniciar sesión debe de verificar la cuenta");
                      navigateToCreateSchool(context);
                    } else {
                      acceptDialogRegister(context,
                          "Le hemos enviado un email para verificar la cuenta. Recuerde que antes de iniciar sesión debe de verificar la cuenta");
                    }
                  } catch (e) {
                    errorDialog(context, "No se le ha podido enviar el email para verificar la cuenta");
                  }
                }
              }
            } catch (e) {
              Navigator.of(context, rootNavigator: true).pop();
              String message;
              if (e.code == "ERROR_INVALID_EMAIL") {
                message = "El email no es válido";
              } else if (e.code == "ERROR_EMAIL_ALREADY_IN_USE") {
                message = "El email ya está en uso";
              } else if (e.code == "ERROR_WEAK_PASSWORD") {
                message = "La contraseña es demasiado débil";
              } else {
                message = "Ha ocurrido un error";
              }
              errorDialog(context, message);
            }
          },
          elevation: 3.0,
          color: Colors.blueAccent,
          child: Text(
            "REGISTRARSE",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _handleRadioValueChange(dynamic value) {
    setState(() {
      hasSchoolSport = value;
    });
  }

  // ignore: missing_return
  String _checkSelectedRadioButton(dynamic v) {
    if (v == "") {
      return "Debe de seleccionar una opción";
    }
  }

  Widget termsAndConditions() {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      child: Center(
          child: RichText(
        text: TextSpan(
            text: 'Al registrarte, estás aceptando nuestros ',
            style: TextStyle(fontSize: 8.0, color: Colors.black),
            children: <TextSpan>[
              TextSpan(
                  text: 'Términos y Condiciones',
                  style: TextStyle(
                    fontSize: 8.0,
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => TermsAndConditionsDialog(), fullscreenDialog: true),
                      ); // code to open / launch privacy policy link here
                    }),
              TextSpan(text: ' y nuestra ', style: TextStyle(fontSize: 8.0, color: Colors.black), children: <TextSpan>[
                TextSpan(
                    text: 'Política de Privacidad',
                    style: TextStyle(fontSize: 8.0, color: Colors.blueAccent, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => PrivacyPolicyDialog(), fullscreenDialog: true),
                        ); // code to open / launch privacy policy link here
                      })
              ])
            ]),
      )),
    );
  }
}
