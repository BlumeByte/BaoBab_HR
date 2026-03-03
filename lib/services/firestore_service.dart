import 'package:baobab_hr/models/attendance_model.dart';
import 'package:baobab_hr/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(firestore: FirebaseFirestore.instance);
});

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // Collection references
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _attendance => _firestore.collection('attendance');

  // User methods
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateUserLastLogin(String userId) async {
    try {
      await _users.doc(userId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Attendance methods
  Future<void> checkIn(String userId,
      {Location? location, bool isRemote = false}) async {
    try {
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month}-${today.day}';

      final attendance = AttendanceModel(
        id: dateStr,
        userId: userId,
        date: today,
        checkIn: today,
        status: _determineStatus(today),
        checkInLocation: location,
        isRemote: isRemote,
      );

      await _attendance.doc('$userId-$dateStr').set(attendance.toMap());
    } catch (e) {
      print('Error checking in: $e');
      rethrow;
    }
  }

  AttendanceStatus _determineStatus(DateTime checkInTime) {
    // Define office start time (e.g., 9:00 AM)
    final officeStart =
        DateTime(checkInTime.year, checkInTime.month, checkInTime.day, 9, 0);

    if (checkInTime.isBefore(officeStart)) {
      return AttendanceStatus.present;
    } else if (checkInTime
        .isBefore(officeStart.add(const Duration(minutes: 30)))) {
      return AttendanceStatus.late;
    } else {
      return AttendanceStatus.halfDay;
    }
  }

  Stream<List<AttendanceModel>> getUserAttendance(
      String userId, DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    return _attendance
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AttendanceModel.fromMap(
            doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
