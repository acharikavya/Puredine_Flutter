import 'package:restaurant_unified_app/admin/services/api_service.dart';
import 'package:restaurant_unified_app/core/constants.dart';
import 'package:restaurant_unified_app/admin/core/models/restaurant_model.dart';

class MenuService {
  // ─── Categories ────────────────────────────────────────────────────────────

  static Future<List<MenuCategory>> getCategories() async {
    // GET /api/admin/menu/categories  ✅ confirmed working
    final data = await ApiService.get(
      ApiEndpoints.menuCategoriesList,
      requiresAuth: true,
    );
    final list = data as List<dynamic>;
    return list.map((e) => MenuCategory.fromJson(e)).toList();
  }

  static Future<MenuCategory> createCategory(Map<String, dynamic> body) async {
    // POST /api/admin/menu/categories  ✅ confirmed working
    final data = await ApiService.post(
      ApiEndpoints.menuCategoriesList,
      body,
      requiresAuth: true,
    );
    return MenuCategory.fromJson(data as Map<String, dynamic>);
  }

  static Future<MenuCategory> updateCategory(
    String id,
    Map<String, dynamic> body,
  ) async {
    // PUT /api/admin/categories/:id  — direct route, no /menu/ prefix
    final cleanData = Map<String, dynamic>.from(body)..remove('id');
    final data = await ApiService.put(
      ApiEndpoints.menuCategoryById(id),
      cleanData,
      requiresAuth: true,
    );
    return MenuCategory.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> deleteCategory(String id) async {
    // DELETE /api/admin/categories/:id  — direct route
    await ApiService.delete(
      ApiEndpoints.menuCategoryById(id),
      requiresAuth: true,
    );
  }

  // ─── Items ─────────────────────────────────────────────────────────────────

  static Future<List<MenuItem>> getItems() async {
    // GET /api/admin/menu/items  ✅ confirmed working
    final data = await ApiService.get(
      ApiEndpoints.menuItemsList,
      requiresAuth: true,
    );
    final list = data as List<dynamic>;
    return list.map((e) => MenuItem.fromJson(e)).toList();
  }

  static Future<MenuItem> createItem(Map<String, dynamic> body) async {
    // POST /api/admin/menu/items  ✅ confirmed working
    final data = await ApiService.post(
      ApiEndpoints.menuItemsList,
      body,
      requiresAuth: true,
    );
    return MenuItem.fromJson(data as Map<String, dynamic>);
  }

  static Future<void> updateItem(
    String itemId,
    Map<String, dynamic> data,
  ) async {
    // PUT /api/admin/menu/items/:id  — backend uses PUT for full item update
    // Sana confirmed: do NOT send preparation_time or restaurant_id
    final cleanData = Map<String, dynamic>.from(data)
      ..remove('id')
      ..remove('preparation_time')
      ..remove('preparationTime')
      ..remove('restaurant_id');

    await ApiService.put(
      ApiEndpoints.menuItemById(itemId),
      cleanData,
      requiresAuth: true,
    );
  }

  static Future<void> toggleItem(String itemId) async {
    // PATCH /api/admin/menu/items/:id/toggle  ✅ confirmed working
    await ApiService.patch(
      ApiEndpoints.toggleMenuItem(itemId),
      requiresAuth: true,
    );
  }

  static Future<void> updateSpecialStatus(String itemId, bool isSpecial) async {
    await ApiService.patch(
      ApiEndpoints.toggleMenuItem(itemId),
      body: {
        'isSpecial': isSpecial,
        'is_special': isSpecial,
      }, // Send both to be safe
      requiresAuth: true,
    );
  }

  /// Deletes a single menu item — new method, added to support the delete
  /// button now on each item card in MenuScreen. Mirrors `deleteCategory`
  /// exactly: same `ApiService.delete` call, same `requiresAuth: true`,
  /// just targeting the item-by-id endpoint (the same
  /// `ApiEndpoints.menuItemById(itemId)` helper already used by
  /// `updateItem` above) instead of the category endpoint.
  ///
  /// Expected route: DELETE /api/admin/menu/items/:id
  /// Nothing about any existing method above was changed to add this.
  static Future<void> deleteItem(String itemId) async {
    await ApiService.delete(
      ApiEndpoints.menuItemById(itemId),
      requiresAuth: true,
    );
  }
}