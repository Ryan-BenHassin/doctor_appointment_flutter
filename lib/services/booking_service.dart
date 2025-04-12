import 'package:intl/intl.dart';
import 'http_client.dart';

class BookingService {
  static const String baseUrl = 'http://10.0.2.2:5015/api';
  final _httpClient = HttpClient();

  Future<List<DateTime>> fetchAvailableDatetimes(String doctorId) async {
    final response = await _httpClient.get('$baseUrl/doctor/availableslots/$doctorId');
    List<dynamic> data = response['data'] ?? [];
    return data.map((dateStr) => DateTime.parse(dateStr.toString())).toList();
  }

  Future<bool> createReservation({
    required String doctorId,
    required DateTime dateTime
  }) async {
    try {
      await _httpClient.post(
        '$baseUrl/appointment/bookappointment',
        body: {
          'doctorId': doctorId,
          'date': DateFormat('yyyy-MM-dd').format(dateTime),
          'time': DateFormat('HH:mm').format(dateTime),
        },
      );
      return true;
    } catch (e) {
      print('Error creating reservation: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserBookings() async {
    try {
      final response = await _httpClient.get('$baseUrl/appointment/appointments');
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  Future<bool> cancelReservation(String reservationId) async {
    try {
      await _httpClient.put(
        '$baseUrl/reservations/$reservationId',
        body: {
          'data': {
            'state': 'CANCELED'
          }
        },
      );
      return true;
    } catch (e) {
      print('Error canceling reservation: $e');
      return false;
    }
  }

  Future<List<DateTime>> fetchDoctorAppointments(String doctorId) async {
    try {
      final response = await _httpClient.get('$baseUrl/doctor/appointments/$doctorId');
      if (response is List) {
        return response.map((app) {
          final date = DateFormat('yyyy-MM-dd').parse(app['date']);
          final time = DateFormat('HH:mm').parse(app['time']);
          return DateTime(
            date.year, 
            date.month, 
            date.day,
            time.hour,
            time.minute
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching doctor appointments: $e');
      return [];
    }
  }
}
