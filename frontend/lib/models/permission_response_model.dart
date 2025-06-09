class PermitResponse {
  final bool status;
  final String message;
  final PermitData? data;

  PermitResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory PermitResponse.fromJson(Map<String, dynamic> json) {
    return PermitResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? PermitData.fromJson(json['data']) : null,
    );
  }
}

class PermitData {
  final String permitId;
  final String permitDate;
  final int permitStatus;
  final String permitTitle;
  final String permitDesc;

  PermitData({
    required this.permitId,
    required this.permitDate,
    required this.permitStatus,
    required this.permitTitle,
    required this.permitDesc,
  });

  factory PermitData.fromJson(Map<String, dynamic> json) {
    return PermitData(
      permitId: json['permit_id'] ?? '',
      permitDate: json['permit_date'] ?? '',
      permitStatus: json['permit_status'] ?? 0,
      permitTitle: json['permit_title'] ?? '',
      permitDesc: json['permit_desc'] ?? '',
    );
  }
}