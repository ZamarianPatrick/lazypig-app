import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:lazy_pig/views/plant.dart';

import 'globals.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'LazyPig';

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: gqlClientNotifier,
      child: const MaterialApp(
        title: _title,
        home: PlantView(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
