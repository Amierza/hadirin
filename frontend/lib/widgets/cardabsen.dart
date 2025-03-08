import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';

class cardabsen extends StatelessWidget {
  final String image;
  final String date;
  final String status;

  const cardabsen({
    Key? key,
    required this.image,
    required this.date,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color borderColor = status == "Masuk" ? primaryColor : dangerColor;

    return Container(
      padding: EdgeInsets.all(8.0),
      width: 150.0,
      height: 80.0,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: borderColor, width: 5.0),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(image, width: 50, height: 30, fit: BoxFit.cover),
          ),
          SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              Text(
                date, // Provided date or timestamp
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
