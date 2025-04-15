import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:typed_data'; // For Uint8List
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'users_screen.dart';
import 'notifications_screen.dart';
import 'parking_history_screen.dart';
import 'profiles_screen.dart';
import 'stores_screen.dart';
import 'violations_screen.dart';
import 'create_user_screen.dart';
import 'signup_screen.dart';
import 'contact_us_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AdminApp());
}

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueAccent.withOpacity(0.8),
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: _routes,
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("Page Not Found")),
          body: Center(
            child: Text(
              "404 - Page Not Found",
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }

  static final Map<String, WidgetBuilder> _routes = {
    '/login': (context) => LoginScreen(),
    '/dashboard': (context) => DashboardScreen(),
    '/users': (context) => UsersScreen(),
    '/notifications': (context) => NotificationsScreen(),
    '/parking_history': (context) => ParkingHistoryScreen(),
    '/profiles': (context) => ProfilesScreen(),
    '/stores': (context) => StoresScreen(),
    '/violations': (context) => ViolationsScreen(),
    '/create_user': (context) => CreateUserScreen(),
    '/signup': (context) => SignupScreen(),
    '/contact_us': (context) => ContactUsScreen(),
  };
}

class AppService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> storeToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}