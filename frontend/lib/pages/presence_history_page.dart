import 'package:flutter/material.dart';
import 'package:frontend/controllers/attendance_controller.dart';
import 'package:frontend/models/attendance_model.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:intl/intl.dart';

class PresenceHistoryPage extends StatefulWidget {
  const PresenceHistoryPage({Key? key}) : super(key: key);

  @override
  State<PresenceHistoryPage> createState() => _PresenceHistoryPageState();
}

class _PresenceHistoryPageState extends State<PresenceHistoryPage> {
  String selectedMonth = 'Juni'; // Default to current month
  final DateFormat dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat timeFormat = DateFormat('HH:mm');

  final List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  Widget build(BuildContext context) {
    final AttendanceController attendanceController = Get.put(AttendanceController());

    return Scaffold(
      backgroundColor: secondaryBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Riwayat Absensi',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (attendanceController.isEmpty.value == true) {
            return Center(
              child: Column(
                children: [
                  Icon(Icons.people, size: 60),
                  Text(
                    'Belum ada presensi yang dilakukan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: medium,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Month Dropdown
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: tertiaryTextColor.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedMonth,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => selectedMonth = newValue);
                        final monthIndex = months.indexOf(newValue) + 1;

                        attendanceController.filterByMonth(monthIndex);
                      }
                    },
                    items:
                        months.map((month) {
                          return DropdownMenuItem(
                            value: month,
                            child: Text(
                              month,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
              // List Absensi
              Expanded(
                child: Obx(() {
                  if (attendanceController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (attendanceController.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Text(
                        attendanceController.errorMessage.value,
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                    );
                  }
                  if (attendanceController.filteredList.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada data absensi untuk bulan ini',
                        style: GoogleFonts.plusJakartaSans(),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await attendanceController.fetchAllAttendance();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: attendanceController.filteredList.length,
                      itemBuilder: (context, index) {
                        final att = attendanceController.filteredList[index];
                        return _buildAttendanceCard(att);
                      },
                    ),
                  );
                }),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemTapped: (index) {},
        currentIndex: 3,
      ),
    );
  }

  Widget _buildAttendanceCard(Attendance att) {
    final dateTimeIn = att.attDateIn.toLocal();
    final hasCheckedOut =
        att.attDateOut != null && att.attDateOut != "0001-01-01T00:00:00Z";

    final date = dateFormat.format(dateTimeIn);
    final masuk = timeFormat.format(dateTimeIn);
    final keluar = hasCheckedOut ? timeFormat.format(att.attDateOut!.toLocal()) : '-';

    return AbsensiCard(
      date: date,
      day: getDayName(dateTimeIn.weekday),
      masuk: masuk,
      keluar: keluar,
      hasCheckedOut: hasCheckedOut,
      onTap: () {
        // Add action when card is tapped if needed
      },
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

class AbsensiCard extends StatelessWidget {
  final String date;
  final String day;
  final String masuk;
  final String keluar;
  final bool hasCheckedOut;
  final VoidCallback? onTap;

  const AbsensiCard({
    super.key,
    required this.date,
    required this.day,
    required this.masuk,
    required this.keluar,
    required this.hasCheckedOut,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color:
                hasCheckedOut
                    ? const Color(0xFF2CCE66) // Green if checked out
                    : const Color(0xFFFFA000), // Orange if not checked out
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date Box
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.split(' ')[0], // Day number only
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    day.substring(0, 3), // Short day name
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Time Info
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Masuk",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        masuk,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Keluar",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        keluar,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color:
                              hasCheckedOut
                                  ? Colors.black54
                                  : const Color(
                                    0xFFFFA000,
                                  ), // Orange if not checked out
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
