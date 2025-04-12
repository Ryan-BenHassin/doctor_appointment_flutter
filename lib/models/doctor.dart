class Doctor {
  final String id;
  final Map<String, dynamic> userId;
  final String specialization;
  final int experience;
  final double fees;
  final double latitude;
  final double longitude;
  final bool isDoctor;

  Doctor({
    required this.id,
    required this.userId,
    required this.specialization,
    required this.experience,
    required this.fees,
    required this.latitude,
    required this.longitude,
    required this.isDoctor,
  });

  String get name => '${userId['firstname'] ?? ''} ${userId['lastname'] ?? ''}'.trim();
  String get description => 'Specialization: $specialization\nExperience: $experience years\nFees: \$$fees';

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? {},
      specialization: json['specialization'] ?? '',
      experience: json['experience']?.toInt() ?? 0,
      fees: (json['fees'] ?? 0).toDouble(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      isDoctor: json['isDoctor'] ?? false,
    );
  }
}
