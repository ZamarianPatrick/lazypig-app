import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lazy_pig/colors.dart';
import 'package:lazy_pig/components/drawer.dart';
import 'package:lazy_pig/components/topbar.dart';

class PlantView extends StatefulWidget {
  const PlantView({Key? key}) : super(key: key);

  @override
  State<PlantView> createState() => _PlantView();
}

class _PlantView extends State<PlantView> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _allPlants = [
    {
      "id": 1,
      "name": "Bonsai Fenster",
      "active": true,
      "room": "Zimmer 108",
      "templateName": "Bonsai",
      "battery": 60,
      "water": 9,
    },
    {
      "id": 2,
      "name": "Kaktus Tisch",
      "active": true,
      "room": "Zimmer 204",
      "templateName": "Kaktus",
      "battery": 30,
      "water": 74,
    },
    {
      "id": 3,
      "name": "Calluna",
      "active": false,
      "room": "Zimmer 212",
      "templateName": "Calluna",
      "battery": 10,
      "water": 92,
    },
    {
      "id": 4,
      "name": "Calluna",
      "active": false,
      "room": "Zimmer 212",
      "templateName": "Calluna",
      "battery": 95,
      "water": 32,
    },
  ];

  List<Map<String, dynamic>> _foundPlants = [];

  void _onItemTapped(int index) {
    List<Map<String, dynamic>> results = [];
    if (index == 0) {
      results = _allPlants;
    } else {
      var active = index == 1;
      results = _allPlants.where((plant) => plant["active"] == active).toList();
    }
    setState(() {
      _selectedIndex = index;
      _foundPlants = results;
    });
  }

  @override
  void initState() {
    _foundPlants = _allPlants;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const TopBar(title: 'Pflanzen', icon: Icons.local_florist),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: _foundPlants.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: _foundPlants.length,
                        itemBuilder: (context, index) =>
                            _PlantCard(plant: _foundPlants[index]))
                    : const Text(
                        'No results found',
                        style: TextStyle(fontSize: 24),
                      ),
              ))
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: IconTheme(
                data: IconThemeData(color: Colors.black38),
                child: Icon(Icons.power_settings_new),
              ),
              label: 'Alle',
            ),
            BottomNavigationBarItem(
              icon: IconTheme(
                data: IconThemeData(color: Colors.green),
                child: Icon(Icons.power_settings_new),
              ),
              label: 'Aktive',
            ),
            BottomNavigationBarItem(
              icon: IconTheme(
                data: IconThemeData(color: Colors.red),
                child: Icon(Icons.power_settings_new),
              ),
              label: 'Inaktive',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
        drawer: const LazyPigDrawer());
  }
}

class _PlantCard extends StatelessWidget {
  final Map<String, dynamic> plant;

  const _PlantCard({
    Key? key,
    required this.plant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        key: ValueKey(plant["id"]),
        color: const Color(0xFFF2F2F2),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 10),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Expanded(
                  child: Align(
                alignment: Alignment.centerLeft,
                child: IconTheme(
                  data: plant["active"]
                      ? const IconThemeData(color: Colors.green)
                      : const IconThemeData(color: Colors.red),
                  child: const Icon(Icons.power_settings_new),
                ),
              )),
              Expanded(
                  flex: 2,
                  child: Column(children: <Widget>[
                    _PlantTitle(title: plant['name'], fontSize: 16),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: MyColors.primary,
                      height: 2,
                    )
                  ])),
              Expanded(
                  child: Column(
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(plant["battery"].toString() + "%"),
                        const SizedBox(
                          width: 5,
                        ),
                        SizedBox(
                            width: 15,
                            height: 15 * 3,
                            child: CustomPaint(
                              painter:
                                  _BatteryLevel(plant["battery"], Colors.black),
                            )),
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(plant["water"].toString() + "%"),
                        const SizedBox(
                          width: 5,
                        ),
                        SizedBox(
                            width: 15,
                            height: 15 * 3,
                            child: CustomPaint(
                              painter:
                                  _WaterLevel(plant["water"], Colors.black),
                            )),
                      ]),
                ],
              )),
            ]),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(children: <Widget>[
                Row(children: <Widget>[
                  const Icon(Icons.door_front_door_outlined),
                  const SizedBox(width: 5),
                  Text(plant["room"]),
                ]),
                const SizedBox(height: 10),
                Row(children: <Widget>[
                  const Icon(Icons.library_books_outlined),
                  const SizedBox(width: 5),
                  Text(plant["templateName"]),
                ])
              ]),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text('Verwalten'),
              style: ElevatedButton.styleFrom(
                primary: MyColors.primary,
              ),
            ),
          ]),
        ));
  }
}

class _PlantTitle extends StatelessWidget {
  const _PlantTitle({
    Key? key,
    required this.title,
    required this.fontSize,
  }) : super(key: key);

  final String title;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            color: Colors.black),
        children: [
          WidgetSpan(
            child: Icon(Icons.local_florist, size: fontSize + 4),
          ),
          TextSpan(
            text: title,
          ),
        ],
      ),
    );
  }
}

class _BatteryLevel extends CustomPainter {
  int batteryLevel;
  Color mainColor;

  _BatteryLevel(this.batteryLevel, this.mainColor);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
        RRect.fromLTRBR(
            0, size.height * 0.2, size.width, size.height * 0.8, Radius.zero),
        Paint()
          ..color = mainColor
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke);

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.2),
        height: size.height * 0.2,
        width: size.width * 0.5,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = mainColor
        ..style = PaintingStyle.fill,
    );

    var bottom = (size.height * 0.8 - 1.0);
    var fullLength = (size.height * 0.8 - 1.0) - (size.height * 0.2 + 1.2);
    var batteryLength = fullLength * (batteryLevel / 100);

    var batteryColor = (batteryLevel <= 20) ? Colors.red : Colors.green;

    canvas.drawRRect(
        RRect.fromLTRBR(
            1.2, bottom - batteryLength, size.width - 1.5, bottom, Radius.zero),
        Paint()
          ..color = batteryColor
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return (oldDelegate as _BatteryLevel).batteryLevel != batteryLevel ||
        (oldDelegate).mainColor != mainColor;
  }
}

class _WaterLevel extends CustomPainter {
  int waterLevel;
  Color mainColor;

  _WaterLevel(this.waterLevel, this.mainColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = mainColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    var bottom = (size.height * 0.8);
    var fullLength = (size.height * 0.8) - (size.height * 0.1);
    var waterLength = fullLength * (waterLevel / 100);
    var waterTop = bottom - waterLength;

    Path path = Path();
    path.moveTo(0, size.height * 0.8);

    const halfRad = 180 * math.pi / 180;
    var y = math.max(waterTop, size.height * 0.2);
    path.lineTo(0, y);
    var a = size.width;
    var c = a * 0.4;
    var d = math.sqrt(math.pow(size.height * 0.2 - size.height * 0.1, 2) +
        math.pow(size.width * 0.3, 2));

    var alpha = math.acos(math.pow(a - c, 2) / (2 * d * (a - c)));
    var delta = halfRad - alpha;
    var hSmall = math.max(waterTop, size.height * 0.2) - waterTop;
    var dSmall = hSmall / math.sin(delta);
    var bSmall = hSmall / math.sin(alpha);
    var cSmall =
        (a * math.sin(alpha) - bSmall * math.sin(halfRad - 2 * alpha)) /
            math.sin(alpha);
    var x = math.sin(alpha) * dSmall;

    y = y - math.cos(alpha) * dSmall;
    path.lineTo(x, y);
    x += cSmall;
    path.lineTo(x, y);
    path.lineTo(size.width, math.max(waterTop, size.height * 0.2));
    path.lineTo(size.width, size.height * 0.8);

    path.lineTo(0, size.height * 0.8);

    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill);

    var heightModifier = 0.8;
    for (int i = 0; i < 7; i++) {
      canvas.drawLine(
          Offset(0, size.height * heightModifier),
          Offset(size.width, size.height * heightModifier),
          Paint()
            ..color = mainColor
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke);
      heightModifier -= 0.1;
    }

    canvas.drawLine(
        Offset(0, size.height * 0.8), Offset(0, size.height * 0.2), paint);

    canvas.drawLine(Offset(size.width, size.height * 0.8),
        Offset(size.width, size.height * 0.2), paint);

    canvas.drawLine(Offset(size.width, size.height * 0.2),
        Offset(size.width * 0.7, size.height * 0.1), paint);

    canvas.drawLine(Offset(0, size.height * 0.2),
        Offset(size.width * 0.3, size.height * 0.1), paint);

    canvas.drawRRect(
        RRect.fromLTRBR(size.width * 0.3, 0, size.width * 0.7,
            size.height * 0.1, Radius.zero),
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.fill);

    canvas.drawRRect(
        RRect.fromLTRBR(size.width * 0.3, 0, size.width * 0.7,
            size.height * 0.1, const Radius.circular(1)),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke);

    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.06),
        Offset(size.width * 0.7, size.height * 0.06), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return (oldDelegate as _WaterLevel).waterLevel != waterLevel ||
        (oldDelegate).mainColor != mainColor;
  }
}
