import 'package:flutter/material.dart';

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
  String _paymentStatus = 'Paid';

  // Light Luxury Color Palette
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color inputBg = Color(0xFFF1F3F5);
  static const Color primaryDark = Color(0xFF1E2022);
  static const Color accentBrown = Color(0xFF8C6239);
  static const Color textMuted = Color(0xFF6C757D);

  void _calculateTotalAmount() {
    double rate = double.tryParse(_dailyRateController.text) ?? 0.0;
    int days = int.tryParse(_daysController.text) ?? 0;
    if (rate > 0 && days > 0) {
      _amountController.text = (rate * days).toStringAsFixed(0);
    }
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
      _paymentStatus = item['status'] ?? 'Paid';
    } else {
      _nameController.clear();
      _roleController.clear();
      _phoneController.clear();
      _dailyRateController.clear();
      _daysController.clear();
      _amountController.clear();
      _paymentStatus = 'Paid';
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
                        editIndex != null ? 'Edit Labour Entry' : 'New Labour Entry',
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
                  const SizedBox(height: 18),

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

                  _buildModernTextField(
                    controller: _amountController,
                    label: 'Total Amount (₹)',
                    icon: Icons.account_balance_wallet_outlined,
                    keyboardType: TextInputType.number,
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
                              color: _paymentStatus == 'Paid'
                                  ? const Color(0xFFE6F4EA)
                                  : inputBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _paymentStatus == 'Paid'
                                    ? const Color(0xFF137333)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: _paymentStatus == 'Paid'
                                      ? const Color(0xFF137333)
                                      : textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Paid',
                                  style: TextStyle(
                                    color: _paymentStatus == 'Paid'
                                        ? const Color(0xFF137333)
                                        : textMuted,
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
                              color: _paymentStatus == 'Pending'
                                  ? const Color(0xFFFEF7E0)
                                  : inputBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _paymentStatus == 'Pending'
                                    ? const Color(0xFFB06000)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pending_actions_rounded,
                                  size: 16,
                                  color: _paymentStatus == 'Pending'
                                      ? const Color(0xFFB06000)
                                      : textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Pending',
                                  style: TextStyle(
                                    color: _paymentStatus == 'Pending'
                                        ? const Color(0xFFB06000)
                                        : textMuted,
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
                        if (_nameController.text.isNotEmpty &&
                            _amountController.text.isNotEmpty) {
                          setState(() {
                            final newRecord = {
                              'name': _nameController.text,
                              'role': _roleController.text,
                              'phone': _phoneController.text,
                              'dailyRate': _dailyRateController.text,
                              'days': _daysController.text,
                              'amount': _amountController.text,
                              'status': _paymentStatus,
                              'date': editIndex != null
                                  ? (widget.labours[editIndex]['date'] ?? 'Today')
                                  : 'Today',
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
                        editIndex != null ? 'UPDATE LABOUR' : 'SAVE LABOUR',
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double totalPaid = 0.0;
    double totalPending = 0.0;

    for (var item in widget.labours) {
      double val = double.tryParse(item['amount']?.replaceAll('₹', '') ?? '0') ?? 0.0;
      if (item['status'] == 'Pending') {
        totalPending += val;
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
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
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
            child: widget.labours.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.engineering_outlined, size: 54, color: Colors.black12),
                        SizedBox(height: 12),
                        Text(
                          'No labour records added yet',
                          style: TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: widget.labours.length,
                    itemBuilder: (context, index) {
                      final item = widget.labours[index];
                      final bool isPaid = item['status'] == 'Paid';

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
                            onTap: () => _openLabourForm(editIndex: index),
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
                                                '${item['role'] ?? 'Worker'}${item['phone'] != null && item['phone']!.isNotEmpty ? ' • ${item['phone']}' : ''}',
                                                style: const TextStyle(
                                                  color: textMuted,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '₹${item['amount']}',
                                        style: const TextStyle(
                                          color: primaryDark,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
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
                                          if (item['dailyRate'] != null && item['dailyRate']!.isNotEmpty) ...[
                                            Text(
                                              '₹${item['dailyRate']}/day',
                                              style: const TextStyle(color: textMuted, fontSize: 12),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          if (item['days'] != null && item['days']!.isNotEmpty)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: inputBg,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${item['days']} days',
                                                style: const TextStyle(
                                                  color: accentBrown,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isPaid
                                              ? const Color(0xFFE6F4EA)
                                              : const Color(0xFFFEF7E0),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          item['status'] ?? 'Paid',
                                          style: TextStyle(
                                            color: isPaid
                                                ? const Color(0xFF137333)
                                                : const Color(0xFFB06000),
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
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onPressed: () => _openLabourForm(),
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: const Text(
          'ADD LABOUR',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ),
    );
  }
}