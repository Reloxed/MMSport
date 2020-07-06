import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

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

  String hasSchoolSport = "";

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Form(
                key: _formKey,
                autovalidate: false,
                child: ListView(
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
                              decoration: InputDecoration(

                              ),
                              initialValue: "",
                              attribute: "has_school_sport",
                              leadingInput: true,
                              onChanged: _handleRadioValueChange,
                              validators: [_checkSelectedRadioButton],
                              options: ["Sí", "No"]
                                  .map((lang) =>
                                  FormBuilderFieldOption(
                                    value: lang,
                                    child: Text('$lang', style: TextStyle(fontSize: 16.0),),
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
                ))));
  }

  Widget _logoImage() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Image.asset("assets/logo/Logo_MMSport_sin_fondo.png"));
  }

  Widget _emailField(String hintText) {
    IconData icon = null;
    icon = Icons.email;
    final RegExp emailRegex = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)$");
    return Container(
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (v) {
              if (v.isEmpty)
                return "Este campo no puede estar vacío";
              else if (!emailRegex.hasMatch(v)) {
                return "El email no es válido";
              } else
                return null;
            },
            obscureText: false,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: hintText,
                prefixIcon: Icon(icon)),
          )
        ],
      ),
    );
  }

  Widget _passwordField(String hintText) {
    IconData icon = null;
    icon = Icons.lock;
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _password,
            validator: (v) {
              if (v.isEmpty)
                return "Este campo no puede estar vacío";
              else if (v.length < 5)
                return "La contraseña tiene que tener más de 5 caracteres";
              else
                return null;
            },
            obscureText: true,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: hintText,
                prefixIcon: Icon(icon)),
          )
        ],
      ),
    );
  }

  Widget _confirmPasswordField(String hintText) {
    IconData icon = null;
    icon = Icons.check;
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _confirmPassword,
            validator: (v) {
              if (v.isEmpty)
                return "Este campo no puede estar vacío";
              else if (!identical(v, _password.text))
                return "La contraseña tiene que tener más de 5 caracteres";
              else
                return null;
            },
            obscureText: true,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: hintText,
                prefixIcon: Icon(icon)),
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
            onPressed: () {
              if (_formKey.currentState.validate()) {
                showDialog(
                    context: context,
                    child: AlertDialog(
                      title: Text("LMAO"),
                    ));
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

  String _checkSelectedRadioButton(dynamic v){
    if(v == ""){
      return "Debe de seleccionar una opción";
    }
  }
}
