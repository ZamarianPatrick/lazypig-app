import 'package:flutter/material.dart';
import 'package:lazy_pig/globals.dart';
import 'package:lazy_pig/views/plant.dart';

import '../backend.dart';
import '../colors.dart';
import '../components/topbar.dart';

class ConnectView extends StatelessWidget {
  const ConnectView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController ipController = TextEditingController();

    return Scaffold(
        appBar: const TopBar(
          title: 'Verbinden',
          icon: Icons.wifi,
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'Willkommen',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Image.asset('assets/images/plant-icon.png'),
                  FractionallySizedBox(
                    widthFactor: 0.6,
                    child: TextField(
                      controller: ipController,
                      decoration: const InputDecoration(
                        labelText: "Server Adresse",
                        labelStyle: TextStyle(color: Colors.black),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: MyColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    child: const Text("Verbinden"),
                    style: ElevatedButton.styleFrom(primary: MyColors.primary),
                    onPressed: () async {
                      bool pingSuccess =
                          await backend.pingAddress(ipController.text);

                      if (pingSuccess) {
                        backend.setAddress(ipController.text);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PlantView()));
                      } else {
                        showMessageDialogContext(context, "Fehler",
                            "Es konnte keine Verbindung hergestellt werden. Bitte prüfe die Server Adresse.");
                      }
                    },
                  )
                ],
              ),
            )));
  }
}
