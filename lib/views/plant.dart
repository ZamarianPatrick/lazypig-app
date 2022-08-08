import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:lazy_pig/colors.dart';
import 'package:lazy_pig/components/drawer.dart';
import 'package:lazy_pig/components/topbar.dart';

import '../globals.dart';
import '../graphql.dart';

class PlantView extends StatefulWidget {
  const PlantView({Key? key}) : super(key: key);

  @override
  State<PlantView> createState() => _PlantView();
}

class _PlantView extends State<PlantView> {
  int _selectedIndex = 0;

  List<dynamic> _stations = [];
  List<dynamic> _stationPorts = [];
  List<dynamic> _templates = [];
  final Map<int, bool> _expanded = {};

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  fetchStations() {
    gqlClient
        .query(QueryOptions(
      document: gql(gqlGetStations()),
      fetchPolicy: FetchPolicy.networkOnly,
    ))
        .catchError((error) {
      log('failed to fetch stations',
          name: 'lazypig.plants', error: jsonEncode(error));
    }).then((result) {
      setState(() {
        _stations = result.data!['stations'];
        for (var station in _stations) {
          if (_expanded[station['id']] == null) {
            _expanded[station['id']] = false;
          }
        }
      });
    });
  }

  subscribeStations() {
    var subscription = gqlClient.subscribe(SubscriptionOptions(
      document: gql(gqlSubscribeStations()),
    ));

    subscription.listen((result) {
      if (result.hasException) {
        log('failed to fetch possible station ports',
            name: 'lazypig.plants', error: result.exception.toString());
        return;
      }

      if (result.isLoading) {
        return;
      }

      var stationData = result.data!['stations'];

      for (var station in _stations) {
        if (station['id'] == stationData['id']) {
          setState(() {
            station['waterLevel'] = stationData['waterLevel'];
          });
        }
      }
    });
  }

  fetchPossibleStationPorts() {
    gqlClient
        .query(QueryOptions(document: gql(gqlPossibleStationPorts())))
        .catchError((error) {
      log('failed to fetch possible station ports',
          name: 'lazypig.plants', error: jsonEncode(error));
    }).then((result) {
      setState(() {
        _stationPorts = result.data!['stationPorts'];
      });
    });
  }

  fetchTemplateNames() {
    gqlClient
        .query(QueryOptions(
      document: gql(gqlGetTemplateNames()),
      fetchPolicy: FetchPolicy.networkOnly,
    ))
        .catchError((error) {
      log('failed to fetch templates',
          name: 'lazypig.templates', error: jsonEncode(error));
    }).then((result) {
      setState(() {
        _templates = result.data!['templates'];
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  showStationDialog(GlobalKey<ScaffoldState> _scaffoldKey, title, station) {
    // Create button

    TextEditingController nameController = TextEditingController();

    if (station['name'] != null) {
      nameController.text = station['name']!;
    }

    Widget abortButton = ElevatedButton(
      child: const Text("Abbrechen"),
      style: ElevatedButton.styleFrom(primary: MyColors.secondary),
      onPressed: () {
        Navigator.of(_scaffoldKey.currentContext!).pop();
      },
    );

    Widget okButton = ElevatedButton(
      child: const Text("Speichern"),
      style: ElevatedButton.styleFrom(primary: MyColors.primary),
      onPressed: () {
        station['name'] = nameController.text;
        gqlClient
            .mutate(
                MutationOptions(document: gql(gqlUpdateStation()), variables: {
          'id': station['id'],
          'input': {'name': station['name']}
        }))
            .catchError((error) {
          log('failed to update station',
              name: 'lazypig.plants', error: jsonEncode(error));
        }).then((result) {
          setState(() {
            station['name'] = result.data!['updateStation']['name'];
          });
        });
        Navigator.of(_scaffoldKey.currentContext!).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Wrap(
        children: [
          Row(
            children: [
              Expanded(
                  child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: MyColors.primary),
                  ),
                ),
              ))
            ],
          ),
        ],
      ),
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

  updatePlantsActiveState(plant, stationID) {
    dynamic variables = {
      'id': plant['id'],
      'stationID': stationID,
      'input': {
        'name': plant['name'],
        'templateID': plant['template']['id'],
        'active': plant['active'],
        'port': plant['port']
      }
    };
    gqlClient
        .mutate(MutationOptions(
            document: gql(gqlUpdatePlant()), variables: variables))
        .catchError((error) {
      log('failed to update plant',
          name: 'lazypig.plants', error: jsonEncode(error));
    }).then((result) {
      fetchStations();
    });
  }

  showPlantDialog(
      GlobalKey<ScaffoldState> _scaffoldKey, title, plant, stationID) {
    // Create button

    TextEditingController nameController = TextEditingController();
    String? port;
    int? templateId;

    if (plant['name'] != null) {
      nameController.text = plant['name']!;
    }

    if (plant['port'] != null) {
      port = plant['port'];
    }

    if (plant['template'] != null && plant['template']['id'] != null) {
      templateId = plant['template']['id'];
    }

    Widget abortButton = ElevatedButton(
      child: const Text("Abbrechen"),
      style: ElevatedButton.styleFrom(primary: MyColors.secondary),
      onPressed: () {
        Navigator.of(_scaffoldKey.currentContext!).pop();
      },
    );

    Widget deleteButton = ElevatedButton.icon(
      icon: const Icon(Icons.delete_rounded),
      style: ElevatedButton.styleFrom(primary: MyColors.danger),
      onPressed: () {
        showConfirmDialog(_scaffoldKey, "Bestätigung",
            "Möchtest du die Pflanze wirklich löschen", () {
          gqlClient
              .mutate(MutationOptions(
                  document: gql(gqlDeletePlant()),
                  variables: {'id': plant['id']}))
              .catchError((error) {
            log('failed to delete plant',
                name: 'lazypig.plants', error: jsonEncode(error));
          }).then((result) {
            fetchStations();
          });
          Navigator.of(_scaffoldKey.currentContext!).pop();
        });
      },
      label: const Text('Löschen'),
    );

    Widget okButton = ElevatedButton(
      child: const Text("Speichern"),
      style: ElevatedButton.styleFrom(primary: MyColors.primary),
      onPressed: () {
        if (nameController.text == "") {
          showMessageDialog(
              _scaffoldKey, "Fehler", "Es wird ein Name benötigt");
          return;
        }

        if (port == null) {
          showMessageDialog(
              _scaffoldKey, "Fehler", "Es wird ein Anschluss benötigt");
          return;
        }

        if (templateId == null) {
          showMessageDialog(
              _scaffoldKey, "Fehler", "Es wird eine Vorlage benötigt");
          return;
        }

        dynamic variables = {
          'stationID': stationID,
          'input': {
            'name': nameController.text,
            'templateID': templateId,
            'port': port
          }
        };

        if (plant['id'] == null) {
          variables['input']['active'] = false;

          gqlClient
              .mutate(MutationOptions(
                  document: gql(gqlCreatePlant()), variables: variables))
              .catchError((error) {
            log('failed to create plant',
                name: 'lazypig.plants', error: jsonEncode(error));
          }).then((result) {
            fetchStations();
          });
        } else {
          variables['id'] = plant['id'];
          variables['input']['active'] = plant['active'];

          gqlClient
              .mutate(MutationOptions(
                  document: gql(gqlUpdatePlant()), variables: variables))
              .catchError((error) {
            log('failed to update plant',
                name: 'lazypig.plants', error: jsonEncode(error));
          }).then((result) {
            fetchStations();
          });
        }

        Navigator.of(_scaffoldKey.currentContext!).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Wrap(
        children: [
          Row(
            children: [
              Expanded(
                  child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: MyColors.primary),
                  ),
                ),
              )),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Anschluss",
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: MyColors.primary),
                        ),
                      ),
                      value: port,
                      items: _stationPorts.map((e) {
                        return DropdownMenuItem<String>(
                            value: e.toString(), child: Text(e));
                      }).toList(),
                      onChanged: (newValue) {
                        port = newValue!;
                      }))
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: "Vorlage",
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: MyColors.primary),
                        ),
                      ),
                      value: templateId,
                      items: _templates.map((e) {
                        return DropdownMenuItem<int>(
                            value: e['id'], child: Text(e['name']));
                      }).toList(),
                      onChanged: (newValue) {
                        templateId = newValue!;
                      }))
            ],
          )
        ],
      ),
      actions: [
        abortButton,
        if (plant['id'] != null) deleteButton,
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

  @override
  void initState() {
    fetchStations();
    fetchPossibleStationPorts();
    fetchTemplateNames();
    subscribeStations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var count = (size.width ~/ math.min(size.width, 400));
    var width = (size.width / count) - ((size.width <= 400) ? 15 : 10 * count);
    var levelSymbolWidth = (width <= 380) ? 10.0 : 15.0;
    var totalWidth = width * count + (20 * (count - 1));
    var gap = (size.width - totalWidth) / 2;
    if (size.width <= 280) {
      gap = 0;
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: const TopBar(title: 'Pflanzen', icon: Icons.local_florist),
        body: Padding(
          padding: EdgeInsets.fromLTRB(gap, 20, gap, 0),
          child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                      child: ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _expanded[_stations[index]['id']] = !isExpanded;
                  });
                },
                children: [
                  for (var station in _stations)
                    ExpansionPanel(
                        isExpanded: _expanded[station['id']]!,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return Row(children: <Widget>[
                            const SizedBox(
                              width: 15,
                            ),
                            Text(station['name'],
                                style: const TextStyle(fontSize: 16)),
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  showStationDialog(_scaffoldKey,
                                      "Station bearbeiten", station);
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orangeAccent,
                                  size: 25,
                                )),
                            Text(station["waterLevel"].toString() + "%"),
                            const SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                                width: levelSymbolWidth,
                                height: levelSymbolWidth * 3,
                                child: ZoomableLevelBar(
                                  title:
                                      "Wasserfüllstand: ${station["waterLevel"]}%",
                                  level: station["waterLevel"],
                                  onCreate: (level) =>
                                      _WaterLevel(level, Colors.black),
                                )),
                          ]);
                        },
                        body: Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    showPlantDialog(
                                        _scaffoldKey,
                                        "Pflanze hinzufügen",
                                        {},
                                        station['id']);
                                  },
                                  child: const Icon(Icons.add,
                                      color: Colors.white),
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(5),
                                    primary:
                                        MyColors.primary, // <-- Button color
                                  ),
                                ),
                              ],
                            ),
                            for (var plant in station['plants'])
                              if (_selectedIndex == 0 ||
                                  (_selectedIndex == 1 && plant['active']) ||
                                  (_selectedIndex == 2 && !plant['active']))
                                _PlantCard(
                                  plant: plant,
                                  width: width,
                                  onPlantActiveUpdate: (plant) {
                                    updatePlantsActiveState(
                                        plant, station['id']);
                                  },
                                  onPlantChange: (plant) {
                                    if (plant['id'] == null) {
                                      showPlantDialog(
                                          _scaffoldKey,
                                          "Pflanze hinzufügen",
                                          plant,
                                          station['id']);
                                    } else {
                                      showPlantDialog(
                                          _scaffoldKey,
                                          "Pflanze bearbeiten",
                                          plant,
                                          station['id']);
                                    }
                                  },
                                )
                          ],
                        )),
                ],
              )))
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
  final double width;
  final void Function(dynamic) onPlantChange;
  final void Function(dynamic) onPlantActiveUpdate;

  const _PlantCard({
    Key? key,
    required this.plant,
    required this.width,
    required this.onPlantChange,
    required this.onPlantActiveUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var cardTitleFontSize = (width <= 300) ? 14.0 : 16.0;
    var inset = (width <= 380) ? 0.0 : 5.0;

    return SizedBox(
      key: ValueKey(plant["id"]),
      width: width,
      child: Card(
          color: const Color(0xFFF2F2F2),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.fromLTRB(inset, 5, inset, 10),
            child: Column(children: <Widget>[
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.all(inset),
                          child: IconButton(
                            icon: IconTheme(
                              data: plant["active"]
                                  ? const IconThemeData(color: Colors.green)
                                  : const IconThemeData(color: Colors.red),
                              child: const Icon(Icons.power_settings_new),
                            ),
                            onPressed: () {
                              plant['active'] = !plant['active'];
                              onPlantActiveUpdate(plant);
                            },
                          ),
                        )),
                    Expanded(
                        flex: (width <= 320)
                            ? (width <= 300)
                                ? 2
                                : 3
                            : 4,
                        child: Column(children: <Widget>[
                          Row(children: <Widget>[
                            Expanded(
                                flex: 2,
                                child: Column(children: <Widget>[
                                  _PlantTitle(
                                      title: plant['name'],
                                      fontSize: cardTitleFontSize),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    color: MyColors.primary,
                                    height: 2,
                                  )
                                ])),
                          ]),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Column(children: <Widget>[
                              Row(children: <Widget>[
                                const Icon(Icons.door_front_door_outlined),
                                const SizedBox(width: 5),
                                Text(plant["port"]),
                              ]),
                              const SizedBox(height: 10),
                              Row(children: <Widget>[
                                const Icon(Icons.library_books_outlined),
                                const SizedBox(width: 5),
                                Text(plant["template"]["name"]),
                              ])
                            ]),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              onPlantChange(plant);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Verwalten'),
                            style: ElevatedButton.styleFrom(
                              primary: MyColors.primary,
                            ),
                          ),
                        ])),
                    const SizedBox(
                      width: 50,
                    )
                  ]),
            ]),
          )),
    );
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

class ZoomableLevelBar extends StatelessWidget {
  final String title;
  final double level;
  final LevelBar Function(double level) onCreate;

  const ZoomableLevelBar(
      {Key? key,
      required this.title,
      required this.level,
      required this.onCreate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => Dialog(
                      child: SizedBox(
                    height: 195,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 7),
                        Text(
                          title,
                          style: TextStyle(
                              fontSize:
                                  (MediaQuery.of(context).size.width <= 400)
                                      ? 18
                                      : 24),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                            width: 50,
                            height: 150,
                            child: LevelAnimation(
                              endLevel: level,
                              onCreate: (double level) {
                                return CustomPaint(painter: onCreate(level));
                              },
                            ))
                      ],
                    ),
                  ))),
          child: SizedBox(
              width: 15,
              height: 15 * 3,
              child: CustomPaint(
                painter: onCreate(level),
              )),
        ));
  }
}

abstract class LevelBar extends CustomPainter {
  final double level;
  final Color mainColor;
  LevelBar(this.level, this.mainColor);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return (oldDelegate as LevelBar).level != level ||
        (oldDelegate).mainColor != mainColor;
  }
}

class LevelAnimation extends StatefulWidget {
  final double endLevel;
  final Widget Function(double level) onCreate;

  const LevelAnimation(
      {Key? key, required this.endLevel, required this.onCreate})
      : super(key: key);

  @override
  _LevelAnimation createState() => _LevelAnimation();
}

class _LevelAnimation extends State<LevelAnimation>
    with SingleTickerProviderStateMixin {
  double level = 0.0;

  late Animation<double> _animation;
  AnimationController? controller;

  @override
  void dispose() {
    controller?.dispose();
    controller = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this)
      ..addListener(() {
        setState(() {
          level = _animation.value;
        });
      });

    controller?.forward();
    controller?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
      } else if (status == AnimationStatus.dismissed) {
        controller?.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _animation = Tween<double>(begin: 0.0, end: widget.endLevel).animate(
        CurvedAnimation(parent: controller!, curve: Curves.decelerate));
    return widget.onCreate(level);
  }
}

class _WaterLevel extends LevelBar {
  _WaterLevel(double level, Color mainColor) : super(level, mainColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = mainColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    var bottom = (size.height * 0.8);
    var fullLength = (size.height * 0.8) - (size.height * 0.1);
    var waterLength = fullLength * (level / 100);
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
}
