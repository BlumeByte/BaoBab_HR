import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, late, absent, halfDay }

class AttendanceModel extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final AttendanceStatus status;
  final String? notes;
  final Location? checkInLocation;
  final Location? checkOutLocation;
  final bool isRemote;

  const AttendanceModel({
    required this.id,
    required this.userId,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.notes,
    this.checkInLocation,
    this.checkOutLocation,
    this.isRemote = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'checkIn': checkIn != null ? Timestamp.fromDate(checkIn!) : null,
      'checkOut': checkOut != null ? Timestamp.fromDate(checkOut!) : null,
      'status': status.toString().split('.').last,
      'notes': notes,
      'checkInLocation': checkInLocation?.toMap(),
      'checkOutLocation': checkOutLocation?.toMap(),
      'isRemote': isRemote,
    };
  }

  factory AttendanceModel.fromMap(String id, Map<String, dynamic> map) {
    return AttendanceModel(
      id: id,
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      checkIn: (map['checkIn'] as Timestamp?)?.toDate(),
      checkOut: (map['checkOut'] as Timestamp?)?.toDate(),
      status: _parseStatus(map['status']),
      notes: map['notes'],
      checkInLocation: map['checkInLocation'] != null
          ? Location.fromMap(map['checkInLocation'])
          : null,
      checkOutLocation: map['checkOutLocation'] != null
          ? Location.fromMap(map['checkOutLocation'])
          : null,
      isRemote: map['isRemote'] ?? false,
    );
  }

  static AttendanceStatus _parseStatus(String? status) {
    switch (status) {
      case 'present':
        return AttendanceStatus.present;
      case 'late':
        return AttendanceStatus.late;
      case 'halfDay':
        return AttendanceStatus.halfDay;
      default:
        return AttendanceStatus.absent;
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        date,
        checkIn,
        checkOut,
        status,
        notes,
        checkInLocation,
        checkOutLocation,
        isRemote,
      ];
}

class Location extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;

  const Location({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      address: map['address'],
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, address];
}