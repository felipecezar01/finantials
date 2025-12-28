import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';

class ExpensesTitleSheet extends StatefulWidget {
  final String value;
  final Map<String, dynamic> category;

  final dynamic editKey;
  final Map<String, dynamic>? initialTransaction;

  const ExpensesTitleSheet({
    super.key,
    required this.value,
    required this.category,
    this.editKey,
    this.initialTransaction,
  });

  @override
  State<ExpensesTitleSheet> createState() => _ExpensesTitleSheetState();
}

class _ExpensesTitleSheetState extends State<ExpensesTitleSheet> {
  late TextEditingController _titleController;
  final _expensesBox = Hive.box('expenses');

  late DateTime _selectedDate;
  late int _installmentsCount;

  @override
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      _titleController = TextEditingController(text: widget.initialTransaction!['title']);
      _selectedDate = DateTime.parse(widget.initialTransaction!['date']);
      _installmentsCount = widget.initialTransaction!['installments'];
    } else {
      _titleController = TextEditingController();
      _selectedDate = DateTime.now();
      _installmentsCount = 1;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String get formattedValue {
    final cleanValue = widget.value.replaceAll(',', '.');
    final doubleVal = double.tryParse(cleanValue) ?? 0.0;
    return doubleVal.toStringAsFixed(2);
  }

  void _incrementInstallments() { setState(() { if (_installmentsCount < 48) _installmentsCount++; }); }
  void _decrementInstallments() { setState(() { if (_installmentsCount > 1) _installmentsCount--; }); }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFF653FFF), onPrimary: Colors.white, onSurface: Colors.white, surface: Color(0xFF1C1C1E))), child: child!),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBottomPadding = max(MediaQuery.of(context).viewInsets.bottom, MediaQuery.of(context).padding.bottom);
    final dateString = "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}";

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          children: [
            // TOP BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)), child: const Icon(Icons.close, color: Colors.white, size: 20)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text('Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // INPUT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _titleController, autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Expense title',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 32, fontWeight: FontWeight.bold),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24, width: 2)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24, width: 2)),
                  contentPadding: const EdgeInsets.only(bottom: 8),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // DATA & PARCELAS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildActionRow(icon: Icons.calendar_today, label: 'Date', child: Text(dateString, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), onTap: () => _selectDate(context)),
                  const SizedBox(height: 12),
                  _buildActionRow(
                    icon: Icons.layers, label: 'Installments',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(onTap: _decrementInstallments, child: Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)), child: const Icon(Icons.chevron_left, color: Colors.white, size: 20))),
                        const SizedBox(width: 12),
                        Text('${_installmentsCount}x', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        GestureDetector(onTap: _incrementInstallments, child: Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)), child: const Icon(Icons.chevron_right, color: Colors.white, size: 20))),
                      ],
                    ), onTap: null,
                  ),
                ],
              ),
            ),
            const Spacer(),
            // FOOTER ADD
            Container(
              padding: EdgeInsets.only(top: 20, bottom: effectiveBottomPadding + 16),
              decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), border: Border.all(color: Colors.white.withOpacity(0.2), width: 1)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$formattedValue BRL', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.2))),
                          child: Row(children: [Container(width: 24, height: 24, decoration: BoxDecoration(color: widget.category['color'], shape: BoxShape.circle), child: Icon(widget.category['icon'], color: Colors.white, size: 14)), const SizedBox(width: 8), Text(widget.category['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(height: 1, width: double.infinity, color: Colors.white.withOpacity(0.2)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF1C1C1E), border: Border.all(color: Colors.white.withOpacity(0.1))), child: const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 24)),
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 4))],
                                  color: Colors.white, // Botão Branco
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final cleanValue = widget.value.replaceAll(',', '.');
                                    final doubleVal = double.tryParse(cleanValue) ?? 0.0;
                                    final newExpense = {
                                      'title': _titleController.text.trim().isEmpty ? 'Untitled' : _titleController.text.trim(),
                                      'value': doubleVal,
                                      'date': _selectedDate.toIso8601String(),
                                      'installments': _installmentsCount,
                                      'categoryName': widget.category['name'],
                                      'categoryColor': (widget.category['color'] as Color).value,
                                      'categoryIcon': (widget.category['icon'] as IconData).codePoint,
                                    };

                                    if (widget.editKey != null) {
                                      await _expensesBox.put(widget.editKey, newExpense);
                                    } else {
                                      await _expensesBox.add(newExpense);
                                    }

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 32)),
                                  icon: Icon(widget.editKey != null ? Icons.save : Icons.add, color: Colors.black),
                                  label: Text(widget.editKey != null ? 'Save' : 'Add', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow({required IconData icon, required String label, required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [Icon(icon, color: Colors.white70, size: 20), const SizedBox(width: 12), Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500))), child]),
      ),
    );
  }
}