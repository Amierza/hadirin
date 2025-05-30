import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/navbar.dart';

class PresenceHistoryPage extends StatefulWidget {
  const PresenceHistoryPage({Key? key}) : super(key: key);

  @override
  State<PresenceHistoryPage> createState() => _PresenceHistoryPageState();
}

class _PresenceHistoryPageState extends State<PresenceHistoryPage> {
  String selectedMonth = 'Februari';

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

  final List<AbsensiItem> absensiList = [
    AbsensiItem(
      date: '17',
      day: 'Mon',
      masuk: '18:35:40',
      keluar: '18:35:40',
    ),
    AbsensiItem(
      date: '17',
      day: 'Mon',
      masuk: '18:35:40',
      keluar: '18:35:40',
    ),
    AbsensiItem(
      date: '17',
      day: 'Mon',
      masuk: '18:35:40',
      keluar: '18:35:40',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryBackgroundColor,
      appBar: AppBar(title: Text('Riwayat Absesi')),
      body: SafeArea(child: Column(
        children: [
          // Month Dropdown
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(color: tertiaryTextColor, spreadRadius: 1, blurRadius: 2),
                ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMonth,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => selectedMonth = newValue);
                  }
                },
                items: months.map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text(
                      month,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: extraBold,
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: absensiList.length,
              itemBuilder: (context, index) {
                final absensi = absensiList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF2CCE66), width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Date Container
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFEFEF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              absensi.date,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              absensi.day,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Time Information
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
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  absensi.masuk,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
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
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  absensi.keluar,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemTapped: (index) {},
        currentIndex: 3,
      ),
    );
  }
}

class AbsensiItem {
  final String date;
  final String day;
  final String masuk;
  final String keluar;

  const AbsensiItem({
    required this.date,
    required this.day,
    required this.masuk,
    required this.keluar,
  });
}
