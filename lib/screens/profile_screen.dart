import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'package:another_flushbar/flushbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isEditing = false;
  User? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getCurrentUser();
      setState(() {
        _userData = userData;
        _firstnameController.text = userData.firstname;
        _lastnameController.text = userData.lastname;
        _phoneController.text = userData.phone ?? '';
        _emailController.text = userData.email;
      });
    } catch (e) {
      if (mounted) {
        _showMessage('Failed to load profile data', false);
      }
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updatedUser = await _authService.updateProfile({
          'firstname': _firstnameController.text,
          'lastname': _lastnameController.text,
          'mobile': _phoneController.text,
          'email': _emailController.text,
        });
        
        if (mounted) {
          setState(() {
            _isEditing = false;
            _userData = updatedUser;
          });
          _showMessage('Profile updated successfully', true);
        }
      } catch (e) {
        if (mounted) {
          print('Update error: $e');
          _showMessage(e.toString(), false);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _handleRefresh() async {
    return _loadUserData();
  }

  void _showMessage(String message, bool success) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: success ? Colors.green : Colors.red,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _userData == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _firstnameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(),
                          ),
                          enabled: _isEditing,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter first name' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastnameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(),
                          ),
                          enabled: _isEditing,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter last name' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          enabled: _isEditing,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          enabled: _isEditing,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Please enter email' : null,
                        ),
                        if (_isEditing) ...[
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleSave,
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Save Changes'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
