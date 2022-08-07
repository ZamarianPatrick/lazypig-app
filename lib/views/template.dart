import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:lazy_pig/globals.dart';
import 'package:lazy_pig/graphql.dart';

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
  final Map<int, bool> _selected = {};

  fetchTemplates() {
    gqlClient
        .query(QueryOptions(
      document: gql(gqlGetTemplates()),
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

  deleteTemplates(List<int> ids) {
    gqlClient
        .mutate(MutationOptions(
            document: gql(gqlDeleteTemplates()), variables: {'ids': ids}))
        .catchError((error) {
      log('failed to delete templates',
          name: 'lazypig.templates', error: jsonEncode(error));
    }).then((result) {
      if (result.hasException) {
        GraphQLError? err = result.exception?.graphqlErrors.first;
        if (err?.message == "FOREIGN KEY constraint failed") {
          showMessageDialog(_scaffoldKey, "Fehler",
              "Ein Template wird noch von einer Pflanze verwendet. Bitte lösche zuerst die Pflanze.");
        }
      } else {
        fetchTemplates();
      }
    });
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
                    onPressed: () {},
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
                                icon: const Icon(Icons.edit),
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
                                onPressed: () {},
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
