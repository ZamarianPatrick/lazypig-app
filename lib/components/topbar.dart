import 'package:flutter/material.dart';

import '../colors.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  const TopBar({Key? key, required this.title, required this.icon})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  final String title;
  final IconData icon;

  @override
  final Size preferredSize; // default is 56.0

  @override
  _TopBar createState() => _TopBar();
}

class _TopBar extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var fontSize = (size.width <= 380)
        ? (size.width <= 280)
            ? 18.0
            : 24.0
        : 28.0;
    return AppBar(
      centerTitle: true,
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: Colors.white),
          children: [
            WidgetSpan(
              child: Icon(widget.icon, size: fontSize + 4),
            ),
            const WidgetSpan(
              child: SizedBox(
                width: 5,
              ),
            ),
            TextSpan(
              text: widget.title,
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      automaticallyImplyLeading: false,
      actions: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.notifications),
        ),
      ],
      backgroundColor: MyColors.primary,
    );
  }
}
