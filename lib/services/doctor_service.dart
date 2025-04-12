import '../models/doctor.dart';
import 'http_client.dart';

class DoctorService {
  static const String baseUrl = 'http://10.0.2.2:5015/api';
  final _httpClient = HttpClient();
  
  Future<List<Doctor>> fetchDoctors() async {
    try {
      final response = await _httpClient.get('$baseUrl/doctor/getalldoctors');
      // print('Raw doctor response:', response); // Debug log
      
      if (response is List) {
        return response.map((json) => Doctor.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }

  Future<bool> updateLocation(double latitude, double longitude) async {
    try {
      await _httpClient.put(
        '$baseUrl/doctor/updatelocation',
        body: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      return true;
    } catch (e) {
      print('Error updating location: $e');
      return false;
    }
  }
}
