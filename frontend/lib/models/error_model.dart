class ErrorResponse {
  final bool status;
  final String message;
  final String error;

  ErrorResponse({
    required this.status,
    required this.message,
    required this.error,
  });

  @override
  String toString() {
    return 'ErrorResponse(message: $message, status: $status, error: $error)';
  }

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      status: json['status'],
      message: json['message'],
      error: json['error'],
    );
  }
}
