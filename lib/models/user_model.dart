import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum UserRole { employee, admin, hr }

class UserModel extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final UserRole role;
  final String? departmentId;
  final String? position;
  final DateTime? hireDate;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    required this.role,
    this.departmentId,
    this.position,
    this.hireDate,
    this.profileImageUrl,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role.toString().split('.').last,
      'departmentId': departmentId,
      'position': position,
      'hireDate': hireDate != null ? Timestamp.fromDate(hireDate!) : null,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'],
      role: _parseRole(map['role']),
      departmentId: map['departmentId'],
      position: map['position'],
      hireDate: (map['hireDate'] as Timestamp?)?.toDate(),
      profileImageUrl: map['profileImageUrl'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'hr':
        return UserRole.hr;
      default:
        return UserRole.employee;
    }
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phoneNumber,
        role,
        departmentId,
        position,
        hireDate,
        profileImageUrl,
        isActive,
        createdAt,
        lastLogin,
      ];
}
