import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_edit_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  UserDetailScreen({required this.user});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      String apiUrl = 'https://appfinity.vercel.app/profile';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> userList = jsonDecode(response.body);
        final userMatch = userList.firstWhere(
              (user) => user['name'].toString().toLowerCase() == widget.user['name'].toString().toLowerCase(),
          orElse: () => null,
        );

        if (userMatch != null) {
          setState(() {
            userProfile = userMatch;
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.user['name']} Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF71BFDC),
              Color(0xFF9676D6),],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : hasError
              ? Text(
            'Failed to load user profile',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          )
              : Card(
            color: Colors.white.withOpacity(0.9),
            margin: EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            elevation: 6,
            shadowColor: Color(0xFF42B5B5).withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow(Icons.person, 'Full Name',
                      userProfile?['full_name'] ?? "N/A"),
                  _buildDetailRow(Icons.badge, 'ID Number',
                      userProfile?['id_number'] ?? "N/A"),
                  _buildDetailRow(Icons.email, 'Email',
                      widget.user['email'] ?? "N/A"),
                  _buildDetailRow(Icons.credit_card, 'RFID',
                      widget.user['rfid'] ?? "N/A"),
                  _buildDetailRow(Icons.directions_car, 'Plate Number',
                      userProfile?['plate_number'] ?? "N/A"),
                  _buildDetailRow(Icons.two_wheeler, 'Vehicle Type',
                      userProfile?['vehicle_type'] ?? "N/A"),
                  _buildDetailRow(Icons.car_repair, 'Vehicle Model',
                      userProfile?['vehicle_model'] ?? "N/A"),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2CAFB3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      padding: EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditUserScreen(user: widget.user)),
                      ).then((updated) {
                        if (updated == true) {
                          Navigator.pop(context, true);
                        }
                      });
                    },
                    child: Text('Edit User',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF1AA6B8), size: 28),
          SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1AA6B8)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}