import 'package:http/http.dart' as http;
import 'dart:convert';
import 'storage_service.dart';

class HttpClient {
  final StorageService _storage = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String url) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Request failed with status: ${response.statusCode}');
  }

  Future<dynamic> post(String url, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Request failed with status: ${response.statusCode}');
  }

  Future<dynamic> postWithoutAuth(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body != null ? json.encode(body) : null,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle text responses like "User registered successfully"
        return {'success': true, 'message': response.body, 'data': body};
      }
      throw Exception('Request failed with status: ${response.statusCode}');
    } catch (e) {
      if (e.toString().contains('FormatException')) {
        return {'success': true, 'data': body};
      }
      throw Exception('Request failed: $e');
    }
  }

  Future<dynamic> put(String url, {Map<String, dynamic>? body}) async {
    try {
      final token = await _storage.getAuthToken();
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle text response
        if (response.body.contains('successfully')) {
          return body; // Return original data on success
        }
        return response.body.isNotEmpty ? json.decode(response.body) : body;
      }
      throw Exception('Request failed with status: ${response.statusCode}');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }
}
