import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:frontend/widgets/cardabsen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hari ini",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Februari 17, 2025",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: secondaryBackgroundColor,
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        cardabsen(
                          image: 'assets/muka_presensi.png',
                          date: '17:00',
                          status: 'Masuk',
                        ),
                        cardabsen(
                          image: 'assets/muka_presensi.png',
                          date: '17:00',
                          status: 'Pulang',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "Hadirin",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Hadirin",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            CustomBottomNavigationBar(
              onItemTapped: (index) {},
              currentIndex: 0,
            ),
          ],
        ),
      ),
    );
  }
}
