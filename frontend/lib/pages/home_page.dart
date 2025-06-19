import 'package:flutter/material.dart';
import 'package:frontend/controllers/attendance_controller.dart';
import 'package:frontend/pages/presence_history_page.dart';
import 'package:frontend/shared/theme.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:frontend/widgets/cardabsen.dart';
import 'package:frontend/widgets/cardabsenlong.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int attendanceStreak = 0;
  final DateFormat dateFormat = DateFormat('MMMM d, yyyy');
  final DateFormat timeFormat = DateFormat('HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    final attendanceTodayController = Get.put(AttendanceTodayController());
    final attendanceController = Get.put(AttendanceController());
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: secondaryBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: backgroundColor,
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
                    dateFormat.format(now),
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
              child: Obx(() {
                if (attendanceController.isLoading == true) {
                  return Center(child: CircularProgressIndicator());
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Absensi',
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: regular,
                                color: backgroundColor,
                              ),
                            ),
                            Text(
                              '${attendanceController.attendanceList.length} Hari',
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
                );
              }),
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
                  child: Obx(() {
                    if (attendanceTodayController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (attendanceTodayController
                        .errorMessage
                        .value
                        .isNotEmpty) {
                      return Center(
                        child: Text(
                          attendanceTodayController.errorMessage.value,
                        ),
                      );
                    }

                    final todayAttendance =
                        attendanceTodayController.attendance.value;
                    final hasCheckedIn = todayAttendance?.attDateIn != null;
                    final hasCheckedOut =
                        todayAttendance?.attDateOut != null &&
                        todayAttendance!.attDateOut != "0001-01-01T00:00:00Z";

                    return ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 15),
                              // Check-in Card
                              if (hasCheckedIn)
                                cardabsen(
                                  image: 'assets/muka_presensi.png',
                                  date: dateFormat.format(now),
                                  status: 'Masuk',
                                  time:
                                      todayAttendance != null
                                          ? timeFormat.format(
                                            todayAttendance.attDateIn.toLocal(),
                                          )
                                          : '--:--:--',
                                  desc:
                                      'Tepat Waktu', // You can add logic for late/early
                                ),

                              const SizedBox(height: 15),
                              // Check-out Card
                              if (hasCheckedOut)
                                cardabsen(
                                  image: 'assets/muka_presensi.png',
                                  date: dateFormat.format(now),
                                  status: 'Pulang',
                                  time: timeFormat.format(
                                    todayAttendance.attDateOut!.toLocal(),
                                  ),
                                  desc: 'Tepat Waktu',
                                )
                              else if (hasCheckedIn && !hasCheckedOut)
                                cardabsen(
                                  image: 'assets/muka_presensi.png',
                                  date: dateFormat.format(now),
                                  status: 'Pulang',
                                  time: '-',
                                  desc: 'Menunggu',
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
                              // Example monthly card (you can replace with actual data)
                              Obx(
                                () => ListView.separated(
                                  shrinkWrap: true,
                                  itemCount:
                                      attendanceController
                                                  .attendanceList
                                                  .length >
                                              3
                                          ? 3
                                          : attendanceController
                                              .attendanceList
                                              .length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final data =
                                        attendanceController
                                            .attendanceList[index];

                                    final dateFormat = DateFormat('d MMMM yyyy');
                                    final dateTimeIn = data.attDateIn.toLocal();
                                    final hasCheckedOut =
                                        data.attDateOut != null &&
                                        data.attDateOut !=
                                            "0001-01-01T00:00:00Z";
     
                                    final date = dateFormat.format(dateTimeIn);
                                    final masuk = timeFormat.format(dateTimeIn);
                                    final keluar =
                                        hasCheckedOut
                                            ? timeFormat.format(
                                              data.attDateOut!,
                                            )
                                            : '-';

                                    return Cardabsenlong(
                                      day: getDayName(dateTimeIn.weekday),
                                      date: date.split(' ')[0],
                                      status1: "Masuk",
                                      status2: "Pulang",
                                      time1: masuk,
                                      time2: keluar,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
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

  String getDayName(int weekday) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[weekday - 1];
  }
}
