import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/sign_in_page.dart';

class SignoutDialog extends StatelessWidget {
  const SignoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: backgroundColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Apakah kamu ingin keluar?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // "Tidak" Button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: dangerColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Tidak",
                  style: TextStyle(fontSize: 16, color: backgroundColor),
                ),
              ),
              // "Ya" Button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.to(() => SignInPage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Ya",
                  style: TextStyle(fontSize: 16, color: backgroundColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
