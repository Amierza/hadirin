import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:google_fonts/google_fonts.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({Key? key}) : super(key: key);

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
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

  final List<PermissionItem> permissions = [
    PermissionItem(
      date: '28 Februari 2024',
      type: 'Sakit',
      description: 'Demam Berdarah',
      status: PermissionStatus.approved,
    ),
    PermissionItem(
      date: '28 Februari 2024',
      type: 'Izin',
      description: 'Acara Nikahan',
      status: PermissionStatus.pending,
    ),
    PermissionItem(
      date: '28 Februari 2024',
      type: 'Sakit',
      description: 'Diare dan Demam',
      status: PermissionStatus.rejected,
    ),
    PermissionItem(
      date: '28 Februari 2024',
      type: 'Sakit',
      description: 'Demam Berdarah',
      status: PermissionStatus.approved,
    ),
    PermissionItem(
      date: '28 Februari 2024',
      type: 'Izin',
      description: 'Acara Nikahan',
      status: PermissionStatus.pending,
    ),
    PermissionItem(
      date: '28 Februari 2024',
      type: 'Sakit',
      description: 'Diare dan Demam',
      status: PermissionStatus.rejected,
    ),
    PermissionItem(
      date: '28 Februari 2024',
      type: 'Sakit',
      description: 'Demam Berdarah',
      status: PermissionStatus.approved,
    ),
    PermissionItem(
      date: '28 Februari 2024',
      type: 'Izin',
      description: 'Acara Nikahan',
      status: PermissionStatus.pending,
    ),
    PermissionItem(
      date: '28 Februari 2024',
      type: 'Sakit',
      description: 'Diare dan Demam',
      status: PermissionStatus.rejected,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Perizinan',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black,
            fontWeight: bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildMonthDropdown(),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: permissions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return PermissionCard(permission: permissions[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemTapped: (index) {},
        currentIndex: 2,
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => selectedMonth = newValue);
            }
          },
          items:
              months.map((month) {
                return DropdownMenuItem(
                  value: month,
                  child: Text(
                    month,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: extraBold,
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

enum PermissionStatus { approved, pending, rejected }

class PermissionItem {
  final String date;
  final String type;
  final String description;
  final PermissionStatus status;

  const PermissionItem({
    required this.date,
    required this.type,
    required this.description,
    required this.status,
  });
}

class PermissionCard extends StatelessWidget {
  final PermissionItem permission;

  const PermissionCard({Key? key, required this.permission}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: primaryTextColor, spreadRadius: 1, blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            permission.date,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel(
                permission.type,
                permission.type == 'Sakit' ? Colors.green : Colors.orange,
              ),
              _buildStatusLabel(permission.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            permission.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: regular,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusLabel(PermissionStatus status) {
    Color color;
    String text;

    switch (status) {
      case PermissionStatus.approved:
        color = Colors.green;
        text = 'Disetujui';
        break;
      case PermissionStatus.pending:
        color = Colors.orange;
        text = 'Menunggu';
        break;
      case PermissionStatus.rejected:
        color = Colors.red;
        text = 'Ditolak';
        break;
    }

    return _buildLabel(text, color);
  }
}
