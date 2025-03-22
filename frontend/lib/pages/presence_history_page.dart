import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:google_fonts/google_fonts.dart';

class PresenceHistoryPage extends StatefulWidget {
  const PresenceHistoryPage({Key? key}) : super(key: key);

  @override
  State<PresenceHistoryPage> createState() => _PerizinanPageState();
}

class _PerizinanPageState extends State<PresenceHistoryPage> {
  String selectedMonth = 'Februari';

  final List<PerizinanItem> permissions = [
    PerizinanItem(date: '20 February 2024', type: 'Sakit', description: 'Demam Berdarah', status: PermissionStatus.pending),
    PerizinanItem(date: '21 February 2024', type: 'Izin', description: 'Acara Nikahan', status: PermissionStatus.pending),
    PerizinanItem(date: '22 February 2024', type: 'Sakit', description: 'Diare dan Demam', status: PermissionStatus.rejected),
    PerizinanItem(date: '23 February 2024', type: 'Sakit', description: 'Demam Berdarah', status: PermissionStatus.approved),
    PerizinanItem(date: '20 February 2024', type: 'Sakit', description: 'Demam Berdarah', status: PermissionStatus.pending),
    PerizinanItem(date: '21 February 2024', type: 'Izin', description: 'Acara Nikahan', status: PermissionStatus.pending),
    PerizinanItem(date: '22 February 2024', type: 'Sakit', description: 'Diare dan Demam', status: PermissionStatus.rejected),
    PerizinanItem(date: '23 February 2024', type: 'Sakit', description: 'Demam Berdarah', status: PermissionStatus.approved),
    PerizinanItem(date: '20 February 2024', type: 'Sakit', description: 'Demam Berdarah', status: PermissionStatus.pending),
    PerizinanItem(date: '21 February 2024', type: 'Izin', description: 'Acara Nikahan', status: PermissionStatus.pending),
    PerizinanItem(date: '22 February 2024', type: 'Sakit', description: 'Diare dan Demam', status: PermissionStatus.rejected),
    PerizinanItem(date: '23 February 2024', type: 'Sakit', description: 'Demam Berdarah', status: PermissionStatus.approved),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Riwayat Absensi',
          style: GoogleFonts.plusJakartaSans(
            color: primaryTextColor,
            fontWeight: bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: _showMonthPicker,
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedMonth,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_outlined, size: 40),
                    ],
                  ),
                ),
              ),
            ),

            // List Perizinan
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: permissions.length,
                itemBuilder: (context, index) {
                  return PermissionCard(permission: permissions[index]);
                },
              ),
            ),
            CustomBottomNavigationBar(onItemTapped: (index) {}, currentIndex: 0),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: ListView(
            children: [
              'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
              'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
            ].map(
              (month) => ListTile(
                title: Text(
                  month,
                  style: GoogleFonts.plusJakartaSans(),
                ),
                onTap: () {
                  setState(() {
                    selectedMonth = month;
                  });
                  Navigator.pop(context);
                },
              ),
            ).toList(),
          ),
        );
      },
    );
  }
}

enum PermissionStatus { approved, pending, rejected }

class PerizinanItem {
  final String date;
  final String type;
  final String description;
  final PermissionStatus status;

  PerizinanItem({
    required this.date,
    required this.type,
    required this.description,
    required this.status,
  });
}

class PermissionCard extends StatelessWidget {
final PerizinanItem permission;

  const PermissionCard({Key? key, required this.permission}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primaryColor, width: 5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '17',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24, 
                    fontWeight: bold
                  ),
                ),
                Text(
                  'Mon',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, 
                    fontWeight: bold
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Masuk',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18, 
                      fontWeight: bold
                    ),
                  ),
                  SizedBox(width: 50),
                  Text(
                    'Keluar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18, 
                      fontWeight: bold
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    '18:35:40',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14
                    ),
                  ),
                  SizedBox(width: 50),
                  Text(
                    '18:35:40',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
