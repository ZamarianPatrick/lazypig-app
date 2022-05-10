import 'package:flutter/material.dart';
import 'package:lazy_pig/views/about.dart';
import 'package:lazy_pig/views/plant.dart';

import '../colors.dart';
import '../views/template.dart';

class LazyPigDrawer extends StatelessWidget {
  const LazyPigDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          minWidth: 150, maxWidth: MediaQuery.of(context).size.width * 0.5),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 64,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: MyColors.primary,
                ),
                child: Text('Menü'),
              ),
            ),
            CustomListTile(
                Icons.local_florist,
                'Pflanzen',
                () => {
                      Navigator.pop(context),
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PlantView()))
                    }),
            CustomListTile(
                Icons.library_books_outlined,
                'Vorlagen',
                () => {
                      Navigator.pop(context),
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TemplateView()))
                    }),
            CustomListTile(
                Icons.info,
                'Über',
                () => {
                      Navigator.pop(context),
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AboutView()))
                    }),
          ],
        ),
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const CustomListTile(this.icon, this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    //ToDO
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade400))),
        child: InkWell(
            splashColor: Colors.orangeAccent,
            onTap: onTap,
            child: SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(icon),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                        ),
                        Text(
                          text,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_right)
                  ],
                ))),
      ),
    );
  }
}
