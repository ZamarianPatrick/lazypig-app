import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/drawer.dart';
import '../components/topbar.dart';

class TemplateView extends StatelessWidget {
  const TemplateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        appBar: TopBar(title: 'Vorlagen', icon: Icons.library_books_outlined),
        body: Text('Vorlagen'),
        drawer: LazyPigDrawer());
  }
}
