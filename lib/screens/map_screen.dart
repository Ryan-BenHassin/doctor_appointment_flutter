import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/doctor.dart';
import '../services/doctor_service.dart';
import '../widgets/booking_dialog.dart';
import '../widgets/showFlushbar.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController = MapController();
  LatLng? currentLocation;
  List<Doctor> doctors = [];
  final _doctorService = DoctorService();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _loaddoctors();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _goToMyLocation();
    });
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
  }

  Future<void> _goToMyLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
      mapController.move(currentLocation!, 14,); // Poisitional arguments
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _loaddoctors() async {
    try {
      final loadeddoctors = await _doctorService.fetchDoctors();
      setState(() {
        doctors = loadeddoctors.where((d) => 
          d.latitude != 0 && d.longitude != 0 && d.isDoctor
        ).toList();
      });
    } catch (e) {
      print('Error loading doctors: $e');
      if (!mounted) return;
      showFlushBar(
        context,
        message: 'Failed to load doctors',
        success: false,
      );
    }
  }

  Future<void> _loadMapData() async {
    try {
      // API call here
    } catch (e) {
      if (mounted) {
        showFlushBar(context, message: 'Failed to load map data', success: false);
      }
    }
  }

  void _showdoctorDetails(Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doctor.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Specialization: ${doctor.specialization}'),
            Text('Experience: ${doctor.experience} years'),
            Text('Fees: \$${doctor.fees}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () => _showBookingDialog(doctor),
            child: Text('Book Appointment'),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => BookingDialog(
        doctor: doctor,
        // bookingService: _bookingService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('doctors Map')),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: LatLng(0, 0),
          zoom: 2,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
            tileProvider: NetworkTileProvider(),
            maxZoom: 19,
            keepBuffer: 5,
          ),
          MarkerLayer(
            markers: [
              if (currentLocation != null)
                Marker(
                  point: currentLocation!,
                  width: 80,
                  height: 80,
                  builder: (context) => Icon(Icons.my_location_rounded, color: Colors.blue, size: 40),
                ),
              // Add markers for doctors
              ...doctors.map(
                (doctor) => Marker(
                  point: LatLng(doctor.latitude, doctor.longitude),
                  width: 80,
                  height: 80,
                  builder: (context) => GestureDetector(
                    onTap: () => _showdoctorDetails(doctor),
                    child: Tooltip(
                      message: '${doctor.name}\n${doctor.description ?? ""}',
                      child: Icon(Icons.location_on_sharp, color: Colors.red, size: 50),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMyLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
