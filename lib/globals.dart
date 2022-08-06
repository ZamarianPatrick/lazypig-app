library lazypig.globals;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

GraphQLClient gqlClient = GraphQLClient(
  link: HttpLink('http://lazypig.local:8080/graphql'),
  cache: GraphQLCache(),
);

ValueNotifier<GraphQLClient> gqlClientNotifier = ValueNotifier(gqlClient);

showAlertDialog(
    GlobalKey<ScaffoldState> _scaffoldKey, String title, String message) {
  // Create button
  Widget okButton = TextButton(
    child: const Text("OK"),
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
