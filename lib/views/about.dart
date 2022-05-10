import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/drawer.dart';
import '../components/topbar.dart';

class AboutView extends StatelessWidget {
  const AboutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        appBar: TopBar(
          title: 'Über',
          icon: Icons.info,
        ),
        body: Text('Über'),
        drawer: LazyPigDrawer());
  }
}
