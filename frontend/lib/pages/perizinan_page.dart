import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:google_fonts/google_fonts.dart';

class PerizinanPage extends StatefulWidget {
  const PerizinanPage({Key? key}) : super(key: key);

  @override
  State<PerizinanPage> createState() => _PerizinanPageState();
}

class _PerizinanPageState extends State<PerizinanPage> {
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
        backgroundColor: backgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Perizinan',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      const Icon(Icons.search, size: 24),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: tertiaryTextColor,
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
       child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              permission.date,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16, 
                fontWeight: bold, 
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getTypeColor(permission.type),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        permission.type,
                        style: GoogleFonts.plusJakartaSans(
                          color: backgroundColor,
                          fontSize: 12,
                          fontWeight: bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      permission.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(permission.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(permission.status),
                    style: GoogleFonts.plusJakartaSans(
                      color: backgroundColor,
                      fontSize: 12,
                      fontWeight: bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.approved:
        return successColor;
      case PermissionStatus.pending:
        return secondaryColor;
      case PermissionStatus.rejected:
        return dangerColor;
    }
  }

  String _getStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.approved:
        return 'Disetujui';
      case PermissionStatus.pending:
        return 'Menunggu';
      case PermissionStatus.rejected:
        return 'Ditolak';
    }
  }

  Color _getTypeColor(String type) {
    return type == 'Sakit' ? successColor : secondaryColor;
  }
}
