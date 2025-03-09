import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';

class Cardabsenlong extends StatelessWidget {
  final String date;
  final String day;
  final String status1;
  final String time1;
  final String status2;
  final String time2;

  const Cardabsenlong({
    Key? key,
    required this.date,
    required this.day,
    required this.status1,
    required this.time1,
    required this.status2,
    required this.time2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: 350.0,
      height: 80.0,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: primaryColor, width: 5.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: extraBold,
                  color: primaryTextColor,
                ),
              ),
              Text(
                day,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: extraBold,
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status1,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: extraBold,
                  color: primaryTextColor,
                ),
              ),
              Text(
                time1,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: regular,
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status2,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: extraBold,
                  color: primaryTextColor,
                ),
              ),
              Text(
                time2,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: regular,
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
