import 'package:flutter/material.dart';
import 'package:frontend/models/permission_model.dart';
import 'package:frontend/services/permission_service.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/widgets/navbar.dart';
import 'package:google_fonts/google_fonts.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({Key? key}) : super(key: key);

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  String selectedMonth = 'Januari';

  static const List<String> months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  List<PermitItem> _permits = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setCurrentMonth();
    _loadPermits();
  }

  void _setCurrentMonth() {
    final currentMonth = DateTime.now().month;
    selectedMonth = months[currentMonth - 1];
  }

  String _getMonthNumber(String monthName) {
    final index = months.indexOf(monthName) + 1;
    return index.toString().padLeft(2, '0');
  }

  Future<void> _loadPermits() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final monthNumber = _getMonthNumber(selectedMonth);
      final result = await PermitService.fetchPermitsByMonth(monthNumber);
      
      if (mounted) {
        setState(() {
          _permits = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to load permits: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _refreshPermits() async {
    await _loadPermits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryBackgroundColor,
      appBar: AppBar(
        title: const Text('Perizinan'),
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPermits,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildMonthDropdown(),
              ),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemTapped: (index) {},
        currentIndex: 2,
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data perizinan...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPermits,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_permits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data perizinan\nuntuk bulan $selectedMonth',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _permits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return PermissionCard(permission: _permits[index]);
      },
    );
  }

  Widget _buildMonthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: tertiaryTextColor,
            spreadRadius: 1,
            blurRadius: 2,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedMonth,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          onChanged: _isLoading ? null : (String? newValue) {
            if (newValue != null && newValue != selectedMonth) {
              setState(() => selectedMonth = newValue);
              _loadPermits();
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
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class PermissionCard extends StatelessWidget {
  final PermitItem permission;

  const PermissionCard({Key? key, required this.permission}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryTextColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            permission.formattedDate,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          _TitleLabel(
            text: permission.title,
            color: permission.titleColor,
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final textSpan = TextSpan(
                text: permission.description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                  height: 1.4,
                ),
              );
              
              final textPainter = TextPainter(
                text: textSpan,
                maxLines: 3,
                textDirection: TextDirection.ltr,
              )..layout(maxWidth: constraints.maxWidth - 100); // Account for status width
              
              if (textPainter.didExceedMaxLines) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permission.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _StatusLabel(status: permission.status),
                    ),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        permission.description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusLabel(status: permission.status),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _TitleLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _TitleLabel({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final PermissionStatus status;

  const _StatusLabel({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        border: Border.all(color: status.color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayText,
        style: GoogleFonts.plusJakartaSans(
          color: status.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}