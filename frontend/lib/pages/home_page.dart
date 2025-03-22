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
                      fontWeight: extraBold,
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
                    const SizedBox(height: 40),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      height: MediaQuery.of(context).size.height * 0.72,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 350.0,
                                  height: 40.0,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: secondaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Perizinan",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: regular,
                                            color: backgroundColor,
                                          ),
                                        ),
                                        Icon(
                                          Icons.privacy_tip_rounded,
                                          size: 20,
                                          color: backgroundColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                        Get.to(() => PresenceHistoryPage());
                                      },
                                      icon: Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 30,
                                        color: primaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Cardabsenlong(
                                  day: '17',
                                  date: 'Mon',
                                  status1: 'Masuk',
                                  status2: 'Pulang',
                                  time1: '17:00',
                                  time2: '17:00',
                                ),
                                const SizedBox(height: 15),
                                Cardabsenlong(
                                  day: '17',
                                  date: 'Mon',
                                  status1: 'Masuk',
                                  status2: 'Pulang',
                                  time1: '17:00',
                                  time2: '17:00',
                                ),
                                const SizedBox(height: 15),
                                Cardabsenlong(
                                  day: '17',
                                  date: 'Mon',
                                  status1: 'Masuk',
                                  status2: 'Pulang',
                                  time1: '17:00',
                                  time2: '17:00',
                                ),
                                const SizedBox(height: 15),
                                Cardabsenlong(
                                  day: '17',
                                  date: 'Mon',
                                  status1: 'Masuk',
                                  status2: 'Pulang',
                                  time1: '17:00',
                                  time2: '17:00',
                                ),
                                const SizedBox(height: 15),
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
