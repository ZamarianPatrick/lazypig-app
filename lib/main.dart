import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lazy_pig/backend.dart';
import 'package:lazy_pig/globals.dart';
import 'package:lazy_pig/views/connect.dart';
import 'package:lazy_pig/views/plant.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'LazyPig';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Builder(builder: (context) {
        backend.onDisconnect = () {
          if (!kIsWeb) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ConnectView()));
            showMessageDialogContext(context, "Verbindungsfehler",
                "Verbindung zum Server verloren...");
          }
        };

        return ((kIsWeb) ? const PlantView() : const ConnectView());
      }),
      debugShowCheckedModeBanner: false,
    );
  }
}
