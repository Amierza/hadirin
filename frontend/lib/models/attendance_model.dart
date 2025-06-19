class Attendance {
  final String attId;
  final bool attStatus;
  final DateTime attDateIn;
  final DateTime? attDateOut;
  final String attPhotoIn;
  final String attPhotoOut;
  final String attLatitudeIn;
  final String attLongitudeIn;
  final String attLatitudeOut;
  final String attLongitudeOut;

  Attendance({
    required this.attId,
    required this.attStatus,
    required this.attDateIn,
    this.attDateOut,
    required this.attPhotoIn,
    required this.attPhotoOut,
    required this.attLatitudeIn,
    required this.attLongitudeIn,
    required this.attLatitudeOut,
    required this.attLongitudeOut,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      attId: json['att_id'],
      attStatus: json['att_status'],
      attDateIn: DateTime.parse(json['att_date_in']),
      attDateOut:
          json['att_date_out'] != "0001-01-01T00:00:00Z"
              ? DateTime.tryParse(json['att_date_out'])
              : null,
      attPhotoIn: json['att_photo_in'],
      attPhotoOut: json['att_photo_out'],
      attLatitudeIn: json['att_latitude_in'],
      attLongitudeIn: json['att_longitude_in'],
      attLatitudeOut: json['att_latitude_out'],
      attLongitudeOut: json['att_longitude_out'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'att_id': attId,
      'att_status': attStatus,
      'att_date_in': attDateIn.toIso8601String(),
      'att_date_out': attDateOut?.toIso8601String() ?? "0001-01-01T00:00:00Z",
      'att_photo_in': attPhotoIn,
      'att_photo_out': attPhotoOut,
      'att_latitude_in': attLatitudeIn,
      'att_longitude_in': attLongitudeIn,
      'att_latitude_out': attLatitudeOut,
      'att_longitude_out': attLongitudeOut,
    };
  }
}

class AllAttendanceResponse {
  final bool status;
  final String message;
  final List<Attendance> data;

  AllAttendanceResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AllAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AllAttendanceResponse(
      status: json['status'],
      message: json['message'],
      data: List<Attendance>.from(
        json['data'].map((item) => Attendance.fromJson(item)),
      ),
    );
  }
}

class AttendanceResponse {
  final bool status;
  final String message;
  final Attendance data;

  AttendanceResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      status: json['status'],
      message: json['message'],
      data: Attendance.fromJson(json['data']),
    );
  }
}
