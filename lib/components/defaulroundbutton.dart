import 'package:flutter/material.dart';

class Defaultbuttondesign extends StatelessWidget {
  Defaultbuttondesign({this.onPressed, this.textdata, this.buttoncolor});
  final Function onPressed;
  final String textdata;
  final Color buttoncolor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        color: buttoncolor,
        borderRadius: BorderRadius.circular(30.0),
        elevation: 5.0,
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(textdata),
          textColor: Colors.white,
        ),
      ),
    );
  }
}
