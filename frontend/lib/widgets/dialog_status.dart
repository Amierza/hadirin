import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusDialog extends StatelessWidget {
  final bool isSuccess;
  final String message;
  final VoidCallback onPressed;

  const StatusDialog({
    Key? key,
    required this.isSuccess,
    required this.message,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: backgroundColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          Image.asset(
            isSuccess ? 'assets/checkmark.png' : 'assets/crossmark.png',
          ),
          SizedBox(height: 10),
          Text(
            isSuccess ? 'Success' : 'Failure',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: bold,
              color: primaryTextColor,
            ),
          ),
          SizedBox(height: 5),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: semiBold,
              color: primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess ? primaryColor : dangerColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: medium,
                color: backgroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
