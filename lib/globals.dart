library lazypig.globals;

import 'package:flutter/material.dart';
import 'package:lazy_pig/colors.dart';

showMessageDialog(
    GlobalKey<ScaffoldState> _scaffoldKey, String title, String message) {
  // Create button
  Widget okButton = ElevatedButton(
    child: const Text("OK"),
    style: ElevatedButton.styleFrom(primary: MyColors.primary),
    onPressed: () {
      Navigator.of(_scaffoldKey.currentContext!).pop();
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: _scaffoldKey.currentContext!,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showMessageDialogContext(BuildContext context, String title, String message) {
  // Create button
  Widget okButton = ElevatedButton(
    child: const Text("OK"),
    style: ElevatedButton.styleFrom(primary: MyColors.primary),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showConfirmDialog(GlobalKey<ScaffoldState> _scaffoldKey, String title,
    String message, onConfirm) {
  // Create button
  Widget abortButton = ElevatedButton(
    child: const Text("Abbrechen"),
    style: ElevatedButton.styleFrom(primary: MyColors.secondary),
    onPressed: () {
      Navigator.of(_scaffoldKey.currentContext!).pop();
    },
  );

  Widget okButton = ElevatedButton(
    child: const Text("Bestätigen"),
    style: ElevatedButton.styleFrom(primary: MyColors.primary),
    onPressed: () {
      onConfirm();
      Navigator.of(_scaffoldKey.currentContext!).pop();
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      abortButton,
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: _scaffoldKey.currentContext!,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
