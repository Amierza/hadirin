import 'package:flutter/material.dart';
import 'package:frontend/models/permission_model.dart';
import 'package:frontend/pages/make_permission_page.dart';
import 'package:frontend/pages/permission_detail_page.dart';
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
  final List<String> _months = const [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _selectedMonth = 'Januari';
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
    final now = DateTime.now();
    _selectedMonth = _months[now.month - 1];
  }

  String _getMonthNumber(String name) {
    final index = _months.indexOf(name) + 1;
    return index.toString().padLeft(2, '0');
  }

  Future<void> _loadPermits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final monthNumber = _getMonthNumber(_selectedMonth);
      final permits = await PermitService.fetchPermitsByMonth(monthNumber);
      setState(() => _permits = permits);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshPermits() async {
    await _loadPermits();
  }

  void _navigateToDetail(PermitItem permit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PermissionDetailPage(
          permit: permit,
          onPermissionDeleted: _onPermissionDeleted,
          onPermissionUpdated: _onPermissionUpdated,
        ),
      ),
    );

    // Handle navigation result sebagai fallback
    if (result != null) {
      if (result == 'deleted') {
        // Refresh the list if deleted via navigation result
        _refreshPermits();
      } else if (result is PermitItem) {
        // Update the specific item if updated
        _onPermissionUpdated(result);
      }
    }
  }

  // Callback untuk menghapus permission dari list
  void _onPermissionDeleted(String deletedId) {
    setState(() {
      _permits.removeWhere((permit) => permit.id == deletedId);
    });
    
    // Tampilkan snackbar konfirmasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Permission berhasil dihapus',
          style: GoogleFonts.plusJakartaSans(),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Callback untuk mengupdate permission di list
  void _onPermissionUpdated(PermitItem updatedPermit) {
    setState(() {
      final index = _permits.indexWhere((permit) => permit.id == updatedPermit.id);
      if (index != -1) {
        _permits[index] = updatedPermit;
      }
    });
  }

  void _navigateToCreatePermission() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePermissionPage()),
    );

    if (result == true) _refreshPermits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryBackgroundColor,
      appBar: AppBar(
        title: const Text('Perizinan'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPermits,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildMonthDropdown(),
              ),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePermission,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
          BoxShadow(
            color: tertiaryTextColor,
            spreadRadius: 1,
            blurRadius: 2,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMonth,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          onChanged: _isLoading
              ? null
              : (value) {
                  if (value != null && value != _selectedMonth) {
                    setState(() => _selectedMonth = value);
                    _loadPermits();
                  }
                },
          items: _months.map((month) {
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.red),
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
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Belum ada data perizinan\nuntuk bulan $_selectedMonth',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _permits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, index) {
        final permit = _permits[index];
        return PermissionCard(
          permission: permit, 
          onTap: () => _navigateToDetail(permit),
        );
      },
    );
  }
}

class PermissionCard extends StatelessWidget {
  final PermitItem permission;
  final VoidCallback? onTap;

  const PermissionCard({Key? key, required this.permission, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = permission.status;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            _HeaderRow(date: permission.formattedDate),
            const SizedBox(height: 12),
            _TitleLabel(text: permission.title, color: permission.titleColor),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    permission.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusLabel(status: status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final String date;

  const _HeaderRow({required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          date,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      ],
    );
  }
}

class _TitleLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _TitleLabel({required this.text, required this.color});

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
    final color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayText,
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}