import 'package:flutter/material.dart';

class TransportationScreen extends StatefulWidget {
  final List<Map<String, String>> transportations;

  const TransportationScreen({super.key, required this.transportations});

  @override
  State<TransportationScreen> createState() => _TransportationScreenState();
}

class _TransportationScreenState extends State<TransportationScreen> {
  final _driverController = TextEditingController();
  final _vehicleNoController = TextEditingController();
  final _fromLocationController = TextEditingController();
  final _toLocationController = TextEditingController();
  final _distanceKmController = TextEditingController();
  final _materialController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedVehicleType = 'Truck';
  final List<String> _vehicleTypes = [
    'Truck',
    'Tempo',
    'Tractor',
    'Pickup (Bolero)',
    'Dumper',
    'Container',
    'Other'
  ];

  // Modern Dark Color Palette
  static const Color bgDark = Color(0xFF0F0F12);
  static const Color cardDark = Color(0xFF1B1B22);
  static const Color inputBg = Color(0xFF262630);
  static const Color accentGold = Color(0xFFE5C158);
  static const Color textLight = Color(0xFFF4F4F6);

  void _openTransportationForm({int? editIndex}) {
    if (editIndex != null) {
      final item = widget.transportations[editIndex];
      _driverController.text = item['driver'] ?? '';
      _vehicleNoController.text = item['vehicle'] ?? '';
      _fromLocationController.text = item['from'] ?? '';
      _toLocationController.text = item['to'] ?? '';
      _distanceKmController.text = item['distance'] ?? '';
      _materialController.text = item['material'] ?? '';
      _amountController.text = item['amount']?.replaceAll('₹', '') ?? '';
      _selectedVehicleType = _vehicleTypes.contains(item['vehicleType'])
          ? item['vehicleType']!
          : 'Truck';
    } else {
      _driverController.clear();
      _vehicleNoController.clear();
      _fromLocationController.clear();
      _toLocationController.clear();
      _distanceKmController.clear();
      _materialController.clear();
      _amountController.clear();
      _selectedVehicleType = 'Truck';
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 30,
                spreadRadius: 5,
              )
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      editIndex != null ? 'Edit Transport Log' : 'New Transport Log',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textLight,
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
                        child: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // Transporter / Driver Name
                _buildModernTextField(
                  controller: _driverController,
                  label: 'Driver / Transporter Name',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),

                // Vehicle Type Dropdown & Vehicle Number Row
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedVehicleType,
                            dropdownColor: cardDark,
                            isExpanded: true,
                            style: const TextStyle(color: textLight, fontSize: 13, fontWeight: FontWeight.w600),
                            items: _vehicleTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedVehicleType = val);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: _buildModernTextField(
                        controller: _vehicleNoController,
                        label: 'Vehicle No.',
                        icon: Icons.subtitles_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // From Location -> To Location
                Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        controller: _fromLocationController,
                        label: 'From (Source)',
                        icon: Icons.trip_origin_rounded,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.arrow_right_alt_rounded, color: accentGold, size: 20),
                    ),
                    Expanded(
                      child: _buildModernTextField(
                        controller: _toLocationController,
                        label: 'To (Destination)',
                        icon: Icons.location_on_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Distance (KM) & Total Amount
                Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        controller: _distanceKmController,
                        label: 'Distance (KM)',
                        icon: Icons.add_road_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildModernTextField(
                        controller: _amountController,
                        label: 'Amount (₹)',
                        icon: Icons.currency_rupee_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Material Description
                _buildModernTextField(
                  controller: _materialController,
                  label: 'Material Description',
                  icon: Icons.inventory_2_outlined,
                ),
                const SizedBox(height: 20),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textLight,
                      foregroundColor: bgDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (_driverController.text.isNotEmpty &&
                          _amountController.text.isNotEmpty) {
                        setState(() {
                          final newRecord = {
                            'driver': _driverController.text,
                            'vehicle': _vehicleNoController.text,
                            'vehicleType': _selectedVehicleType,
                            'from': _fromLocationController.text,
                            'to': _toLocationController.text,
                            'distance': _distanceKmController.text,
                            'material': _materialController.text,
                            'amount': _amountController.text,
                            'date': editIndex != null
                                ? (widget.transportations[editIndex]['date'] ?? 'Today')
                                : 'Today',
                          };

                          if (editIndex != null) {
                            widget.transportations[editIndex] = newRecord;
                          } else {
                            widget.transportations.insert(0, newRecord);
                          }
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      editIndex != null ? 'UPDATE LOG' : 'SAVE LOG',
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
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: textLight, fontSize: 13, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        filled: true,
        fillColor: inputBg,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentGold, width: 1),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _driverController.dispose();
    _vehicleNoController.dispose();
    _fromLocationController.dispose();
    _toLocationController.dispose();
    _distanceKmController.dispose();
    _materialController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Total Expense Calculation
    double totalExpense = widget.transportations.fold(0.0, (sum, item) {
      double val = double.tryParse(item['amount']?.replaceAll('₹', '') ?? '0') ?? 0.0;
      return sum + val;
    });

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Transport Activity',
          style: TextStyle(
            color: textLight,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: textLight),
      ),
      body: Column(
        children: [
          // Header Glassmorphic Summary Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF23232D), Color(0xFF16161D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
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
                      'TOTAL SPENT',
                      style: TextStyle(
                        color: accentGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${totalExpense.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: textLight,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: accentGold,
                    size: 26,
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Transport Record List
          Expanded(
            child: widget.transportations.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.route_outlined, size: 54, color: Colors.white12),
                        SizedBox(height: 12),
                        Text(
                          'No transport records found',
                          style: TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: widget.transportations.length,
                    itemBuilder: (context, index) {
                      final item = widget.transportations[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: cardDark,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => _openTransportationForm(editIndex: index),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Driver Info & Amount Badge
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
                                              Icons.alt_route_rounded,
                                              color: accentGold,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['driver'] ?? 'Driver',
                                                style: const TextStyle(
                                                  color: textLight,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${item['vehicleType'] ?? 'Vehicle'} • ${item['vehicle'] ?? ''}',
                                                style: const TextStyle(
                                                  color: Colors.white38,
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
                                          color: textLight,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 14),
                                  Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                                  const SizedBox(height: 12),

                                  // Route: From -> To & Distance Tag
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(Icons.location_on_outlined, size: 15, color: Colors.white38),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                '${item['from'] ?? 'N/A'} ➔ ${item['to'] ?? 'N/A'}',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (item['distance'] != null && item['distance']!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: inputBg,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${item['distance']} KM',
                                            style: const TextStyle(
                                              color: accentGold,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Material Description & Date
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['material'] ?? '',
                                          style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        item['date'] ?? 'Today',
                                        style: const TextStyle(
                                          color: Colors.white24,
                                          fontSize: 11,
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
        backgroundColor: textLight,
        foregroundColor: bgDark,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onPressed: () => _openTransportationForm(),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'ADD LOG',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ),
    );
  }
}