import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:lazy_pig/globals.dart';

import '../backend.dart';
import '../colors.dart';
import '../components/drawer.dart';
import '../components/topbar.dart';

class TemplateView extends StatefulWidget {
  const TemplateView({Key? key}) : super(key: key);

  @override
  State<TemplateView> createState() => _TemplateView();
}

class _TemplateView extends State<TemplateView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> _templates = [];
  bool _allSelected = false;
  int _selectedCount = 0;
  Map<int, bool> _selected = {};

  fetchTemplates() {
    backend.getTemplates((result) {
      setState(() {
        _templates = result.data!['templates'];
      });
    });
  }

  deleteTemplates(List<int> ids) {
    backend.deleteTemplates(ids, (result) {
      if (result.hasException) {
        GraphQLError? err = result.exception?.graphqlErrors.first;
        if (err?.message == "FOREIGN KEY constraint failed") {
          showMessageDialog(_scaffoldKey, "Fehler",
              "Ein Template wird noch von einer Pflanze verwendet. Bitte lösche zuerst die Pflanze.");
        }
      } else {
        _selected = {};
        fetchTemplates();
      }
    });
  }

  showTemplateDialog(GlobalKey<ScaffoldState> _scaffoldKey, title, template) {
    // Create button

    TextEditingController nameController = TextEditingController();
    TextEditingController waterThresholdController = TextEditingController();

    if (template['name'] != null) {
      nameController.text = template['name']!;
    }

    if (template['waterThreshold'] != null) {
      waterThresholdController.text = template['waterThreshold'].toString();
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
        template['name'] = nameController.text;
        template['waterThreshold'] =
            double.parse(waterThresholdController.text);

        dynamic variables = {
          'input': {
            'name': template['name'],
            'waterThreshold': template['waterThreshold']
          }
        };

        if (template['id'] == null) {
          backend.createTemplate(variables, (result) => fetchTemplates());
        } else {
          variables['id'] = template['id'];
          backend.updateTemplate(variables, (result) => fetchTemplates());
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
              ))
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: TextField(
                controller: waterThresholdController,
                decoration: const InputDecoration(
                  labelText: "Feuchtigkeitsschwelle",
                  labelStyle: TextStyle(
                    color: Colors.black,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: MyColors.primary),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ))
            ],
          )
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

  @override
  void initState() {
    fetchTemplates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar:
            const TopBar(title: 'Vorlagen', icon: Icons.library_books_outlined),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      showTemplateDialog(_scaffoldKey, "Vorlage erstellen", {});
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      primary: MyColors.primary, // <-- Button color
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: _templates.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 2, color: MyColors.secondary))),
                          child: Row(
                            children: [
                              Checkbox(
                                  value: _allSelected,
                                  activeColor: MyColors.primary,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _allSelected = newValue!;

                                      _selected.forEach((key, value) {
                                        _selected[key] = newValue;
                                      });

                                      if (newValue == true) {
                                        _selectedCount = _selected.length;
                                      } else {
                                        _selectedCount = 0;
                                      }
                                    });
                                  }),
                              const Text('Name'),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () {
                                  List<int> ids = [];
                                  _selected.forEach((id, isSelected) {
                                    if (isSelected) {
                                      ids.add(id);
                                    }
                                  });

                                  showConfirmDialog(
                                      _scaffoldKey,
                                      "Bestätigung",
                                      "Möchstest du die " +
                                          _selectedCount.toString() +
                                          " Vorlage(n) wirklich löschen?", () {
                                    deleteTemplates(ids);
                                  });
                                },
                                icon: const Icon(Icons.delete_rounded),
                                label: Text(_selectedCount.toString() +
                                    ' Ausgewählte löschen'),
                                style: ElevatedButton.styleFrom(
                                  primary: MyColors.danger,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      index -= 1;

                      final template = _templates[index];

                      if (_selected[template['id']] == null) {
                        _selected[template['id']] = false;
                      }

                      return Container(
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 1, color: MyColors.secondary))),
                        child: Row(
                          children: [
                            Checkbox(
                                value: _selected[template['id']],
                                activeColor: MyColors.primary,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selected[template['id']] = newValue!;
                                    if (newValue == true) {
                                      _selectedCount++;
                                    } else {
                                      _selectedCount--;
                                    }

                                    if (_selectedCount == _selected.length) {
                                      _allSelected = true;
                                    } else {
                                      _allSelected = false;
                                    }
                                  });
                                }),
                            Text(template['name'] ?? ''),
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  showConfirmDialog(_scaffoldKey, "Bestätigung",
                                      "Möchtest du die Vorlage wirklich löschen?",
                                      () {
                                    deleteTemplates([template['id']]);
                                  });
                                },
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  color: Colors.red,
                                  size: 25,
                                )),
                            IconButton(
                                onPressed: () {
                                  showTemplateDialog(_scaffoldKey,
                                      "Vorlage bearbeiten", template);
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orangeAccent,
                                  size: 25,
                                ))
                          ],
                        ),
                      );
                    })
              ],
            )),
        drawer: const LazyPigDrawer());
  }
}
