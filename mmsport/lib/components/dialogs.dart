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
          content: SingleChildScrollView(child: ListBody(children: <Widget>[Center(child: Text(message))])),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
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

dynamic loadingDialog(BuildContext context) {
  return showDialog(context: context, barrierDismissible: false, builder: (BuildContext builder){
    return AlertDialog(
      title: Image.asset("assets/logo/loading_gif.gif"),
      content: Text("Un momento, por favor...", style: TextStyle(fontSize: 20)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
    );
  });
}

dynamic loading(){
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset("assets/logo/loading_gif.gif"),
        Text("Un momento, por favor...", style: TextStyle(fontSize: 20))
      ],
    ),
  );
}

dynamic loadingHome(){
  return Scaffold(
    body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset("assets/logo/loading_gif.gif"),
          Text("Un momento, por favor...", style: TextStyle(fontSize: 20))
        ],
      ),
    ),
  );
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
          content: SingleChildScrollView(child: ListBody(children: <Widget>[Center(child: Text(message))])),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
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
