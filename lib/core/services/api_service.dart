import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../features/auth/providers/auth_provider.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ApiService(prefs, ref);
});

class ApiService {
  final SharedPreferences _prefs;
  final Ref _ref;

  ApiService(this._prefs, this._ref);

  String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  Map<String, String> _headers() {
    final token = _prefs.getString('access_token');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    final http.Response response;
    try {
      response = await http.get(url, headers: _headers());
    } catch (e) {
      throw Exception('Network error: $e');
    }
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, dynamic body) async {
    final url = Uri.parse('$baseUrl$path');
    final http.Response response;
    try {
      response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode(body),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, dynamic body) async {
    final url = Uri.parse('$baseUrl$path');
    final http.Response response;
    try {
      response = await http.patch(
        url,
        headers: _headers(),
        body: jsonEncode(body),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, dynamic body) async {
    final url = Uri.parse('$baseUrl$path');
    final http.Response response;
    try {
      response = await http.put(
        url,
        headers: _headers(),
        body: jsonEncode(body),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final url = Uri.parse('$baseUrl$path');
    final http.Response response;
    try {
      response = await http.delete(
        url,
        headers: _headers(),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
    return _handleResponse(response);
  }

  Future<ApiResponse> getWithResponse(String path) async {
    final url = Uri.parse('$baseUrl$path');
    final http.Response response;
    try {
      response = await http.get(url, headers: _headers());
    } catch (e) {
      throw Exception('Network error: $e');
    }
    final decodedData = _handleResponse(response);
    return ApiResponse(data: decodedData, headers: response.headers);
  }

  dynamic _handleResponse(http.Response response) {
    final path = response.request?.url.path ?? '';
    final isAuthFlow = path.contains('/auth/login') || path.contains('/auth/register');

    if (response.statusCode == 401 && !isAuthFlow) {
      // Token expired or invalid, trigger logout
      _ref.read(authProvider.notifier).logout();
      throw Exception('Session expired. Please log in again.');
    }
    
    final bodyString = response.body;
    dynamic data;
    if (bodyString.isNotEmpty) {
      try {
        data = jsonDecode(bodyString);
      } catch (e) {
        // Not a JSON response
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      String message = 'Request failed';
      if (data is Map && data['error'] != null && data['error']['message'] != null) {
        message = data['error']['message'];
      } else if (data is Map && data['detail'] != null) {
        message = data['detail'].toString();
      }
      throw Exception(message);
    }
  }
}

class ApiResponse {
  final dynamic data;
  final Map<String, String> headers;

  ApiResponse({required this.data, required this.headers});
}
