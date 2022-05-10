import 'package:flutter/material.dart';
import 'package:lazy_pig/views/plant.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: PlantView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
