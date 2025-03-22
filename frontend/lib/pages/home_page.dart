import 'package:flutter/material.dart';
import 'package:frontend/pages/presence_history_page.dart';
import 'package:frontend/shared/theme.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:frontend/widgets/cardabsen.dart';
import 'package:frontend/widgets/cardabsenlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int attendanceStreak = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity, // Make it span the full width
              color: backgroundColor, // White background
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
                      fontWeight: FontWeight.w800,
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: primaryTextColor),
                  hintText: 'Search',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: regular,
                    color: primaryTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Streak Absensi',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: regular,
                              color: backgroundColor,
                            ),
                          ),
                          Text(
                            '$attendanceStreak Hari',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: extraBold,
                              color: backgroundColor,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 60.0,
                            color: backgroundColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 15),
                            cardabsen(
                              image: 'assets/muka_presensi.png',
                              date: 'April 17, 2023',
                              status: 'Masuk',
                              time: '18:35:40',
                              desc: 'Tepat Waktu',
                            ),
                            const SizedBox(height: 15),
                            cardabsen(
                              image: 'assets/muka_presensi.png',
                              date: 'April 17, 2023',
                              status: 'Pulang',
                              time: '18:35:40',
                              desc: 'Tepat Waktu',
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                  "Bulan ini",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 30,
                                    fontWeight: black,
                                    color: primaryTextColor,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Get.to(() => const PresenceHistoryPage());
                                  },
                                  icon: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 30,
                                    color: primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Cardabsenlong(
                              day: '17',
                              date: 'Mon',
                              status1: 'Masuk',
                              status2: 'Pulang',
                              time1: '17:00',
                              time2: '17:00',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
