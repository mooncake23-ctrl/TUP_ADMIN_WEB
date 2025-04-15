import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditUserScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  EditUserScreen({required this.user});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _idNumberController;
  late TextEditingController _plateNumberController;
  late TextEditingController _vehicleModelController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _contactNumberController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user['full_name']);
    _idNumberController = TextEditingController(text: widget.user['id_number']);
    _plateNumberController = TextEditingController(text: widget.user['plate_number']);
    _vehicleModelController = TextEditingController(text: widget.user['vehicle_model']);
    _vehicleTypeController = TextEditingController(text: widget.user['vehicle_type']);
    _contactNumberController = TextEditingController(text: widget.user['contact_number']);
    _emailController = TextEditingController(text: widget.user['email']);
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('https://appfinity.vercel.app/profile/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': widget.user['name'],
        'full_name': _fullNameController.text,
        'id_number': _idNumberController.text,
        'plate_number': _plateNumberController.text,
        'vehicle_model': _vehicleModelController.text,
        'vehicle_type': _vehicleTypeController.text,
        'contact_number': _contactNumberController.text,
        'email': _emailController.text,
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ User updated successfully!')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to update profile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF71BFDC),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF71BFDC), Color(0xFFC0BDC5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(maxWidth: 400),
            child: Card(
              color: Colors.white,
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF1B92B5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.edit, size: 36, color: Color(
                              0xFF18ACC1)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Update Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Edit your profile information',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 16),
                        Divider(thickness: 1, color: Colors.grey[300]),
                        SizedBox(height: 16),
                        _buildTextField('Full Name', _fullNameController, Icons.person),
                        SizedBox(height: 12),
                        _buildTextField('ID Number', _idNumberController, Icons.badge),
                        SizedBox(height: 12),
                        _buildTextField('Plate Number', _plateNumberController, Icons.directions_car),
                        SizedBox(height: 12),
                        _buildTextField('Vehicle Model', _vehicleModelController, Icons.motorcycle),
                        SizedBox(height: 12),
                        _buildTextField('Vehicle Type', _vehicleTypeController, Icons.directions_bus),
                        SizedBox(height: 12),
                        _buildTextField('Contact Number', _contactNumberController, Icons.phone),
                        SizedBox(height: 12),
                        _buildTextField('Email', _emailController, Icons.email),
                        SizedBox(height: 24),
                        _isLoading
                            ? CircularProgressIndicator(color: Color(0xFF11A4B1))
                            : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0C8798),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                            ),
                            child: Text(
                              'Update Profile',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFFB76E79)),
        labelText: label,
        labelStyle: TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFB76E79), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: (value) => value!.isEmpty ? 'Enter $label' : null,
    );
  }
}