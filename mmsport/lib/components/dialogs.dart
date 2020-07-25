import 'package:flutter/material.dart';
import 'package:mmsport/navigations/navigations.dart';

dynamic errorDialog(BuildContext context, String message) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext builder) {
        return AlertDialog(
          title: new IconTheme(
            data: new IconThemeData(
              color: Colors.red,
            ),
            child: Icon(Icons.error),
          ),
          content: SingleChildScrollView(
              child: ListBody(children: <Widget>[
                Center(child: Text(message))
              ])),
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.all(Radius.circular(15.0))),
          actions: <Widget>[
            FlatButton(
              color: Colors.white,
              textColor: Colors.blueAccent,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Entendido"),
            )
          ],
        );
      });
}

dynamic confirmDialogOnCreateSchool(BuildContext context, String message) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext builder) {
        return AlertDialog(
          title: new IconTheme(
            data: new IconThemeData(
              color: Colors.green,
            ),
            child: Icon(Icons.check),
          ),
          content: SingleChildScrollView(
              child: ListBody(children: <Widget>[
                Center(child: Text(message))
              ])),
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.all(Radius.circular(15.0))),
          actions: <Widget>[
            FlatButton(
              color: Colors.white,
              textColor: Colors.blueAccent,
              onPressed: () {
                logout(context);
              },
              child: Text("Entendido"),
            )
          ],
        );
      });
}