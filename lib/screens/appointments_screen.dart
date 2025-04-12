import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../widgets/appointment_item.dart';

class AppointmentsScreen extends StatefulWidget {
  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _appointmentService = AppointmentService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final appointmentsData = await _appointmentService.fetchUserAppointments();
      setState(() {
        _appointments = appointmentsData.map((b) => Appointment.fromJson(b)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text('My Appointments')),
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: _appointments.isEmpty 
            ? Center(child: Text('No appointments found'))
            : ListView.builder(
                itemCount: _appointments.length,
                itemBuilder: (context, index) => AppointmentItem(
                  appointment: _appointments[index],
                  onCanceled: () {
                    setState(() {
                      _loadAppointments();
                    });
                  },
                ),
              ),
      ),
    );
  }
}
