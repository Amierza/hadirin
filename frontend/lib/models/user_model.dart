import 'package:frontend/models/position_model.dart';
import 'package:frontend/models/role_model.dart';

class User {
  final String userId;
  final String userName;
  final String userEmail;
  final String userPassword;
  final String userPhoneNumber;
  final String userPhoto;
  final bool userIsVerified;
  final Position position;
  final Role role;

  User({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPassword,
    required this.userPhoneNumber,
    required this.userPhoto,
    required this.userIsVerified,
    required this.position,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      userPassword: json['user_password'],
      userPhoneNumber: json['user_phone_number'],
      userPhoto: json['user_photo'],
      userIsVerified: json['user_is_verified'],
      position: Position.fromJson(json['position']),
      role: Role.fromJson(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'user_password': userPassword,
      'user_phone_number': userPhoneNumber,
      'user_photo': userPhoto,
      'user_is_verified': userIsVerified,
      'position': position.toJson(),
      'role': role.toJson(),
    };
  }
}

class UserRequest {
  final String name;
  final String email;
  final String? password;
  final String phoneNumber;
  final String? photo;
  final Role? roleId;
  final Position? positionId;

  UserRequest({
    required this.name,
    required this.email,
    this.password,
    required this.phoneNumber,
    this.photo,
    this.roleId,
    this.positionId,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    data['phone_number'] = phoneNumber;
    if (photo != null) data['photo'] = photo;
    if (roleId != null) data['role_id'] = roleId;
    if (positionId != null) data['position_id'] = positionId;
    return data;
  }
}


class UserResponse {
  final bool status;
  final String message;
  final User data;

  UserResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      status: json['status'],
      message: json['message'],
      data: User.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}