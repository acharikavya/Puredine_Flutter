import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class MenuProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<MenuItem> _items = [];
  List<MenuItem> get items => List.unmodifiable(_items);

  static const String _baseUrl = 'https://pos-backend-s380.onrender.com';

  MenuProvider();

  Future<void> fetchMenuItems({String? authToken}) async {
    if (_isLoading) return;
    if (_items.isEmpty) {
      _isLoading = true;
      _error = null;
      Future.microtask(() => notifyListeners());
    }

    try {
      final String? token = authToken ??
          (await SharedPreferences.getInstance()).getString('auth_token');

      // If no token, we still proceed to try public endpoints
      final Map<String, String> headers = {'Content-Type': 'application/json'};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      debugPrint('MenuProvider: Token length: ${token?.length ?? 0}');
      if (token != null && token.length > 10) {
        debugPrint(
          'MenuProvider: Token starts with: ${token.substring(0, 10)}...',
        );
      }

      // List of endpoints to try
      final endpoints = [
        '/api/admin/menu/items',
        '/api/menu/items',
        '/api/staff/menu/items',
        '/api/admin/menu/categories',
      ];

      bool success = false;
      String? lastError;
      // Tracks whether every failed attempt looked like a network-level
      // failure (as opposed to a clean HTTP error status) — on Flutter
      // Web this pattern (every endpoint fails with no status code) is
      // the signature of a CORS block, since the browser refuses the
      // response before it ever reaches this code.
      bool allFailuresLookLikeNetworkOrCors = true;
      bool sawAuthFailure = false;

      for (final endpoint in endpoints) {
        final url = '$_baseUrl$endpoint';
        debugPrint('MenuProvider: Fetching from $url with headers $headers');

        try {
          final response = await http
              .get(Uri.parse(url), headers: headers)
              .timeout(const Duration(seconds: 10));

          // We got an actual HTTP response, so this was not a
          // network/CORS-level failure for this endpoint.
          allFailuresLookLikeNetworkOrCors = false;

          debugPrint('MenuProvider: $endpoint - Status ${response.statusCode}');

          if (response.statusCode == 200) {
            final bodySnippet = response.body.length > 200
                ? '${response.body.substring(0, 200)}...'
                : response.body;
            debugPrint('MenuProvider: Response: $bodySnippet');

            dynamic decoded = json.decode(response.body);
            List<dynamic> itemsList = _extractList(decoded);

            if (itemsList.isNotEmpty) {
              _items = itemsList
                  .map((j) => _parseItem(j as Map<String, dynamic>))
                  .toList();
              _items.sort((a, b) => a.category.compareTo(b.category));
              success = true;
              debugPrint(
                'MenuProvider: Successfully parsed ${_items.length} items from $endpoint',
              );
              break;
            } else {
              debugPrint(
                'MenuProvider: Endpoint $endpoint returned empty list or could not be extracted',
              );
            }
          } else {
            if (response.statusCode == 401 || response.statusCode == 403) {
              sawAuthFailure = true;
            }
            lastError =
                'Failed to load menu from $endpoint (${response.statusCode})';
          }
        } catch (e) {
          debugPrint('MenuProvider: Error fetching $endpoint: $e');
          lastError = 'Error: $e';
        }
      }

      if (!success) {
        if (kIsWeb && allFailuresLookLikeNetworkOrCors) {
          // Every single endpoint failed before returning any HTTP
          // status — on web that almost always means the browser
          // blocked the response due to missing CORS headers on the
          // backend, not a problem with this app's code or your
          // internet connection.
          _error =
              'Could not reach the menu server from the web app. This usually '
              'means the backend needs to allow requests from this website\'s '
              'address (CORS). Ask your backend team to enable CORS for this '
              'web app\'s origin. (Technical detail: $lastError)';
        } else if (sawAuthFailure) {
          _error =
              'You may need to sign in again — the menu server rejected the '
              'request as unauthorized. (Technical detail: $lastError)';
        } else {
          _error = lastError ?? 'Failed to load menu items from any endpoint';
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('MenuProvider critical error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map) {
      // Try common response shapes
      for (final key in [
        'data',
        'items',
        'menu',
        'menuItems',
        'menu_items',
        'results',
      ]) {
        final val = decoded[key];
        if (val is List) return val;
        if (val is Map) {
          for (final inner in val.values) {
            if (inner is List) return inner;
          }
        }
      }
      for (final val in decoded.values) {
        if (val is List) return val;
      }
    }
    return [];
  }

  MenuItem _parseItem(Map<String, dynamic> json) {
    final String id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final String name = json['name']?.toString() ??
        json['item_name']?.toString() ??
        json['title']?.toString() ??
        'Item';
    final double price = double.tryParse(
          json['price']?.toString() ??
              json['selling_price']?.toString() ??
              json['rate']?.toString() ??
              '0',
        ) ??
        0.0;

    String category = 'Other';
    final rawCat =
        json['category'] ?? json['categoryName'] ?? json['category_name'];
    if (rawCat is String) {
      category = rawCat.isNotEmpty ? rawCat : 'Other';
    } else if (rawCat is Map) {
      category =
          rawCat['name']?.toString() ?? rawCat['title']?.toString() ?? 'Other';
    }

    final rawAvail = json['is_available'] ??
        json['isAvailable'] ??
        json['available'] ??
        true;
    final bool isAvailable =
        rawAvail is bool ? rawAvail : rawAvail.toString() != 'false';

    return MenuItem(
      id: id,
      name: name,
      price: price,
      category: category,
      isAvailable: isAvailable,
    );
  }
}
