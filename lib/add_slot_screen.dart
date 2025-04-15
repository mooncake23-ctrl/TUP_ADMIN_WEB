import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddSlotScreen extends StatefulWidget {
  @override
  _AddSlotScreenState createState() => _AddSlotScreenState();
}

class _AddSlotScreenState extends State<AddSlotScreen> {
  final String baseUrl = 'https://appfinity.vercel.app/stores';
  bool isLoading = false;
  String? newSlotName;

  final Color _primaryColor = Color(0xFFB76E79);
  final Color _secondaryColor = Color(0xFFF5E6D7);
  final Color _textColor = Color(0xFF5D4037);

  Future<void> _addSlot() async {
    setState(() => isLoading = true);
    try {
      // Step 1: Add new slot column
      final addResponse = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'unique_id': "12345", // Replace with actual store ID if needed
        }),
      );

      if (addResponse.statusCode == 200) {
        final responseData = json.decode(addResponse.body);
        final message = responseData['message'] as String;

        // Extract the new slot name from the message
        final slotNameRegExp = RegExp(r"'(slot\d+)'");
        final match = slotNameRegExp.firstMatch(message);
        if (match != null) {
          newSlotName = match.group(1); // Extract just the name like "slot6"

          // Step 2: Set the new slot status to "available"
          await _updateNewSlotToAvailable();

          Navigator.pop(context, true); // Go back to previous screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ New slot "$newSlotName" added and set to available'),
              backgroundColor: _primaryColor,
            ),
          );
        } else {
          throw Exception("Could not extract new slot name from response.");
        }
      } else {
        throw Exception("Failed to add slot: ${addResponse.statusCode}");
      }
    } catch (e) {
      _showErrorDialog("Error", "Failed to add slot: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateNewSlotToAvailable() async {
    if (newSlotName == null) return;

    final updateResponse = await http.post(
      Uri.parse('$baseUrl/update-slot'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'unique_id': "12345", // Replace with actual store ID if needed
        'slot': newSlotName,
        'new_value': 'available'
      }),
    );

    if (updateResponse.statusCode != 200) {
      throw Exception("Failed to update slot status: ${updateResponse.statusCode}");
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(color: _textColor)),
        content: Text(message, style: TextStyle(color: _textColor)),
        backgroundColor: _secondaryColor,
        actions: [
          TextButton(
            child: Text('OK', style: TextStyle(color: _primaryColor)),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _secondaryColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        title: Text("Add New Slot", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator(color: _primaryColor)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _addSlot,
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                "Add New Slot",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "This will create a new parking slot\nand set it to 'available' status",
              textAlign: TextAlign.center,
              style: TextStyle(color: _textColor),
            ),
          ],
        ),
      ),
    );
  }
}