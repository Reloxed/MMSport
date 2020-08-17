import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/components/form_validators.dart';
import 'package:mmsport/components/utils.dart';

class AddCalendarEvent extends StatefulWidget {
  @override
  _AddCalendarEventState createState() {
    return new _AddCalendarEventState();
  }
}

class _AddCalendarEventState extends State<AddCalendarEvent> {
  final _formKey = GlobalKey<FormState>();

  DateTime selectedDay;
  TimeOfDay selectedStartTimeSchedule;
  TimeOfDay selectedEndTimeSchedule;

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
                              _selectDateField(),
                              _selectScheduleField(),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[_createEvent()],
                        ),
                      ],
                    )))));
  }

  Widget _logoImage() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 50), child: Image.asset("assets/logo/Logo_MMSport_sin_fondo.png"));
    //return Image.asset("assets/logo/Logo_MMSport_sin_fondo.png");
  }

  Widget _selectDateField() {
    return Container();
  }

  Widget _selectScheduleField() {
    IconData icon = Icons.access_time;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: <Widget>[
          TextFormField(
            readOnly: true,
            validator: (v) {
              if (FormValidators.validateEmptyPassword(v) == false)
                return "Este campo no puede estar vacío";
              else
                return null;
            },
            obscureText: true,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Contraseña",
                prefixIcon: IconButton(
                  icon: Icon(icon),
                  onPressed: () {},
                )),
            onChanged: (value) => selectedStartTimeSchedule = stringToTimeOfDay(value),
          )
        ],
      ),
    );
  }

  Future<void> showStartTimeDialog(BuildContext context) async {
    TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    if(selectedTime != null){

    }
  }

  Widget _createEvent() {
    return Container(
        margin: EdgeInsets.only(top: 16),
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: RaisedButton(
            onPressed: () async {},
            elevation: 3.0,
            color: Colors.blueAccent,
            child: Text(
              "CREAR EVENTO",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ));
  }
}
