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
    return AppBar(
      title: RichText(
        text: TextSpan(
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
          children: [
            const TextSpan(
              text: 'Lazy Pig - ',
            ),
            const WidgetSpan(
              child: Icon(Icons.local_florist, size: 26),
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
