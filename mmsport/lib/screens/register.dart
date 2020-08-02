import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/components/form_validators.dart';
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
                              _emailField("Correo electrónico"),
                              _passwordField("Contraseña"),
                              _confirmPasswordField("Confirmar contraseña"),
                              Container(
                                margin: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  "¿Tienes una escuela?",
                                  style: TextStyle(fontSize: 20.0),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 4.0),
                                child: FormBuilderRadio(
                                  decoration: InputDecoration(),
                                  initialValue: "",
                                  attribute: "has_school_sport",
                                  leadingInput: true,
                                  onChanged: _handleRadioValueChange,
                                  validators: [_checkSelectedRadioButton],
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
                          children: <Widget>[_button()],
                        ),
                      ],
                    )))));
  }

  Widget _logoImage() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Image.asset("assets/logo/Logo_MMSport_sin_fondo.png"));
  }

  Widget _emailField(String hintText) {
    IconData icon;
    icon = Icons.email;
    final RegExp emailRegex = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)$");
    return Container(
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
              if (FormValidators.validateEmptyPassword(v) == false)
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
              if (FormValidators.validateEmptyPassword(v) == false)
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
          onPressed: () async {
            try {
              if (_formKey.currentState.validate()) {
                final FirebaseUser newUser = (await _auth.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                ))
                    .user;

                if (newUser != null) {
                  if (hasSchoolSport == "Sí") {
                    navigateToCreateSchool(context);
                  } else {

                  }
                }
              }
            } catch (e) {
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
              setState(() {
                errorDialog(context, message);
              });
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
}
