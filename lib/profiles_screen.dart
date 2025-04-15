import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class ProfilesScreen extends StatefulWidget {
  @override
  _ProfilesScreenState createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> with SingleTickerProviderStateMixin {
  List<dynamic> stores = [];
  List<dynamic> filteredStores = [];
  Map<String, dynamic>? selectedSlotDetails;
  String? selectedSlotNumber;
  bool isLoading = true;
  String? occupiedSlotUserInfo;

  // Light color palette
  final Color backgroundColor = Color(0xFFF8FAFC);
  final Color primaryColor = Color(0xFF71BFDC);
  final Color secondaryColor = Color(0xFF0B0C0C);
  final Color accentColor = Color(0xFF4FD1C5);
  final Color availableColor = Color(0xFF48BB78);
  final Color unavailableColor = Color(0xFFF56565);
  final Color textColor = Color(0xFF4A5568);
  final Color lightTextColor = Color(0xFF718096);
  final Color cardColor = Colors.white;
  final Color dividerColor = Color(0xFFEDF2F7);

  late AnimationController _controller;
  late Animation<double> _animation;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _fetchStores();
    _startRealTimeUpdates();
  }

  void _startRealTimeUpdates() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _fetchStores();
    });
  }

  Future<void> _fetchStores() async {
    try {
      final response = await http.get(Uri.parse('https://appfinity.vercel.app/stores'));
      if (response.statusCode == 200) {
        stores = json.decode(response.body);
        _applyFilters();
      } else {
        throw Exception('Failed to load stores');
      }
    } catch (e) {
      print('Error fetching stores: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _applyFilters() {
    if (mounted) {
      setState(() {
        filteredStores = stores;
        if (!isLoading) {
          _controller.forward(from: 0);
        }
      });
    }
  }

  void _showSlotDetails(String slotNumber, dynamic slotData) {
    setState(() {
      selectedSlotNumber = slotNumber;
      selectedSlotDetails = slotData is Map<String, dynamic> ? slotData : null;
    });

    if (selectedSlotDetails != null) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => Container(
          margin: EdgeInsets.only(top: 50),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: dividerColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Slot $slotNumber',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 20),
              if (selectedSlotDetails!['name'] != null)
                _buildDetailRow(Icons.person_outline, selectedSlotDetails!['name']),
              if (selectedSlotDetails!['email'] != null)
                _buildDetailRow(Icons.email_outlined, selectedSlotDetails!['email']),
              if (selectedSlotDetails!['phone'] != null)
                _buildDetailRow(Icons.phone_iphone_outlined, selectedSlotDetails!['phone']),
              if (selectedSlotDetails!['time'] != null)
                _buildDetailRow(Icons.access_time_outlined, selectedSlotDetails!['time']),
              if (selectedSlotDetails!['date'] != null)
                _buildDetailRow(Icons.calendar_today_outlined, selectedSlotDetails!['date']),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildDetailRow(IconData icon, String text) => Container(
    padding: EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: dividerColor,
          width: 1,
        ),
      ),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          color: secondaryColor,
          size: 22,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );

  int _availableSlotCount(Map<String, dynamic> store) {
    return List.generate(20, (i) => store['slot${i + 1}'] == 'available' ? 1 : 0)
        .fold(0, (a, b) => a + b);
  }

  void _onSlotOccupied(String slotNumber, Map<String, dynamic> slotData) async {
    String userName = slotData['name'];

    try {
      final response = await http.get(
        Uri.parse('https://appfinity.vercel.app/profile/$userName'),
        headers: {'accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        var profileData = json.decode(response.body);
        setState(() {
          occupiedSlotUserInfo =
          '👤 ${profileData['full_name']}\n🚗 ${profileData['vehicle_model']}\n🔢 ${profileData['plate_number']}';
        });

        Future.delayed(Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              occupiedSlotUserInfo = null;
            });
          }
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() {
        occupiedSlotUserInfo = 'Failed to load user info';
      });

      Future.delayed(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            occupiedSlotUserInfo = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Parking Slot Monitor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchStores,
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
            SizedBox(height: 16),
            Text(
              'Loading parking data...',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: filteredStores.map((store) {
                final availableCount = _availableSlotCount(store);
                final totalSlots = 20;
                final percentageAvailable = (availableCount / totalSlots * 100).round();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Parking Area ${stores.indexOf(store) + 1}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: percentageAvailable > 30
                                      ? availableColor.withOpacity(0.1)
                                      : unavailableColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$percentageAvailable% available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: percentageAvailable > 30
                                        ? availableColor
                                        : unavailableColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: availableCount / totalSlots,
                            backgroundColor: unavailableColor.withOpacity(0.05),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                availableColor),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Available: $availableCount',
                                style: TextStyle(
                                  color: availableColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Total: $totalSlots',
                                style: TextStyle(
                                  color: lightTextColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                            itemCount: 20,
                            itemBuilder: (context, i) {
                              final slotKey = 'slot${i + 1}';
                              final slotData = store[slotKey];
                              final isAvailable = slotData == 'available';

                              return GestureDetector(
                                onTap: () {
                                  if (isAvailable) {
                                    _onSlotOccupied((i + 1).toString(), slotData);
                                  }
                                  _showSlotDetails((i + 1).toString(), slotData);
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    color: isAvailable
                                        ? availableColor.withOpacity(0.8)
                                        : unavailableColor.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Icon(
                                          isAvailable
                                              ? Icons.check_circle_outline
                                              : Icons.highlight_off,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (occupiedSlotUserInfo != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: dividerColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_circle,
                        color: primaryColor,
                        size: 40,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          occupiedSlotUserInfo!,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }
}