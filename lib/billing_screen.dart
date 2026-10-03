import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingScreen extends StatefulWidget {
  final String? siteName;
  final List<Map<String, String>>? purchases;
  final List<Map<String, String>>? transportations;
  final List<Map<String, String>>? labours;

  const BillingScreen({
    super.key,
    this.siteName,
    this.purchases,
    this.transportations,
    this.labours,
  });

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientPhoneController = TextEditingController();
  final TextEditingController _siteAddressController = TextEditingController();
  final TextEditingController _invoiceNumberController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String _paymentStatus = 'Pending';

  List<Map<String, dynamic>> _invoiceItems = [];
  List<Map<String, dynamic>> _savedBillsRecord = [];
  int? _editingBillIndex;

  // Modal Item Controllers
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedUnit = 'Sq.ft';
  String _selectedCategory = 'Ceiling Work';

  final List<String> _unitOptions = ['Sq.ft', 'R.ft', 'Nos', 'Pcs', 'Lump sum', 'Days'];
  final List<String> _categoryOptions = [
    'Ceiling Work',
    'Carpentry & Furniture',
    'Painting & Polish',
    'Electrical Work',
    'Plumbing',
    'Civil Work',
    'Other Material'
  ];

  @override
  void initState() {
    super.initState();
    _invoiceNumberController.text = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    _loadSavedBills();
    _populateFromConstructor();
  }

  void _populateFromConstructor() {
    if (widget.siteName != null && widget.siteName!.isNotEmpty) {
      _siteAddressController.text = widget.siteName!;
    }

    double parseAmt(String? val) {
      if (val == null || val.isEmpty) return 0.0;
      return double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }

    if (widget.purchases != null) {
      for (var item in widget.purchases!) {
        double cost = parseAmt(item['amount'] ?? item['price'] ?? item['cost']);
        if (cost > 0) {
          _invoiceItems.add({
            'item': item['item'] ?? item['name'] ?? 'Purchase Item',
            'category': 'Other Material',
            'rate': cost,
            'qty': 1.0,
            'unit': 'Nos',
            'notes': '',
            'total': cost,
          });
        }
      }
    }

    if (widget.transportations != null) {
      for (var item in widget.transportations!) {
        double cost = parseAmt(item['amount'] ?? item['charges'] ?? item['cost']);
        if (cost > 0) {
          _invoiceItems.add({
            'item': 'Transport: ${item['details'] ?? item['type'] ?? 'Delivery'}',
            'category': 'Other Material',
            'rate': cost,
            'qty': 1.0,
            'unit': 'Lump sum',
            'notes': '',
            'total': cost,
          });
        }
      }
    }

    if (widget.labours != null) {
      for (var item in widget.labours!) {
        double cost = parseAmt(item['amount'] ?? item['wages'] ?? item['cost']);
        if (cost > 0) {
          _invoiceItems.add({
            'item': 'Labour: ${item['type'] ?? item['work'] ?? 'Labor Work'}',
            'category': 'Civil Work',
            'rate': cost,
            'qty': 1.0,
            'unit': 'Days',
            'notes': '',
            'total': cost,
          });
        }
      }
    }
  }

  Future<void> _loadSavedBills() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('saved_bills');
    if (savedData != null) {
      setState(() {
        List<dynamic> decoded = jsonDecode(savedData);
        _savedBillsRecord = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> _saveBillsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_bills', jsonEncode(_savedBillsRecord));
  }

  void _addItem() {
    final name = _itemNameController.text.trim();
    final double? rate = double.tryParse(_rateController.text);
    final double? qty = double.tryParse(_qtyController.text);
    final notes = _notesController.text.trim();

    if (name.isNotEmpty && rate != null && qty != null) {
      setState(() {
        _invoiceItems.add({
          'item': name,
          'category': _selectedCategory,
          'rate': rate,
          'qty': qty,
          'unit': _selectedUnit,
          'notes': notes,
          'total': rate * qty,
        });
      });
      _clearModalFields();
      Navigator.pop(context);
    }
  }

  void _clearModalFields() {
    _itemNameController.clear();
    _rateController.clear();
    _qtyController.clear();
    _notesController.clear();
    _selectedUnit = 'Sq.ft';
    _selectedCategory = 'Ceiling Work';
  }

  double get _subTotal {
    return _invoiceItems.fold(0.0, (sum, item) => sum + ((item['total'] ?? 0.0) as num).toDouble());
  }

  double get _discountAmount {
    final double? disc = double.tryParse(_discountController.text);
    return disc ?? 0.0;
  }

  double get _finalTotal {
    double total = _subTotal - _discountAmount;
    return total < 0 ? 0.0 : total;
  }

  void _clearForm() {
    setState(() {
      _clientNameController.clear();
      _clientPhoneController.clear();
      _siteAddressController.clear();
      _discountController.clear();
      _invoiceNumberController.text = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      _selectedDate = DateTime.now();
      _dueDate = DateTime.now().add(const Duration(days: 7));
      _paymentStatus = 'Pending';
      _invoiceItems = [];
      _editingBillIndex = null;
    });
  }

  void _loadBillForEditing(int index) {
    final bill = _savedBillsRecord[index];
    setState(() {
      _editingBillIndex = index;
      _clientNameController.text = bill['clientName'] ?? '';
      _clientPhoneController.text = bill['clientPhone'] ?? '';
      _siteAddressController.text = bill['siteAddress'] ?? '';
      _invoiceNumberController.text = bill['invoiceNo'] ?? '';
      _discountController.text = (bill['discount'] ?? 0.0).toString();
      _paymentStatus = bill['paymentStatus'] ?? 'Pending';
      if (bill['date'] != null) _selectedDate = DateTime.tryParse(bill['date']) ?? DateTime.now();
      if (bill['dueDate'] != null) _dueDate = DateTime.tryParse(bill['dueDate']) ?? DateTime.now();
      _invoiceItems = List<Map<String, dynamic>>.from(
        (bill['items'] as List).map((e) => Map<String, dynamic>.from(e)),
      );
    });
    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context, bool isDueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? _dueDate : _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  void _openAddItemModal() {
    _clearModalFields();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 10,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add Particular / Item',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A0845)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(dialogContext),
                          )
                        ],
                      ),
                      const Divider(height: 10),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            items: _categoryOptions.map((String cat) {
                              return DropdownMenuItem<String>(
                                value: cat,
                                child: Text(cat, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => _selectedCategory = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildModernTextField(
                        controller: _itemNameController,
                        label: 'Particular Description *',
                        hint: 'e.g. Gypsum Board Ceiling Work',
                        icon: Icons.design_services,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildModernTextField(
                              controller: _rateController,
                              label: 'Rate (₹)',
                              hint: '0.00',
                              icon: Icons.currency_rupee,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _buildModernTextField(
                              controller: _qtyController,
                              label: 'Qty',
                              hint: '1',
                              icon: Icons.numbers,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedUnit,
                                  isExpanded: true,
                                  items: _unitOptions.map((String u) {
                                    return DropdownMenuItem<String>(
                                      value: u,
                                      child: Text(u, style: const TextStyle(fontSize: 13)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setDialogState(() => _selectedUnit = val);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildModernTextField(
                        controller: _notesController,
                        label: 'Notes / Spec (Optional)',
                        hint: 'e.g. Saint-Gobain board',
                        icon: Icons.note_add_outlined,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8E24AA), Color(0xFFE91E63)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _addItem,
                          child: const Text('ADD PARTICULAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- PDF GENERATION WITH ASSETS LOGO ---
  Future<void> _printPdf({
    required String clientName,
    required String clientPhone,
    required String siteAddress,
    required String invoiceNo,
    required List<Map<String, dynamic>> items,
    required double subTotal,
    required double discount,
    required double finalTotal,
    required String dateStr,
    required String dueDateStr,
  }) async {
    final pdf = pw.Document();

    // Asset image load (.png / .jpg extension nu sar check karun gya)
    pw.MemoryImage? logoImage;
    try {
      final imageBytes = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());
    } catch (e) {
      try {
        final imageBytes = await rootBundle.load('assets/images/logo.jpg');
        logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());
      } catch (err) {
        debugPrint('Logo load error: $err');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          width: 60,
                          height: 60,
                          margin: const pw.EdgeInsets.only(right: 12),
                          child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                        )
                      else
                        pw.Container(
                          width: 50,
                          height: 50,
                          margin: const pw.EdgeInsets.only(right: 12),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.purple900,
                            borderRadius: pw.BorderRadius.circular(10),
                          ),
                          child: pw.Center(
                            child: pw.Text('SS', style: const pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 20)),
                          ),
                        ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('SS INTERIOR', style: const pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.purple900)),
                          pw.Text('Interior Design & Execution Specialist', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                        ],
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE', style: const pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.purple700)),
                      pw.Text('#$invoiceNo', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text('Invoice Date: $dateStr', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('Due Date: $dueDateStr', style: const pw.TextStyle(fontSize: 9, color: PdfColors.red700)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, height: 20, color: PdfColors.purple200),

              // Client Details
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('CLIENT DETAILS:', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.purple900)),
                    pw.SizedBox(height: 3),
                    pw.Text('Client Name: $clientName', style: const pw.TextStyle(fontSize: 10)),
                    if (clientPhone.isNotEmpty) pw.Text('Phone: $clientPhone', style: const pw.TextStyle(fontSize: 10)),
                    if (siteAddress.isNotEmpty) pw.Text('Site Location: $siteAddress', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // Items Table
              pw.TableHelper.fromTextArray(
                headers: ['#', 'Particular / Description', 'Category', 'Rate (Rs)', 'Qty', 'Unit', 'Total (Rs)'],
                data: List.generate(items.length, (index) {
                  final item = items[index];
                  String desc = item['item'] ?? '';
                  if (item['notes'] != null && (item['notes'] as String).isNotEmpty) {
                    desc += '\n(${item['notes']})';
                  }
                  return [
                    '${index + 1}',
                    desc,
                    '${item['category'] ?? '-'}',
                    '${item['rate']}',
                    '${item['qty']}',
                    '${item['unit'] ?? 'Sq.ft'}',
                    '${item['total']}',
                  ];
                }),
                headerStyle: const pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.purple800),
                cellHeight: 22,
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 12),

              // Sub Total & Grand Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Sub Total: Rs. ${subTotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
                      if (discount > 0)
                        pw.Text('Discount: - Rs. ${discount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.red)),
                      pw.SizedBox(height: 4),
                      pw.Text('Grand Total: Rs. ${finalTotal.toStringAsFixed(2)}',
                          style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              // Signature Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey600),
                      pw.SizedBox(height: 4),
                      pw.Text('Client Signature', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('For SS INTERIOR', style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.purple900)),
                      pw.SizedBox(height: 35),
                      pw.Container(width: 160, height: 1, color: PdfColors.grey600),
                      pw.SizedBox(height: 4),
                      pw.Text('Signature of Contractor', style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.purple900)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: PdfColors.grey300),
              pw.Center(
                child: pw.Text('Thank you for business with SS Interior!', style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.purple900)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void _saveOrUpdateAndPrint() async {
    if (_clientNameController.text.isEmpty || _invoiceItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Client Name & add at least 1 item.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final dateStr = '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
    final dueDateStr = '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}';

    final billData = {
      'invoiceNo': _invoiceNumberController.text,
      'clientName': _clientNameController.text,
      'clientPhone': _clientPhoneController.text,
      'siteAddress': _siteAddressController.text,
      'items': List<Map<String, dynamic>>.from(_invoiceItems),
      'subTotal': _subTotal,
      'discount': _discountAmount,
      'total': _finalTotal,
      'date': _selectedDate.toIso8601String(),
      'dueDate': _dueDate.toIso8601String(),
      'paymentStatus': _paymentStatus,
    };

    setState(() {
      if (_editingBillIndex != null) {
        _savedBillsRecord[_editingBillIndex!] = billData;
      } else {
        _savedBillsRecord.add(billData);
      }
    });

    await _saveBillsToStorage();

    await _printPdf(
      clientName: _clientNameController.text,
      clientPhone: _clientPhoneController.text,
      siteAddress: _siteAddressController.text,
      invoiceNo: _invoiceNumberController.text,
      items: _invoiceItems,
      subTotal: _subTotal,
      discount: _discountAmount,
      finalTotal: _finalTotal,
      dateStr: dateStr,
      dueDateStr: dueDateStr,
    );
  }

  void _openHistoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Saved Invoices', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2A0845))),
                  TextButton.icon(
                    onPressed: () {
                      _clearForm();
                      Navigator.pop(bottomSheetContext);
                    },
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF8E24AA)),
                    label: const Text('New Invoice', style: TextStyle(color: Color(0xFF8E24AA), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(),
              _savedBillsRecord.isEmpty
                  ? const Expanded(child: Center(child: Text('No saved invoices found.', style: TextStyle(color: Colors.grey))))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _savedBillsRecord.length,
                        itemBuilder: (context, index) {
                          final bill = _savedBillsRecord[index];
                          final double totalVal = ((bill['total'] ?? 0.0) as num).toDouble();
                          final String status = bill['paymentStatus'] ?? 'Pending';
                          Color statusColor = status == 'Paid' ? Colors.green : (status == 'Partial' ? Colors.orange : Colors.red);

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: const Color(0xFF8E24AA).withValues(alpha: 0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.receipt_long, color: Color(0xFF8E24AA)),
                              ),
                              title: Row(
                                children: [
                                  Expanded(child: Text(bill['clientName'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                              subtitle: Text('Inv #${bill['invoiceNo'] ?? '-'} | Total: ₹${totalVal.toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: const Icon(Icons.edit_note, color: Colors.blueAccent), onPressed: () => _loadBillForEditing(index)),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () async {
                                      setState(() => _savedBillsRecord.removeAt(index));
                                      setModalState(() {});
                                      await _saveBillsToStorage();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF8E24AA), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_editingBillIndex != null ? 'Edit Bill #${_editingBillIndex! + 1}' : 'Billing & Invoice', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF2A0845), Color(0xFF6441A5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _clearForm),
              IconButton(icon: const Icon(Icons.history, color: Colors.white), onPressed: _openHistoryModal),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Client & Invoice Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2A0845))),
                            if (_editingBillIndex != null)
                              GestureDetector(onTap: _clearForm, child: const Text('Cancel Edit', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildModernTextField(controller: _invoiceNumberController, label: 'Invoice No', hint: 'INV-101', icon: Icons.tag)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _paymentStatus,
                                    isExpanded: true,
                                    items: ['Pending', 'Paid', 'Partial'].map((String val) => DropdownMenuItem<String>(value: val, child: Text(val, style: const TextStyle(fontSize: 14)))).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _paymentStatus = val);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildModernTextField(controller: _clientNameController, label: 'Client Name *', hint: 'Enter full name', icon: Icons.person_outline),
                        const SizedBox(height: 10),
                        _buildModernTextField(controller: _clientPhoneController, label: 'Phone Number', hint: '+91 0000000000', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                        const SizedBox(height: 10),
                        _buildModernTextField(controller: _siteAddressController, label: 'Site Address', hint: 'Location / Site details', icon: Icons.location_on_outlined),
                        const SizedBox(height: 12),

                        // Date Section with clear labels
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(padding: EdgeInsets.only(left: 4, bottom: 4), child: Text('Invoice Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                                  InkWell(
                                    onTap: () => _selectDate(context, false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 18, color: Color(0xFF8E24AA)),
                                          const SizedBox(width: 8),
                                          Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(padding: EdgeInsets.only(left: 4, bottom: 4), child: Text('Due Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                                  InkWell(
                                    onTap: () => _selectDate(context, true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.event_available, size: 18, color: Colors.redAccent),
                                          const SizedBox(width: 8),
                                          Text('${_dueDate.day}/${_dueDate.month}/${_dueDate.year}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Particulars / Works', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2A0845))),
                      InkWell(
                        onTap: _openAddItemModal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF8E24AA), Color(0xFFE91E63)]), borderRadius: BorderRadius.circular(12)),
                          child: const Row(
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text('Add Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  _invoiceItems.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                          child: const Center(child: Text('No items added yet. Tap "Add Item" to add works.', style: TextStyle(color: Colors.grey))),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _invoiceItems.length,
                          itemBuilder: (context, itemIndex) {
                            final item = _invoiceItems[itemIndex];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6)]),
                              child: ListTile(
                                title: Text('${item['item']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Cat: ${item['category']} | ₹${item['rate']} × ${item['qty']} ${item['unit']}', style: const TextStyle(fontSize: 12)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('₹${item['total']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
                                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => setState(() => _invoiceItems.removeAt(itemIndex))),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)]),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sub Total', style: TextStyle(color: Colors.grey)),
                            Text('₹${_subTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Discount (₹)', style: TextStyle(color: Colors.grey)),
                            const Spacer(),
                            SizedBox(
                              width: 100,
                              height: 35,
                              child: TextField(
                                controller: _discountController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                onChanged: (val) => setState(() {}),
                                decoration: InputDecoration(hintText: '0.00', contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2A0845))),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF8E24AA), Color(0xFFE91E63)]).createShader(bounds),
                              child: Text('₹${_finalTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    height: 54,
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2A0845), Color(0xFF6441A5)]), borderRadius: BorderRadius.circular(16)),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: _saveOrUpdateAndPrint,
                      icon: Icon(_editingBillIndex != null ? Icons.update : Icons.print, color: Colors.white),
                      label: Text(_editingBillIndex != null ? 'UPDATE & PRINT PDF' : 'SAVE & GENERATE PDF', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}