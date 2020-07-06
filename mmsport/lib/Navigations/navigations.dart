
import 'package:flutter/material.dart';
import 'package:mmsport/screens/register.dart';

void navigateFromLoginToRegister(BuildContext context){
  Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
}