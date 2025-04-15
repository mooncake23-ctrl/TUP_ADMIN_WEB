import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isSubmitting = false;
  String _statusMessage = '';
  List<dynamic> users = [];
  final Color _primaryColor = Color(0xFF71BFDC);
  final Color _backgroundColor = Color(0xFFF8F6F6);

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('https://appfinity.vercel.app/admin'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('users') && data['users'] is List) {
          setState(() {
            users = data['users'];
          });
        } else {
          setState(() {
            users = [data];
          });
        }
      } else {
        setState(() {
          _statusMessage = 'Failed to load users: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error fetching users: ${e.toString()}';
      });
      developer.log('Error fetching users', error: e);
    }
  }

  Future<void> sendMessageToUser(String userId, String message) async {
    try {
      if (userId.isEmpty) {
        throw Exception('Invalid user ID');
      }

      setState(() {
        _isSubmitting = true;
        _statusMessage = '';
      });

      developer.log('Attempting to send message to user $userId');

      final Map<String, dynamic> requestBody = {
        'name': _nameController.text,
        'email': _emailController.text,
        'message': message,
        'userId': userId,
      };

      developer.log('Request body: $requestBody');

      final response = await http.post(
        Uri.parse('https://appfinity.vercel.app/contact'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _statusMessage = 'Message sent successfully!';
        });
      } else {
        final errorResponse = json.decode(response.body);
        final errorMessage = errorResponse['message'] ?? 'Failed to send message';
        throw Exception('$errorMessage (${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
      });
      developer.log('Error sending message', error: e);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> sendMessageToAllUsers(String message) async {
    try {
      setState(() {
        _isSubmitting = true;
        _statusMessage = '';
      });

      if (_formKey.currentState?.validate() ?? false) {
        int successCount = 0;

        for (var user in users) {
          try {
            final userId = user['id']?.toString() ?? user['_id']?.toString() ?? '';
            if (userId.isNotEmpty) {
              await sendMessageToUser(userId, message);
              successCount++;
            }
          } catch (e) {
            developer.log('Error sending to ${user['email']}', error: e);
          }
        }

        setState(() {
          _statusMessage = 'Message sent to $successCount/${users.length} users successfully!';
          if (successCount == users.length) {
            _nameController.clear();
            _emailController.clear();
            _messageController.clear();
          }
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
      });
      developer.log('Error sending to all users', error: e);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showUserMessageDialog(Map<String, dynamic> user) {
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _backgroundColor,
          title: Text(
            'Send Message to ${user['name'] ?? 'User'}',
            style: TextStyle(color: _primaryColor),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: messageController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Your Message',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a message';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: _primaryColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
              ),
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final userId = user['id']?.toString() ?? user['_id']?.toString() ?? '';
                  await sendMessageToUser(userId, messageController.text);
                  Navigator.pop(context);
                }
              },
              child: Text('Send', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Contact Users',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send Message to Users',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Fill out the form below to send a message to users.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: _emailController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Your Email',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: _messageController,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Message',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a message';
                              } else if (value.length < 10) {
                                return 'Message should be at least 10 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _isSubmitting ? null : () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  sendMessageToAllUsers(_messageController.text);
                                }
                              },
                              child: _isSubmitting
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                'SEND TO ALL USERS',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          if (_statusMessage.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _statusMessage.contains('Error') || _statusMessage.contains('Failed')
                                    ? Colors.red[100]
                                    : Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _statusMessage.contains('Error') || _statusMessage.contains('Failed')
                                        ? Icons.error_outline
                                        : Icons.check_circle_outline,
                                    color: _statusMessage.contains('Error') || _statusMessage.contains('Failed')
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _statusMessage,
                                      style: TextStyle(
                                        color: _statusMessage.contains('Error') || _statusMessage.contains('Failed')
                                            ? Colors.red[800]
                                            : Colors.green[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Recipients (${users.length} users)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            SizedBox(height: 10),
            if (users.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 50, color: Colors.grey[400]),
                    SizedBox(height: 10),
                    Text(
                      'No users found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return InkWell(
                      onTap: () => _showUserMessageDialog(user),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(user['name']?.toString().substring(0, 1) ?? '?',
                              style: TextStyle(color: _primaryColor)),
                          backgroundColor: _primaryColor.withOpacity(0.2),
                        ),
                        title: Text(
                          user['name']?.toString() ?? 'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          user['email']?.toString() ?? 'No email',
                          style: TextStyle(color: Colors.black54),
                        ),
                        trailing: Icon(Icons.send, color: _primaryColor),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}