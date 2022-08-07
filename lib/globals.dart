library lazypig.globals;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:lazy_pig/colors.dart';

GraphQLClient gqlClient = GraphQLClient(
  link: HttpLink('http://lazypig.local:8080/graphql'),
  cache: GraphQLCache(),
);

ValueNotifier<GraphQLClient> gqlClientNotifier = ValueNotifier(gqlClient);

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
