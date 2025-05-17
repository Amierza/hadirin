class Login {
  final String accesToken;
  final String refreshToken;

  Login({required this.accesToken, required this.refreshToken});

  @override
  String toString() {
    return 'Login(accesToken: $accesToken, refreshToken: $refreshToken)';
  }

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      accesToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class LoginResponse {
  final bool status;
  final String message;
  final Login data;

  LoginResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  @override
  String toString() {
    return 'LoginResponse(status: $status, message: "$message", data: $data)';
  }

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'],
      message: json['message'],
      data: Login.fromJson(json['data']),
    );
  }
}
