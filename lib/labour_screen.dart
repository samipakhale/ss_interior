import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LabourScreen extends StatefulWidget {
  final List<Map<String, String>> labours;

  const LabourScreen({super.key, required this.labours});

  @override
  State<LabourScreen> createState() => _LabourScreenState();
}

class _LabourScreenState extends State<LabourScreen> {
  final _nameController = TextEditingController();
  final _roleController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dailyRateController = TextEditingController();
  final _daysController = TextEditingController();
  final _amountController = TextEditingController();
  final _advanceController = TextEditingController();
  final _searchController = TextEditingController();
  
  String _paymentStatus = 'Paid';
  String _attendanceStatus = 'Present'; 
  DateTime _selectedDate = DateTime.now();
  
  int _selectedTab = 0;
  String _searchQuery = '';

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color inputBg = Color(0xFFF1F3F5);
  static const Color primaryDark = Color(0xFF1E2022);
  static const Color accentBrown = Color(0xFF8C6239);
  static const Color textMuted = Color(0xFF6C757D);

  final List<String> _months = const [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  void _calculateTotalAmount() {
    double rate = double.tryParse(_dailyRateController.text) ?? 0.0;
    double days = double.tryParse(_daysController.text) ?? 0.0;
    if (rate > 0 && days > 0) {
      _amountController.text = (rate * days).toStringAsFixed(0);
    }
  }

  Future<void> _pickDate(BuildContext context, StateSetter setModalState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setModalState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    final bool launched = await launchUrl(launchUri);
    if (!mounted) return;
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone call'), backgroundColor: Colors.red),
      );
    }
  }

  void _deleteEntry(int index) {
    setState(() {
      widget.labours.removeAt(index);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Labour entry deleted successfully'), backgroundColor: Colors.red),
    );
  }

  void _openLabourForm({int? editIndex}) {
    if (editIndex != null) {
      final item = widget.labours[editIndex];
      _nameController.text = item['name'] ?? '';
      _roleController.text = item['role'] ?? '';
      _phoneController.text = item['phone'] ?? '';
      _dailyRateController.text = item['dailyRate'] ?? '';
      _daysController.text = item['days'] ?? '';
      _amountController.text = item['amount']?.replaceAll('₹', '') ?? '';
      _advanceController.text = item['advance']?.replaceAll('₹', '') ?? '0';
      _paymentStatus = item['status'] ?? 'Paid';
      _attendanceStatus = item['attendance'] ?? 'Present';
      
      try {
        _selectedDate = DateTime.parse(item['date'] ?? DateTime.now().toString());
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    } else {
      _nameController.clear();
      _roleController.clear();
      _phoneController.clear();
      _dailyRateController.clear();
      _daysController.text = '1';
      _amountController.clear();
      _advanceController.text = '0';
      _paymentStatus = 'Paid';
      _attendanceStatus = 'Present';
      _selectedDate = DateTime.now();
      _calculateTotalAmount();
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              color: cardLight,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        editIndex != null ? 'Edit Labour Entry' : 'Daily Attendance Entry',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: primaryDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: inputBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, color: primaryDark, size: 18),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ATTENDANCE DATE',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _pickDate(context, setModalState),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, size: 18, color: accentBrown),
                              const SizedBox(width: 10),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: const TextStyle(
                                  color: primaryDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Change',
                            style: TextStyle(color: accentBrown, fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ATTENDANCE STATUS',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _attendanceStatus = 'Present';
                              _daysController.text = '1';
                              _calculateTotalAmount();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _attendanceStatus == 'Present' ? const Color(0xFFE6F4EA) : inputBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _attendanceStatus == 'Present' ? const Color(0xFF137333) : Colors.transparent,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Present',
                                style: TextStyle(
                                  color: Color(0xFF137333),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _attendanceStatus = 'Half Day';
                              _daysController.text = '0.5';
                              _calculateTotalAmount();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _attendanceStatus == 'Half Day' ? const Color(0xFFFEF7E0) : inputBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _attendanceStatus == 'Half Day' ? const Color(0xFFB06000) : Colors.transparent,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Half Day',
                                style: TextStyle(
                                  color: Color(0xFFB06000),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _attendanceStatus = 'Absent';
                              _daysController.text = '0';
                              _calculateTotalAmount();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _attendanceStatus == 'Absent' ? const Color(0xFFFCE8E6) : inputBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _attendanceStatus == 'Absent' ? const Color(0xFFC5221F) : Colors.transparent,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Absent',
                                style: TextStyle(
                                  color: Color(0xFFC5221F),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildModernTextField(
                    controller: _nameController,
                    label: 'Worker / Labour Name',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernTextField(
                          controller: _roleController,
                          label: 'Role (e.g. Carpenter)',
                          icon: Icons.work_outline_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildModernTextField(
                          controller: _phoneController,
                          label: 'Phone No.',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernTextField(
                          controller: _dailyRateController,
                          label: 'Daily Rate (₹)',
                          icon: Icons.payments_outlined,
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            setModalState(() => _calculateTotalAmount());
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildModernTextField(
                          controller: _daysController,
                          label: 'Days Worked',
                          icon: Icons.calendar_today_outlined,
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            setModalState(() => _calculateTotalAmount());
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernTextField(
                          controller: _amountController,
                          label: 'Total Amount (₹)',
                          icon: Icons.account_balance_wallet_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildModernTextField(
                          controller: _advanceController,
                          label: 'Advance Taken (₹)',
                          icon: Icons.money_off_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PAYMENT STATUS',
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => _paymentStatus = 'Paid'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _paymentStatus == 'Paid' ? const Color(0xFFE6F4EA) : inputBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _paymentStatus == 'Paid' ? const Color(0xFF137333) : Colors.transparent,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF137333)),
                                SizedBox(width: 6),
                                Text(
                                  'Paid',
                                  style: TextStyle(
                                    color: Color(0xFF137333),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => _paymentStatus = 'Pending'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _paymentStatus == 'Pending' ? const Color(0xFFFEF7E0) : inputBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _paymentStatus == 'Pending' ? const Color(0xFFB06000) : Colors.transparent,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.pending_actions_rounded, size: 16, color: Color(0xFFB06000)),
                                SizedBox(width: 6),
                                Text(
                                  'Pending',
                                  style: TextStyle(
                                    color: Color(0xFFB06000),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (_nameController.text.isNotEmpty && _amountController.text.isNotEmpty) {
                          setState(() {
                            final newRecord = {
                              'name': _nameController.text,
                              'role': _roleController.text,
                              'phone': _phoneController.text,
                              'dailyRate': _dailyRateController.text,
                              'days': _daysController.text,
                              'amount': _amountController.text,
                              'advance': _advanceController.text.isEmpty ? '0' : _advanceController.text,
                              'status': _paymentStatus,
                              'attendance': _attendanceStatus,
                              'date': _selectedDate.toIso8601String(),
                            };

                            if (editIndex != null) {
                              widget.labours[editIndex] = newRecord;
                            } else {
                              widget.labours.insert(0, newRecord);
                            }
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        editIndex != null ? 'UPDATE ENTRY' : 'SAVE ATTENDANCE',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: primaryDark, fontSize: 13, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textMuted, fontSize: 12),
        prefixIcon: Icon(icon, color: textMuted, size: 18),
        filled: true,
        fillColor: inputBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentBrown, width: 1.5),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    _dailyRateController.dispose();
    _daysController.dispose();
    _amountController.dispose();
    _advanceController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double totalPaid = 0.0;
    double totalPending = 0.0;

    for (var item in widget.labours) {
      double val = double.tryParse(item['amount']?.replaceAll('₹', '') ?? '0') ?? 0.0;
      double adv = double.tryParse(item['advance']?.replaceAll('₹', '') ?? '0') ?? 0.0;
      double netVal = val - adv;
      if (item['status'] == 'Pending') {
        totalPending += netVal > 0 ? netVal : 0;
      } else {
        totalPaid += val;
      }
    }

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Labour Tracker',
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: primaryDark),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: inputBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? cardLight : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Daily List',
                          style: TextStyle(
                            color: _selectedTab == 0 ? primaryDark : textMuted,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? cardLight : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Monthly Report',
                          style: TextStyle(
                            color: _selectedTab == 1 ? primaryDark : textMuted,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
              style: const TextStyle(color: primaryDark, fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Search labour by name...',
                hintStyle: const TextStyle(color: textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: accentBrown, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: textMuted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: cardLight,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.04), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: accentBrown, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardLight,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PAID AMOUNT',
                      style: TextStyle(
                        color: Color(0xFF137333),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${totalPaid.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: primaryDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 35,
                  width: 1,
                  color: Colors.black.withValues(alpha: 0.08),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PENDING DUE',
                      style: TextStyle(
                        color: Color(0xFFB06000),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${totalPending.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: primaryDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: accentBrown,
                    size: 24,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _selectedTab == 0 ? _buildLabourListView() : _buildMonthlyReportView(),
          ),
        ],
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              backgroundColor: primaryDark,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              onPressed: () => _openLabourForm(),
              icon: const Icon(Icons.person_add_rounded, size: 20),
              label: const Text(
                'ADD ATTENDANCE',
                style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
              ),
            )
          : null,
    );
  }

  Widget _buildLabourListView() {
    List<Map<String, String>> filteredList = widget.labours.where((item) {
      final name = (item['name'] ?? '').toLowerCase();
      return name.contains(_searchQuery);
    }).toList();

    return filteredList.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.engineering_outlined, size: 54, color: Colors.black12),
                SizedBox(height: 12),
                Text(
                  'No matching attendance records found',
                  style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final item = filteredList[index];
              final originalIndex = widget.labours.indexOf(item);
              final bool isPaid = item['status'] == 'Paid';
              final String attendance = item['attendance'] ?? 'Present';
              final String advance = item['advance'] ?? '0';
              final String phone = item['phone'] ?? '';
              
              String formattedDate = 'Today';
              try {
                final dt = DateTime.parse(item['date'] ?? '');
                formattedDate = '${dt.day}/${dt.month}/${dt.year}';
              } catch (e) {
                formattedDate = item['date'] ?? 'Today';
              }
              
              Color attBg = const Color(0xFFE6F4EA);
              Color attColor = const Color(0xFF137333);
              if (attendance == 'Half Day') {
                attBg = const Color(0xFFFEF7E0);
                attColor = const Color(0xFFB06000);
              } else if (attendance == 'Absent') {
                attBg = const Color(0xFFFCE8E6);
                attColor = const Color(0xFFC5221F);
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardLight,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => _openLabourForm(editIndex: originalIndex),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: inputBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: accentBrown,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? 'Labour Name',
                                        style: const TextStyle(
                                          color: primaryDark,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${item['role'] ?? 'Worker'} • Date: $formattedDate',
                                        style: const TextStyle(
                                          color: textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${item['amount']}',
                                        style: const TextStyle(
                                          color: primaryDark,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (advance != '0' && advance.isNotEmpty)
                                        Text(
                                          'Adv: ₹$advance',
                                          style: const TextStyle(
                                            color: Color(0xFFB06000),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  if (phone.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.call_rounded, color: Color(0xFF137333), size: 20),
                                      onPressed: () => _makePhoneCall(phone),
                                      tooltip: 'Call Labour',
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                                    onPressed: () => _deleteEntry(originalIndex),
                                    tooltip: 'Delete Entry',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.black.withValues(alpha: 0.04), height: 1),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: attBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      attendance,
                                      style: TextStyle(
                                        color: attColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (item['days'] != null && item['days']!.isNotEmpty)
                                    Text(
                                      '(${item['days']} days)',
                                      style: const TextStyle(
                                        color: textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPaid ? const Color(0xFFE6F4EA) : const Color(0xFFFEF7E0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item['status'] ?? 'Paid',
                                  style: TextStyle(
                                    color: isPaid ? const Color(0xFF137333) : const Color(0xFFB06000),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildMonthlyReportView() {
    List<Map<String, String>> filteredLabours = widget.labours.where((item) {
      try {
        final dt = DateTime.parse(item['date'] ?? '');
        final matchesDate = dt.month == _selectedMonth && dt.year == _selectedYear;
        final name = (item['name'] ?? '').toLowerCase();
        final matchesName = name.contains(_searchQuery);
        return matchesDate && matchesName;
      } catch (e) {
        return false;
      }
    }).toList();

    Map<String, Map<String, dynamic>> reportSummary = {};

    for (var item in filteredLabours) {
      String name = item['name'] ?? 'Unknown';
      String role = item['role'] ?? 'Worker';
      String phone = item['phone'] ?? '';
      double days = double.tryParse(item['days'] ?? '0') ?? 0.0;
      double amount = double.tryParse(item['amount']?.replaceAll('₹', '') ?? '0') ?? 0.0;
      double advance = double.tryParse(item['advance']?.replaceAll('₹', '') ?? '0') ?? 0.0;
      String attendance = item['attendance'] ?? 'Present';

      if (!reportSummary.containsKey(name)) {
        reportSummary[name] = {
          'name': name,
          'role': role,
          'phone': phone,
          'totalDays': 0.0,
          'totalAmount': 0.0,
          'totalAdvance': 0.0,
          'present': 0,
          'halfDay': 0,
          'absent': 0,
        };
      }

      reportSummary[name]!['totalDays'] += days;
      reportSummary[name]!['totalAmount'] += amount;
      reportSummary[name]!['totalAdvance'] += advance;

      if (attendance == 'Present') {
        reportSummary[name]!['present'] += 1;
      } else if (attendance == 'Half Day') {
        reportSummary[name]!['halfDay'] += 1;
      } else if (attendance == 'Absent') {
        reportSummary[name]!['absent'] += 1;
      }
    }

    final summaryList = reportSummary.entries.map((e) => e.value).toList();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: cardLight,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 18, color: accentBrown),
                  SizedBox(width: 8),
                  Text('Select Month:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: primaryDark)),
                ],
              ),
              Row(
                children: [
                  DropdownButton<int>(
                    value: _selectedMonth,
                    underline: const SizedBox(),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(_months[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryDark)),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMonth = val);
                    },
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<int>(
                    value: _selectedYear,
                    underline: const SizedBox(),
                    items: List.generate(10, (index) {
                      int year = 2024 + index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text('$year', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: accentBrown)),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedYear = val);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: summaryList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assessment_outlined, size: 54, color: Colors.black12),
                      const SizedBox(height: 12),
                      Text(
                        'No records found for ${_months[_selectedMonth - 1]} $_selectedYear',
                        style: const TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardLight,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(inputBg),
                            dataRowMinHeight: 52,
                            dataRowMaxHeight: 60,
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(
                                label: Text('Labour Name', style: TextStyle(color: primaryDark, fontWeight: FontWeight.w800, fontSize: 12)),
                              ),
                              DataColumn(
                                label: Text('Role', style: TextStyle(color: primaryDark, fontWeight: FontWeight.w800, fontSize: 12)),
                              ),
                              DataColumn(
                                label: Text('Present', style: TextStyle(color: Color(0xFF137333), fontWeight: FontWeight.w800, fontSize: 12)),
                              ),
                              DataColumn(
                                label: Text('Half Day', style: TextStyle(color: Color(0xFFB06000), fontWeight: FontWeight.w800, fontSize: 12)),
                              ),
                              DataColumn(
                                label: Text('Absent', style: TextStyle(color: Color(0xFFC5221F), fontWeight: FontWeight.w800, fontSize: 12)),
                              ),
                              DataColumn(
                                label: Text('Total Days', style: TextStyle(color: accentBrown, fontWeight: FontWeight.w800, fontSize: 12)),
                              ),
                              DataColumn(
                                label: Text('Advance (₹)', style: TextStyle(color: Color(0xFFB06000), fontWeight: FontWeight.w800, fontSize: 12)),
                              ),
                              DataColumn(
                                label: Text('Net Payable (₹)', style: TextStyle(color: primaryDark, fontWeight: FontWeight.w800, fontSize: 12)),
                              ),
                            ],
                            rows: summaryList.map((data) {
                              double netAmt = data['totalAmount'] - data['totalAdvance'];
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(data['name'], style: const TextStyle(color: primaryDark, fontWeight: FontWeight.w700, fontSize: 13)),
                                  ),
                                  DataCell(
                                    Text(data['role'], style: const TextStyle(color: textMuted, fontSize: 12)),
                                  ),
                                  DataCell(
                                    Text('${data['present']}', style: const TextStyle(color: Color(0xFF137333), fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                  DataCell(
                                    Text('${data['halfDay']}', style: const TextStyle(color: Color(0xFFB06000), fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                  DataCell(
                                    Text('${data['absent']}', style: const TextStyle(color: Color(0xFFC5221F), fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                  DataCell(
                                    Text('${data['totalDays']}', style: const TextStyle(color: accentBrown, fontWeight: FontWeight.w800, fontSize: 13)),
                                  ),
                                  DataCell(
                                    Text('₹${data['totalAdvance'].toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFB06000), fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                  DataCell(
                                    Text('₹${netAmt.toStringAsFixed(0)}', style: const TextStyle(color: primaryDark, fontWeight: FontWeight.w900, fontSize: 13)),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}