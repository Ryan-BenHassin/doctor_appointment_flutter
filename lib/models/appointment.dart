class Appointment {
  final String id;
  final String userId;
  final Map<String, dynamic>? doctorId;  // Changed to Map to handle nested doctor data
  final String date;
  final String time;
  final String status;

  Appointment({
    required this.id,
    required this.userId,
    this.doctorId,
    required this.date,
    required this.time,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      doctorId: json['doctorId'], // Handle as raw Map
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? '',
    );
  }

  String getDoctorName() {
    if (doctorId == null) return 'Doctor not assigned';
    final userData = doctorId!['userId'] as Map<String, dynamic>?;
    if (userData == null) return 'Doctor not assigned';
    
    final firstname = userData['firstname'] ?? '';
    final lastname = userData['lastname'] ?? '';
    return 'Dr. $firstname $lastname'.trim();
  }
}
