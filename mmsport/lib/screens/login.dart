import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/Navigations/navigations.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() {
    return new _LoginState();
  }
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Form(
                key: _formKey,
                autovalidate: false,
                child: Stack(
              children: <Widget>[
                _logoImage(),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _textField("Correo electrónico", false),
                      _textField("Contraseña", true),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _button(),
                    _registerYet()
                  ],
                ),
              ],
            ))));
  }

  Widget _logoImage(){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 50),
      child: Image.asset("assets/logo/Logo_MMSport_sin_fondo.png")
    );
    //return Image.asset("assets/logo/Logo_MMSport_sin_fondo.png");
  }

  Widget _textField(String hintText, bool isPassword) {
    IconData icon = null;
    String text = "";
    if (isPassword) {
      icon = Icons.lock;
    } else {
      icon = Icons.email;
    }
    final RegExp emailRegex = new RegExp(
        r"^[a-zA-Z0-9.!#$%&'+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)$");
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (v) {
              if (v.isEmpty)
                return "Este campo no puede estar vacío";
              else if (!emailRegex.hasMatch(v) && isPassword == false) {
                return "El email no es válido";
              } else if (v.length < 5 && isPassword == true)
                return "La contraseña tiene que tener más de 5 caracteres";
                else return null;
            },
            obscureText: isPassword,
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
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: SizedBox(
          width: double.infinity,
          child: RaisedButton(
            onPressed: () {
              if(_formKey.currentState.validate()){
                showDialog(context: context, child: AlertDialog(
                  title: Text("LMAO"),
                ));
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

  Widget _registerYet(){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: <Widget>[
          new Text(
            "¿Aún no te has registrado?",
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
          new GestureDetector(
            onTap: () {
              navigateFromLoginToRegister(context);
            },
            child: new Text(
              "¡Regístrate!",
              style: TextStyle(fontSize: 15, color: Colors.black, decoration: TextDecoration.underline),
            ),
          )
        ]
      )
    );
  }
}
