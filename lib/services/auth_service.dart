import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'storage_service.dart';
import '../providers/user_provider.dart';
import 'http_client.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:5015/api';
  final StorageService _storage = StorageService();
  final _httpClient = HttpClient();

  Future<Map<String, dynamic>> login(String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        await _storage.saveAuthToken(data['token']);
        return data;
      }
      throw Exception('Login failed with status: ${response.statusCode}');
    } catch (e) {
      print('Login error: $e');
      throw Exception('Failed to login');
    }
  }

  Future<User> getCompleteUserData() async {
    try {
      final userData = await _httpClient.get('$baseUrl/users/me?populate=*');
      print('Complete user data: $userData'); // For debugging
      final user = User.fromJson(userData);
      UserProvider.user = user;
      return user;
    } catch (e) {
      print('Error getting complete user data: $e');
      throw Exception('Failed to fetch user data');
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    required String mobile,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'firstname': firstname,
          'lastname': lastname,
          'mobile': mobile,
          'role': role,
        }),
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<void> createDoctorProfile({
    required int userId,
    required String speciality,
  }) async {
    try {
      await _httpClient.post(
        '$baseUrl/doctors',
        body: {
          'data': {
            'users_permissions_user': userId,
            'speciality': speciality,
          }
        },
      );
    } catch (e) {
      print('Error creating doctor: $e');
      throw Exception('Failed to create doctor profile');
    }
  }

  Future<void> createPatientProfile({
    required int userId,
    required DateTime birthdate,
  }) async {
    try {
      await _httpClient.post(
        '$baseUrl/patients',
        body: {
          'data': {
            'users_permissions_user': userId,
            'birthdate': birthdate.toIso8601String(),
          }
        },
      );
    } catch (e) {
      print('Error creating patient: $e');
      throw Exception('Failed to create patient profile');
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<User> getCurrentUser() async {
    if (UserProvider.user != null) {
      return UserProvider.user!;
    }

    try {
      // Use base endpoint without ID since token contains user info
      final response = await _httpClient.get('$baseUrl/user/getuser');
      print('Current user response: $response'); // For debugging
      final user = User.fromJson(response);
      UserProvider.user = user;
      return user;
    } catch (e) {
      print('Error getting current user: $e');
      throw Exception('Failed to fetch user data');
    }
  }

  Future<String?> getAuthToken() async {
    return _storage.getAuthToken();
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  Future<User> updateProfile(Map<String, dynamic> userData) async {
    try {
      // Remove null values and prepare request body
      final body = {
        'firstname': userData['firstname'],
        'lastname': userData['lastname'],
        'email': userData['email'],
        'mobile': userData['mobile'] ?? '',
        'age': userData['age'] ?? '',
        'gender': userData['gender'] ?? 'neither',
        'address': userData['address'] ?? '',
        'password': userData['password'] ?? '',
      }..removeWhere((key, value) => value == null);

      print('Update profile request body: $body'); // Debug log

      final response = await _httpClient.put(
        '$baseUrl/user/updateprofile',
        body: body,
      );
      
      final updatedUser = User.fromJson(response);
      UserProvider.user = updatedUser;
      return updatedUser;
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile');
    }
  }
}
