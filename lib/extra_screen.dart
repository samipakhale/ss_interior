import 'package:flutter/material.dart';

class ExtraScreen extends StatefulWidget {
  final List<Map<String, String>> extraNotesList;

  const ExtraScreen({super.key, required this.extraNotesList});

  @override
  State<ExtraScreen> createState() => _ExtraScreenState();
}

class _ExtraScreenState extends State<ExtraScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _personController = TextEditingController();

  String _selectedCategory = 'Expense';
  String _paymentMethod = 'UPI';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = ['Expense', 'Site Note', 'Advance Paid'];
  final List<String> _payMethods = ['UPI', 'Cash', 'Bank Transfer', 'Other'];

  void _showEntryBottomSheet({int? index}) {
    final isEditing = index != null;

    if (isEditing) {
      final item = widget.extraNotesList[index];
      _titleController.text = item['title'] ?? '';
      _detailsController.text = item['details'] ?? '';
      _personController.text = item['person'] ?? '';
      _selectedCategory = item['category'] ?? 'Expense';
      _paymentMethod = item['payMethod'] ?? 'UPI';
      _amountController.text = (item['amount'] ?? '').replaceAll(RegExp(r'[^0-9.]'), '');
    } else {
      _titleController.clear();
      _amountController.clear();
      _detailsController.clear();
      _personController.clear();
      _selectedCategory = 'Expense';
      _paymentMethod = 'UPI';
      _selectedDate = DateTime.now();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isEditing ? 'Edit Entry' : 'New Log / Expense',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E2C),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Selector Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(cat),
                              selected: isSelected,
                              selectedColor: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                              checkmarkColor: const Color(0xFF6C5CE7),
                              labelStyle: TextStyle(
                                color: isSelected ? const Color(0xFF6C5CE7) : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              backgroundColor: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              onSelected: (selected) {
                                setModalState(() => _selectedCategory = cat);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildCustomTextField(
                      controller: _titleController,
                      label: 'Title / Subject',
                      hint: 'e.g. Tea & Snacks / Hardware purchase',
                      icon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 12),

                    if (_selectedCategory != 'Site Note') ...[
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildCustomTextField(
                              controller: _amountController,
                              label: 'Amount (₹)',
                              hint: '0.00',
                              icon: Icons.currency_rupee_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _paymentMethod,
                                  isExpanded: true,
                                  items: _payMethods.map((m) {
                                    return DropdownMenuItem(
                                      value: m,
                                      child: Text(m, style: const TextStyle(fontSize: 13)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setModalState(() => _paymentMethod = val);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildCustomTextField(
                        controller: _personController,
                        label: 'Paid To / Given To',
                        hint: 'e.g. Electrician / Vendor name',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 12),
                    ],

                    _buildCustomTextField(
                      controller: _detailsController,
                      label: 'Additional Notes / Specs',
                      hint: 'Enter extra details...',
                      icon: Icons.notes_rounded,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          if (_titleController.text.trim().isNotEmpty) {
                            setState(() {
                              final updatedData = {
                                'title': _titleController.text.trim(),
                                'category': _selectedCategory,
                                'amount': _selectedCategory != 'Site Note'
                                    ? '₹${_amountController.text.trim()}'
                                    : '-',
                                'payMethod': _paymentMethod,
                                'person': _personController.text.trim(),
                                'date': '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                'details': _detailsController.text.trim(),
                              };

                              if (isEditing) {
                                widget.extraNotesList[index] = updatedData;
                              } else {
                                widget.extraNotesList.insert(0, updatedData);
                              }
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          isEditing ? 'UPDATE LOG' : 'SAVE LOG',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF6C5CE7), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          'Site Notes & Expenses',
          style: TextStyle(color: Color(0xFF1E1E2C), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF1E1E2C)),
      ),
      body: widget.extraNotesList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.note_add_outlined, size: 48, color: Color(0xFF6C5CE7)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Extra Notes or Expenses Yet',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1E2C)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap the + button to log site expenses, notes, or advances.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: widget.extraNotesList.length,
              itemBuilder: (context, index) {
                final item = widget.extraNotesList[index];
                final cat = item['category'] ?? 'Expense';
                
                Color themeColor = cat == 'Expense' 
                    ? const Color(0xFFFF7675) 
                    : (cat == 'Advance Paid' ? const Color(0xFF00B894) : const Color(0xFF0984E3));
                
                IconData catIcon = cat == 'Expense' 
                    ? Icons.account_balance_wallet_rounded 
                    : (cat == 'Advance Paid' ? Icons.payments_rounded : Icons.sticky_note_2_rounded);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(catIcon, color: themeColor, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        cat.toUpperCase(),
                                        style: TextStyle(
                                          color: themeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      Text(
                                        item['date'] ?? '',
                                        style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['title'] ?? 'Untitled',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF1E1E2C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if ((item['details'] ?? '').isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            item['details']!,
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.3),
                          ),
                        ],
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (cat != 'Site Note')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item['amount']} (${item['payMethod'] ?? 'UPI'})',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: themeColor,
                                    ),
                                  ),
                                  if ((item['person'] ?? '').isNotEmpty)
                                    Text(
                                      'To: ${item['person']}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                    ),
                                ],
                              )
                            else
                              const SizedBox.shrink(),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
                                  onPressed: () => _showEntryBottomSheet(index: index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      widget.extraNotesList.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6C5CE7),
        elevation: 4,
        onPressed: () => _showEntryBottomSheet(),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}