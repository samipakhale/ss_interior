import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'purchase_screen.dart';
import 'transportation_screen.dart';
import 'labour_screen.dart';
import 'billing_screen.dart';
import 'extra_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Enable offline-first persistence for Firestore sync
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const SSInteriorApp());
}

class SSInteriorApp extends StatelessWidget {
  const SSInteriorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SS Interior Owner Portal',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF121212),
          primary: const Color(0xFF121212),
          secondary: const Color(0xFFC5A059),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// ================= WELCOME SCREEN =================

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? _savedUsername;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkSavedAccount();
  }

  Future<void> _checkSavedAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SiteSelectionScreen()),
        (route) => false,
      );
      return;
    }

    setState(() {
      _savedUsername = prefs.getString('owner_username');
      _isChecking = false;
    });
  }

  Future<void> _quickLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SiteSelectionScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF121212), strokeWidth: 2),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              
              // App Logo
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 90,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.chair_rounded,
                        size: 70,
                        color: Color(0xFF121212),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'SS INTERIOR WORK',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: const Color(0xFF121212),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Exclusive Owner Workspace',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 40),

              if (_savedUsername != null) ...[
                Center(
                  child: SizedBox(
                    width: 280,
                    child: GestureDetector(
                      onTap: _quickLogin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Color(0xFF121212),
                                  child: Icon(Icons.person, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _savedUsername!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF121212),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tap to continue',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Switch Account / Log In',
                    style: TextStyle(
                      color: Color(0xFF0095F6),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ] else ...[
                Center(
                  child: SizedBox(
                    width: 280,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0095F6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        'Create New Account',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Already have an account? Log In',
                    style: TextStyle(
                      color: Color(0xFF0095F6),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= SIGN UP SCREEN =================

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _signUp() async {
    String id = _idController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (id.isEmpty || password.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match!');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('owner_username', id);
    await prefs.setString('owner_password', password);
    await prefs.setBool('is_logged_in', true);

    if (mounted) {
      _showMessage('Account Created Successfully!', isError: false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SiteSelectionScreen()),
        (route) => false,
      );
    }
  }

  void _showMessage(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF121212)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Text(
                'Create Account',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF121212),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Set up your owner credentials',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 30),

              _buildTextField(
                controller: _idController,
                hintText: 'Mobile Number or Email ID',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                hintText: 'Set Password',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                icon: Icons.lock_reset_outlined,
                isPassword: true,
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0095F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _signUp,
                  child: const Text(
                    'Register & Continue',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

// ================= LOGIN SCREEN =================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    
    String? savedUsername = prefs.getString('owner_username');
    String? savedPassword = prefs.getString('owner_password');

    if (savedUsername == null || savedPassword == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No account found. Please create an account first.'),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (_usernameController.text.trim() == savedUsername &&
        _passwordController.text == savedPassword) {
      
      await prefs.setBool('is_logged_in', true);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SiteSelectionScreen()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid Mobile/Email or Password!'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF121212)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome Back',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF121212),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Log in using your Mobile Number or Email ID',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 36),

              _buildTextField(
                controller: _usernameController,
                hintText: 'Mobile Number or Email ID',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                hintText: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0095F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _login,
                  child: const Text(
                    'Log In',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(
                      color: Color(0xFF0095F6),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

// ================= CHANGE PASSWORD SCREEN =================

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newUsernameController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  Future<void> _updateCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    String currentSavedPass = prefs.getString('owner_password') ?? '';

    if (_currentPasswordController.text != currentSavedPass) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Current password is incorrect!'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (_newUsernameController.text.trim().isNotEmpty) {
      await prefs.setString('owner_username', _newUsernameController.text.trim());
    }

    if (_newPasswordController.text.trim().isNotEmpty) {
      await prefs.setString('owner_password', _newPasswordController.text.trim());
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Security credentials updated!'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newUsernameController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Security',
          style: TextStyle(color: Color(0xFF121212), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF121212)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Update Account Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
            ),
            const SizedBox(height: 18),
            _buildInputField(_currentPasswordController, 'Current Password', Icons.lock_clock, true),
            const SizedBox(height: 14),
            _buildInputField(_newUsernameController, 'New Mobile / Email (Optional)', Icons.person_outline, false),
            const SizedBox(height: 14),
            _buildInputField(_newPasswordController, 'New Password', Icons.lock_outline, true),
            const SizedBox(height: 28),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF121212),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _updateCredentials,
                child: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, IconData icon, bool isPass) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}

// ================= SITE SELECTION SCREEN =================

class SiteSelectionScreen extends StatefulWidget {
  const SiteSelectionScreen({super.key});

  @override
  State<SiteSelectionScreen> createState() => _SiteSelectionScreenState();
}

class _SiteSelectionScreenState extends State<SiteSelectionScreen> {
  List<Map<String, dynamic>> _sites = [];
  bool _isLoading = true;
  final TextEditingController _siteNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSitesFromStorage();
  }

  @override
  void dispose() {
    _siteNameController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _parseListMap(dynamic listData) {
    if (listData == null || listData is! List) return [];
    return listData.map((e) {
      if (e is Map) {
        return e.map((key, value) => MapEntry(key.toString(), value.toString()));
      }
      return <String, String>{};
    }).toList();
  }

  Future<void> _loadSitesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sitesData = prefs.getString('ss_interior_sites');
      if (sitesData != null && sitesData.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(sitesData);
        setState(() {
          _sites = jsonList.map((e) {
            final map = Map<String, dynamic>.from(e as Map);
            return {
              'name': map['name'] ?? '',
              'purchases': _parseListMap(map['purchases']),
              'transportations': _parseListMap(map['transportations']),
              'labours': _parseListMap(map['labours']),
              'extraNotes': _parseListMap(map['extraNotes']),
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        _setDefaultSite();
      }
    } catch (e) {
      _setDefaultSite();
    }
  }

  void _setDefaultSite() {
    setState(() {
      _sites = [
        {
          'name': 'Baner Flat 302',
          'purchases': <Map<String, String>>[],
          'transportations': <Map<String, String>>[],
          'labours': <Map<String, String>>[],
          'extraNotes': <Map<String, String>>[],
        }
      ];
      _isLoading = false;
    });
    _saveSitesToStorage();
  }

  Future<void> _saveSitesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(_sites);
    await prefs.setString('ss_interior_sites', jsonString);
  }

  Future<void> _logout() async {
    await _saveSitesToStorage();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  void _addNewSiteDialog() {
    _siteNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Site', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: TextField(
          controller: _siteNameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Model Colony Site',
            filled: true,
            fillColor: const Color(0xFFF2F4F7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0095F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (_siteNameController.text.trim().isNotEmpty) {
                setState(() {
                  _sites.add({
                    'name': _siteNameController.text.trim(),
                    'purchases': <Map<String, String>>[],
                    'transportations': <Map<String, String>>[],
                    'labours': <Map<String, String>>[],
                    'extraNotes': <Map<String, String>>[],
                  });
                });
                _saveSitesToStorage();
                Navigator.pop(context);
              }
            },
            child: const Text('ADD SITE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteSite(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Site?'),
        content: Text('Are you sure you want to delete "${_sites[index]['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _sites.removeAt(index);
              });
              _saveSitesToStorage();
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Site',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF121212),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: Color(0xFF121212)),
            tooltip: 'Security',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF121212)),
            tooltip: 'Logout',
            onPressed: _logout,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF121212)))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTIVE SITES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sites.isEmpty
                      ? const Expanded(
                          child: Center(
                            child: Text(
                              'No active sites. Tap "+" to create one.',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _sites.length,
                            itemBuilder: (context, index) {
                              final site = _sites[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF121212),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 22),
                                  ),
                                  title: Text(
                                    site['name'],
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  subtitle: const Text('Tap to open dashboard', style: TextStyle(fontSize: 12)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.delete_outline, color: Colors.grey.shade400, size: 22),
                                        onPressed: () => _deleteSite(index),
                                      ),
                                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OwnerDashboard(
                                          siteData: site,
                                          onDataChanged: () {
                                            _saveSitesToStorage();
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF121212),
        elevation: 4,
        onPressed: _addNewSiteDialog,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

// ================= OWNER DASHBOARD =================

class OwnerDashboard extends StatefulWidget {
  final Map<String, dynamic> siteData;
  final VoidCallback onDataChanged;

  const OwnerDashboard({
    super.key,
    required this.siteData,
    required this.onDataChanged,
  });

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  List<Map<String, String>> _castToListMap(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map((e) {
      if (e is Map) {
        return e.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
      return <String, String>{};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final purchasesList = _castToListMap(widget.siteData['purchases']);
    final transportationsList = _castToListMap(widget.siteData['transportations']);
    final laboursList = _castToListMap(widget.siteData['labours']);
    final extraNotesList = _castToListMap(widget.siteData['extraNotes']);

    // Totals Calculation
    double totalPurchaseExpense = 0.0;
    for (var item in purchasesList) {
      totalPurchaseExpense += double.tryParse(item['amount'] ?? item['cost'] ?? '0') ?? 0.0;
    }

    double totalTransportExpense = 0.0;
    for (var item in transportationsList) {
      totalTransportExpense += double.tryParse(item['amount'] ?? item['cost'] ?? '0') ?? 0.0;
    }

    double totalLabourExpense = 0.0;
    for (var item in laboursList) {
      totalLabourExpense += double.tryParse(item['amount'] ?? item['wage'] ?? '0') ?? 0.0;
    }

    double totalExtraExpense = 0.0;
    for (var item in extraNotesList) {
      totalExtraExpense += double.tryParse(item['amount'] ?? item['cost'] ?? '0') ?? 0.0;
    }

    // Grand Total Expense
    double grandTotalExpense = totalPurchaseExpense + totalTransportExpense + totalLabourExpense + totalExtraExpense;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF121212)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.siteData['name'],
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF121212),
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const Text(
              'Dashboard Overview',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ================= MODERN BLUE TOTAL EXPENSE BANNER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4D96FF), Color(0xFF2376F8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4D96FF).withValues(alpha: 0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL SITE EXPENSE',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹ ${grandTotalExpense.toStringAsFixed(0)}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ================= DASHBOARD GRID =================
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
                children: [
                  _buildInstagramCard(
                    title: 'Purchase',
                    icon: Icons.shopping_bag_outlined,
                    badgeCount: purchasesList.length,
                    accentColor: const Color(0xFFFF6B6B),
                    subtext: '₹ ${totalPurchaseExpense.toStringAsFixed(0)}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PurchaseScreen(purchases: purchasesList),
                        ),
                      ).then((_) {
                        widget.siteData['purchases'] = purchasesList;
                        widget.onDataChanged();
                        setState(() {});
                      });
                    },
                  ),
                  _buildInstagramCard(
                    title: 'Transport',
                    icon: Icons.local_shipping_outlined,
                    badgeCount: transportationsList.length,
                    accentColor: const Color(0xFF4D96FF),
                    subtext: '₹ ${totalTransportExpense.toStringAsFixed(0)}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransportationScreen(
                            transportations: transportationsList,
                          ),
                        ),
                      ).then((_) {
                        widget.siteData['transportations'] = transportationsList;
                        widget.onDataChanged();
                        setState(() {});
                      });
                    },
                  ),
                  _buildInstagramCard(
                    title: 'Labour',
                    icon: Icons.people_outline_rounded,
                    badgeCount: laboursList.length,
                    accentColor: const Color(0xFF6BCB77),
                    subtext: '₹ ${totalLabourExpense.toStringAsFixed(0)}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LabourScreen(
                            labours: laboursList,
                          ),
                        ),
                      ).then((_) {
                        widget.siteData['labours'] = laboursList;
                        widget.onDataChanged();
                        setState(() {});
                      });
                    },
                  ),
                  _buildInstagramCard(
                    title: 'Billing',
                    icon: Icons.receipt_long_outlined,
                    badgeCount: 0,
                    accentColor: const Color(0xFF9B51E0),
                    subtext: '₹ ${grandTotalExpense.toStringAsFixed(0)}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BillingScreen(
                            siteName: widget.siteData['name'],
                            purchases: purchasesList,
                            transportations: transportationsList,
                            labours: laboursList,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildInstagramCard(
                    title: 'Extra Notes',
                    icon: Icons.note_add_outlined,
                    badgeCount: extraNotesList.length,
                    accentColor: const Color(0xFFFFB830),
                    subtext: '₹ ${totalExtraExpense.toStringAsFixed(0)}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExtraScreen(extraNotesList: extraNotesList),
                        ),
                      ).then((_) {
                        widget.siteData['extraNotes'] = extraNotesList;
                        widget.onDataChanged();
                        setState(() {});
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstagramCard({
    required String title,
    required IconData icon,
    required int badgeCount,
    required Color accentColor,
    required VoidCallback onTap,
    String? subtext,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withValues(alpha: 0.15),
                            accentColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 28, color: accentColor),
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF121212),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            '$badgeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: 0.3,
                  ),
                ),
                if (subtext != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtext,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}