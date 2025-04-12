import 'package:intl/intl.dart';
import 'http_client.dart';

class AppointmentService {
  static const String baseUrl = 'http://10.0.2.2:5015/api';
  final _httpClient = HttpClient();

  Future<bool> createAppointment({
    required String doctorId,
    required DateTime dateTime
  }) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-ddTHH:mm:ss').format(dateTime);
      await _httpClient.post(
        '$baseUrl/appointment/create',
        body: {
          'doctorId': doctorId,
          'dateTime': formattedDate,
        },
      );
      return true;
    } catch (e) {
      print('Error creating appointment: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserAppointments() async {
    try {
      final response = await _httpClient.get('$baseUrl/appointment/user-appointments');
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      await _httpClient.put(
        '$baseUrl/appointment/cancel/$appointmentId',
        body: {'status': 'cancelled'}
      );
      return true;
    } catch (e) {
      print('Error canceling appointment: $e');
      return false;
    }
  }
}