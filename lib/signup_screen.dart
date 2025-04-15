import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _particleController;
  List<Offset> _particles = [];

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    )..repeat();
    _generateParticles();
  }

  void _generateParticles() {
    final random = Random();
    _particles = List.generate(30, (_) => Offset(random.nextDouble() * 400, random.nextDouble() * 800));
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final url = Uri.parse("https://appfinity.vercel.app/admin/add");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "name": nameController.text.trim(),
          "password_hash": hashPassword(passwordController.text.trim()),
        }),
      );
      final responseData = jsonDecode(response.body);
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.statusCode == 200 && responseData["status"] == "ok"
            ? "✅ Admin created successfully! Please login."
            : "❌ Signup failed: ${responseData['message']}")),
      );
      if (response.statusCode == 200 && responseData["status"] == "ok") {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF71BFDC),
                  Color(0xFF9676D6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Center(
            child: Container(
              width: 400,
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12)],
                border: Border.all(color: Colors.white.withOpacity(0.6)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(nameController, "Full Name", Icons.person, false),
                    SizedBox(height: 20),
                    _buildTextField(emailController, "Email", Icons.email, false),
                    SizedBox(height: 20),
                    _buildTextField(passwordController, "Password", Icons.lock, true),
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Sign Up", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: Text("Already have an account? Login",
                          style: TextStyle(fontSize: 16, color: Colors.white, decoration: TextDecoration.underline)),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isPassword) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: TextStyle(fontSize: 18, color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        )
            : null,
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
      ),
      validator: (value) => value!.isEmpty ? "Please enter your $label" : null,
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Offset> particles;
  final double progress;
  final Random _random = Random();

  ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0);

    for (var i = 0; i < particles.length; i++) {
      final Offset offset = Offset(
        particles[i].dx + (_random.nextDouble() * 2 - 1) * 10,
        particles[i].dy - progress * 400,
      );
      canvas.drawCircle(offset, _random.nextDouble() * 6 + 2, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
