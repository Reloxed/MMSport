import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/components/form_validators.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() {
    return new _ResetPasswordState();
  }
}

class _ResetPasswordState extends State<ResetPassword> {
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
                              _emailTextField(),
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
    return Container(margin: EdgeInsets.only(bottom: 50), child: Image.asset("assets/logo/Logo_MMSport_sin_fondo.png"));
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

  Widget _button() {
    return Container(
        margin: EdgeInsets.only(top: 16),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                try {
                  await _auth.sendPasswordResetEmail(email: email).then((value) {
                    acceptDialogRegister(context, "Se ha enviado una nueva contraseña al correo $email");
                  });
                } catch (e) {
                  if(e.code == "ERROR_USER_NOT_FOUND"){
                    errorDialog(context, "No existe una cuenta con este correo electrónico");
                  }
                }
              }
            },
            elevation: 3.0,
            color: Colors.blueAccent,
            child: Center(
              child: Text(
                "RESTABLECER CONTRASEÑA",
                style: TextStyle(fontSize: 20, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            )
          ),
        ));
  }
}
