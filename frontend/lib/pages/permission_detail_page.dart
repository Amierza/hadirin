import 'package:flutter/material.dart';
import 'package:frontend/models/permission_model.dart';
import 'package:frontend/services/permission_service.dart';
import 'package:frontend/shared/theme.dart';
import 'package:frontend/pages/edit_permission_page.dart';
import 'package:google_fonts/google_fonts.dart';

class PermissionDetailPage extends StatefulWidget {
  final PermitItem permit;
  final Function(String) onPermissionDeleted;  // Callback untuk delete
  final Function(PermitItem) onPermissionUpdated;  // Callback untuk update

  const PermissionDetailPage({
    Key? key,
    required this.permit,
        required this.onPermissionDeleted,
    required this.onPermissionUpdated,
  }) : super(key: key);

  @override
  State<PermissionDetailPage> createState() => _PermissionDetailPageState();
}

class _PermissionDetailPageState extends State<PermissionDetailPage> {
  late PermitItem currentPermit;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentPermit = widget.permit;
  }

  // Check if permit can be edited/deleted (status: menunggu/pending)
  bool get canModifyPermit {
    final status = currentPermit.status.displayText.toLowerCase();
    return status == 'menunggu' || status == 'pending';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryBackgroundColor,
      appBar: AppBar(
        title: const Text('Detail Perizinan'),
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context, currentPermit),
        ),
        actions: canModifyPermit
            ? [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _navigateToEditPage();
                    } else if (value == 'delete') {
                      _showDeleteConfirmation();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Edit Permission'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Permission'),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainCard(),
                const SizedBox(height: 16),
                _buildStatusCard(),
                const SizedBox(height: 16),
                _buildDescriptionCard(),
                if (canModifyPermit) ...[
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _navigateToEditPage,
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text('Edit Permission'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showDeleteConfirmation,
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text('Delete Permission'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            'Informasi Perizinan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Tanggal',
            value: currentPermit.formattedDate,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.category,
            label: 'Jenis Izin',
            value: currentPermit.title,
            valueColor: currentPermit.titleColor,
            showColorDot: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            'Status Perizinan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                _getStatusIcon(),
                color: currentPermit.status.color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: currentPermit.status.color.withOpacity(0.1),
                  border: Border.all(color: currentPermit.status.color),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentPermit.status.displayText,
                  style: GoogleFonts.plusJakartaSans(
                    color: currentPermit.status.color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            'Alasan Perizinan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              currentPermit.description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool showColorDot = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (showColorDot && valueColor != null) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: valueColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: valueColor ?? primaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon() {
    final status = currentPermit.status.displayText.toLowerCase();
    switch (status) {
      case 'menunggu':
      case 'pending':
        return Icons.hourglass_empty;
      case 'disetujui':
      case 'approved':
        return Icons.check_circle;
      case 'ditolak':
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _navigateToEditPage() async {
    if (!canModifyPermit) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPermissionPage(permit: currentPermit),
      ),
    );

    // Handle different types of result from edit page
    if (result != null) {
      if (result is PermitItem) {
        // If edit page returns updated permit item
        setState(() {
          currentPermit = result;
        });
      } else if (result is Map<String, dynamic> && result['success'] == true) {
        // If edit page returns success result with data
        if (result['data'] != null) {
          try {
            final updatedPermit = PermitItem.fromJson(result['data']);
            setState(() {
              currentPermit = updatedPermit;
            });
          } catch (e) {
            // If parsing fails, refresh from server
            _refreshPermitData();
          }
        } else {
          // Refresh from server if no data in result
          _refreshPermitData();
        }
      } else if (result == 'updated') {
        // If edit page just returns a string indicating success
        _refreshPermitData();
      }
    }
  }

  // Helper method to refresh permit data from server
  void _refreshPermitData() async {
    try {
      final result = await PermitService.getPermissionById(currentPermit.id);
      if (result['success'] == true && result['data'] != null) {
        final updatedPermit = PermitItem.fromJson(result['data']);
        setState(() {
          currentPermit = updatedPermit;
        });
      }
    } catch (e) {
      // If refresh fails, show a message but don't break the UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data berhasil diperbarui, namun gagal memuat ulang tampilan',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    if (!canModifyPermit) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Hapus Perizinan',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus perizinan ini? Tindakan ini tidak dapat dibatalkan.',
            style: GoogleFonts.plusJakartaSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deletePermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Hapus',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deletePermission() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await PermitService.deletePermission(currentPermit.id);
      
      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Perizinan berhasil dihapus',
                style: GoogleFonts.plusJakartaSans(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, 'deleted');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Gagal menghapus perizinan',
                style: GoogleFonts.plusJakartaSans(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan: $e',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}