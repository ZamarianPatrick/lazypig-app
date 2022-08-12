import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../components/drawer.dart';
import '../components/topbar.dart';

class AboutView extends StatelessWidget {
  AboutView({Key? key}) : super(key: key);

  final List<String> names = [
    "Erika Brönimann",
    "Andreas Bührer",
    "Andreas Gasser",
    "Joel Meier",
    "Patrick Zamarian",
    "Azad Ahmed",
    "Birakash Vilvarajah",
    "Thierry Lanz",
    "Luca Schüppbach",
    "Rainer Burkhalter",
    "Kay Diego Eng"
  ];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var fontSize = (size.width <= 320)
        ? (size.width <= 280)
            ? (size.width <= 250)
                ? 11.0
                : 12.0
            : 14.0
        : math.max(16.0, size.width / 50);
    if (fontSize > 28) fontSize = 32;
    var iconSize = fontSize + 4;

    return Scaffold(
        appBar: const TopBar(
          title: 'Über',
          icon: Icons.info,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  Icon(
                    Icons.water,
                    size: iconSize,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Lazy Pig',
                    style: TextStyle(fontSize: fontSize),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(
                    Icons.phone_android,
                    size: iconSize,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'App Version: ' +
                        const String.fromEnvironment('VERSION',
                            defaultValue: 'dev'),
                    style: TextStyle(fontSize: fontSize),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Icon(
                    Icons.dns,
                    size: iconSize,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Server Version: 1.14',
                    style: TextStyle(fontSize: fontSize),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Team',
                style: TextStyle(
                    fontSize: math.max(24, fontSize + 4),
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: (size.width <= 1000) ? 400 : size.width * 0.6),
                  child: Row(
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0; i < 6; i++)
                            Text(names[i],
                                style: TextStyle(height: 2, fontSize: fontSize))
                        ],
                      )),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (int i = 6; i < 11; i++)
                            Text(names[i],
                                style:
                                    TextStyle(height: 2, fontSize: fontSize)),
                          const Text(
                            '',
                            style: TextStyle(height: 2),
                          )
                        ],
                      ))
                    ],
                  ))
            ],
          ),
        ),
        drawer: const LazyPigDrawer());
  }
}
