import 'package:flutter/material.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/permission_page.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/pages/presence_page.dart';
import 'package:get/get.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final Function(int) onItemTapped;
  final int currentIndex;

  const CustomBottomNavigationBar({
    Key? key,
    required this.onItemTapped,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              onItemTapped(0);
              Get.to(() => HomePage());
            },
            icon: Icon(
              Icons.home,
              size: 30,
              color: currentIndex == 0 ? primaryTextColor : backgroundColor,
            ),
          ),
          IconButton(
            onPressed: () {
              onItemTapped(1);
              Get.to(() => PresencePage());
            },
            icon: Icon(
              Icons.camera_alt,
              size: 30,
              color: currentIndex == 1 ? primaryTextColor : backgroundColor,
            ),
          ),
          IconButton(
            onPressed: () {
              onItemTapped(2);
              Get.to(() => PermissionPage());
            },
            icon: Icon(
              Icons.description,
              size: 30,
              color: currentIndex == 2 ? primaryTextColor : backgroundColor,
            ),
          ),
          IconButton(
            onPressed: () {
              onItemTapped(3);
              Get.to(() => ProfilePage());
            },
            icon: Icon(
              Icons.person,
              size: 30,
              color: currentIndex == 3 ? primaryTextColor : backgroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
