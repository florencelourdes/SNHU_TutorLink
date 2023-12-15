import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavAppBar extends StatelessWidget implements PreferredSizeWidget{
  const NavAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
      return AppBar(
        title: const Align( //Title Bar
        alignment: Alignment.bottomLeft,
        child: Image(image: NetworkImage(
        "https://dlmrue3jobed1.cloudfront.net/uploads/school/SouthernNewHampshireUniversity/snhu_initials_rgb_pos.png"),
    width: 300,
    height: 100,)
    ),
    flexibleSpace: Container(
    decoration: const BoxDecoration(color: Color(0xff009DEA)),),
    );
  }

}