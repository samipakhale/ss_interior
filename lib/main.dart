import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      home: const AuthWrapper(),
    );
  }
}

// ================= AUTH WRAPPER (Handles Instagram-like Session) =================

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF121212), strokeWidth: 2),
            ),
          );
        }
        if (snapshot.hasData) {
          return const SiteSelectionScreen();
        }
        return const WelcomeScreen();
      },
    );
  }
}

// ================= WELCOME SCREEN =================

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
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
                  child: const Icon(
                    Icons.chair_rounded,
                    size: 70,
                    color: Color(0xFF121212),
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
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= SIGN UP SCREEN (Firebase Auth) =================

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SiteSelectionScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Registration failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
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
                'Set up your owner credentials securely in Cloud',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 30),
              _buildTextField(controller: _emailController, hintText: 'Email ID', icon: Icons.email_outlined),
              const SizedBox(height: 16),
              _buildTextField(controller: _passwordController, hintText: 'Password', icon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 16),
              _buildTextField(controller: _confirmPasswordController, hintText: 'Confirm Password', icon: Icons.lock_reset_outlined, isPassword: true),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0095F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Register & Continue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, required IconData icon, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

// ================= LOGIN SCREEN (Firebase Auth) =================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SiteSelectionScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Login failed'), backgroundColor: Colors.red.shade400),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
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
                'Log in to sync your site data from Cloud',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 36),
              _buildTextField(controller: _emailController, hintText: 'Email ID', icon: Icons.email_outlined),
              const SizedBox(height: 16),
              _buildTextField(controller: _passwordController, hintText: 'Password', icon: Icons.lock_outline, isPassword: true),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0095F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Log In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, required IconData icon, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

// ================= SITE SELECTION SCREEN (Firestore Cloud Synced) =================

class SiteSelectionScreen extends StatefulWidget {
  const SiteSelectionScreen({super.key});

  @override
  State<SiteSelectionScreen> createState() => _SiteSelectionScreenState();
}

class _SiteSelectionScreenState extends State<SiteSelectionScreen> {
  final TextEditingController _siteNameController = TextEditingController();

  CollectionReference get _sitesCollection {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('sites');
  }

  Future<void> _addNewSite(String siteName) async {
    if (siteName.trim().isEmpty) return;
    await _sitesCollection.add({
      'name': siteName.trim(),
      'purchases': [],
      'transportations': [],
      'labours': [],
      'extraNotes': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteSite(String docId) async {
    await _sitesCollection.doc(docId).delete();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
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
              _addNewSite(_siteNameController.text);
              Navigator.pop(context);
            },
            child: const Text('ADD SITE', style: TextStyle(color: Colors.white)),
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
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF121212)),
            tooltip: 'Logout',
            onPressed: _logout,
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _sitesCollection.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF121212)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No active sites on Cloud. Tap "+" to create one.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE CLOUD SITES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final siteData = doc.data() as Map<String, dynamic>;
                      final siteId = doc.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
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
                            siteData['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: const Text('Synced with Cloud Database', style: TextStyle(fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.grey.shade400, size: 22),
                                onPressed: () => _deleteSite(siteId),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OwnerDashboard(
                                  siteId: siteId,
                                  siteData: siteData,
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
          );
        },
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
  final String siteId;
  final Map<String, dynamic> siteData;

  const OwnerDashboard({
    super.key,
    required this.siteId,
    required this.siteData,
  });

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  late Map<String, dynamic> _currentData;

  @override
  void initState() {
    super.initState();
    _currentData = widget.siteData;
  }

  Future<void> _updateCloudData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('sites')
        .doc(widget.siteId)
        .update(_currentData);
  }

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
    final purchasesList = _castToListMap(_currentData['purchases']);
    final transportationsList = _castToListMap(_currentData['transportations']);
    final laboursList = _castToListMap(_currentData['labours']);
    final extraNotesList = _castToListMap(_currentData['extraNotes']);

    double totalPurchaseExpense = purchasesList.fold(0.0, (acc, item) => acc + (double.tryParse(item['amount'] ?? '0') ?? 0.0));
    double totalTransportExpense = transportationsList.fold(0.0, (acc, item) => acc + (double.tryParse(item['amount'] ?? '0') ?? 0.0));
    double totalLabourExpense = laboursList.fold(0.0, (acc, item) => acc + (double.tryParse(item['amount'] ?? '0') ?? 0.0));
    double totalExtraExpense = extraNotesList.fold(0.0, (acc, item) => acc + (double.tryParse(item['amount']?.replaceAll('₹', '') ?? '0') ?? 0.0));

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
              _currentData['name'] ?? '',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF121212),
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const Text(
              'Cloud Synced Dashboard',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
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
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL SITE EXPENSE',
                        style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
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
                  const Icon(Icons.cloud_done_rounded, color: Colors.white, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
                children: [
                  _buildCard('Purchase', Icons.shopping_bag_outlined, purchasesList.length, const Color(0xFFFF6B6B), '₹ ${totalPurchaseExpense.toStringAsFixed(0)}', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseScreen(purchases: purchasesList))).then((_) {
                      setState(() => _currentData['purchases'] = purchasesList);
                      _updateCloudData();
                    });
                  }),
                  _buildCard('Transport', Icons.local_shipping_outlined, transportationsList.length, const Color(0xFF4D96FF), '₹ ${totalTransportExpense.toStringAsFixed(0)}', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TransportationScreen(transportations: transportationsList))).then((_) {
                      setState(() => _currentData['transportations'] = transportationsList);
                      _updateCloudData();
                    });
                  }),
                  _buildCard('Labour', Icons.people_outline_rounded, laboursList.length, const Color(0xFF6BCB77), '₹ ${totalLabourExpense.toStringAsFixed(0)}', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LabourScreen(labours: laboursList))).then((_) {
                      setState(() => _currentData['labours'] = laboursList);
                      _updateCloudData();
                    });
                  }),
                  _buildCard('Billing', Icons.receipt_long_outlined, 0, const Color(0xFF9B51E0), '₹ ${grandTotalExpense.toStringAsFixed(0)}', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BillingScreen(
                      siteName: _currentData['name'],
                      purchases: purchasesList,
                      transportations: transportationsList,
                      labours: laboursList,
                    )));
                  }),
                  _buildCard('Extra Notes', Icons.note_add_outlined, extraNotesList.length, const Color(0xFFFFB830), '₹ ${totalExtraExpense.toStringAsFixed(0)}', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ExtraScreen(extraNotesList: extraNotesList))).then((_) {
                      setState(() => _currentData['extraNotes'] = extraNotesList);
                      _updateCloudData();
                    });
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, int badgeCount, Color accentColor, String subtext, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.15), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: accentColor),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtext, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: accentColor)),
            ],
          ),
        ),
      ),
    );
  }
}