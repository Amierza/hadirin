import 'package:flutter/material.dart';
import 'package:frontend/shared/theme.dart';

enum PermissionStatus {
  approved,
  pending,
  rejected;

  // Helper method untuk mendapatkan display text
  String get displayText {
    switch (this) {
      case PermissionStatus.approved:
        return 'Disetujui';
      case PermissionStatus.pending:
        return 'Menunggu';
      case PermissionStatus.rejected:
        return 'Ditolak';
    }
  }

  // Helper method untuk mendapatkan warna
  Color get color {
    switch (this) {
      case PermissionStatus.approved:
        return successColor;
      case PermissionStatus.pending:
        return secondaryColor;
      case PermissionStatus.rejected:
        return dangerColor;
    }
  }
}

class PermitItem {
  final String id;
  final String date;
  final String title;
  final String description;
  final PermissionStatus status;

  PermitItem({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.status,
  });

  factory PermitItem.fromJson(Map<String, dynamic> json) {
    // Improved null safety and validation
    if (json['permit_date'] == null ||
        json['permit_title'] == null ||
        json['permit_desc'] == null) {
      throw FormatException('Data perizinan tidak lengkap');
    }

    // Konversi status dengan fallback yang lebih robust
    PermissionStatus status;
    final statusValue = json['permit_status'];

    if (statusValue is int) {
      switch (statusValue) {
        case 1:
          status = PermissionStatus.approved;
          break;
        case 2:
          status = PermissionStatus.rejected;
          break;
        case 0:
        default:
          status = PermissionStatus.pending;
      }
    } else if (statusValue is String) {
      // Handle string status if API returns string instead of int
      switch (statusValue.toLowerCase()) {
        case 'approved':
        case 'disetujui':
        case '1':
          status = PermissionStatus.approved;
          break;
        case 'rejected':
        case 'ditolak':
        case '2':
          status = PermissionStatus.rejected;
          break;
        default:
          status = PermissionStatus.pending;
      }
    } else {
      status = PermissionStatus.pending;
    }

    return PermitItem(
      id: json['permit_id'].toString(),
      date: json['permit_date'].toString(),
      title: json['permit_title'].toString(),
      description: json['permit_desc'].toString(),
      status: status,
    );
  }

  // Method untuk mendapatkan formatted date
  String get formattedDate {
    try {
      final parsedDate = DateTime.parse(date);
      const monthNames = [
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

      return '${parsedDate.day} ${monthNames[parsedDate.month - 1]} ${parsedDate.year}';
    } catch (e) {
      return date; // Return original if parsing fails
    }
  }

  // Method untuk mendapatkan warna label berdasarkan title
  Color get titleColor {
    switch (status) {
      case PermissionStatus.approved:
        return Colors.green;
      case PermissionStatus.pending:
        return Colors.orange;
      case PermissionStatus.rejected:
        return Colors.red;
    }
  }

  // copyWith method for immutability
  PermitItem copyWith({
    String? id, // Tambahkan ini
    String? date,
    String? title,
    String? description,
    PermissionStatus? status,
  }) {
    return PermitItem(
      id: id ?? this.id, // Tambahkan ini
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'PermitItem(id: $id, date: $date, title: $title, description: $description, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PermitItem &&
        other.id == id && 
        other.date == date &&
        other.title == title &&
        other.description == description &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^ 
        date.hashCode ^
        title.hashCode ^
        description.hashCode ^
        status.hashCode;
  }
}
