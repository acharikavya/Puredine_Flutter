import 'package:restaurant_unified_app/admin/services/api_service.dart';
import 'package:restaurant_unified_app/core/constants.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';

class StaffService {
  static Future<List<StaffMember>> getStaff() async {
    final data = await ApiService.get(
      ApiEndpoints.staffList,
      requiresAuth: true,
    );
    final list = data as List<dynamic>;
    return list.map((e) => StaffMember.fromJson(e)).toList();
  }

  static Future<StaffMember> createStaff(Map<String, dynamic> body) async {
    final data = await ApiService.post(
      ApiEndpoints.staffList,
      body,
      requiresAuth: true,
    );
    return StaffMember.fromJson(data);
  }

  /// Updates an existing staff member's details (name, email, phone, role,
  /// and optionally password). Mirrors `createStaff` exactly — same request
  /// pattern, just targeted at the specific staff member's endpoint via
  /// `ApiEndpoints.staffById` (the same endpoint `deleteStaff` already uses)
  /// and sent as a PATCH instead of a POST, consistent with how
  /// `toggleStaff` already uses PATCH for partial updates on a single staff
  /// record.
  static Future<StaffMember> updateStaff(
    String staffId,
    Map<String, dynamic> body,
  ) async {
    final data = await ApiService.patch(
      ApiEndpoints.staffById(staffId),
      body: body,
      requiresAuth: true,
    );
    return StaffMember.fromJson(data);
  }

  static Future<void> toggleStaff(String staffId) async {
    await ApiService.patch(
      ApiEndpoints.toggleStaff(staffId),
      requiresAuth: true,
    );
  }

  static Future<void> deleteStaff(String staffId) async {
    await ApiService.delete(
      ApiEndpoints.staffById(staffId),
      requiresAuth: true,
    );
  }
}