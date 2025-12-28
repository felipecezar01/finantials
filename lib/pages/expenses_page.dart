import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; // Importante para data
import '../widgets/value_input_sheet.dart';
import '../widgets/category_input_sheet.dart';
import '../widgets/expenses_title_sheet.dart';

class ExpensesPage extends StatefulWidget {
  // Recebe a data para filtrar e calcular parcelas corretamente
  final DateTime selectedDate;

  const ExpensesPage({
    super.key,
    required this.selectedDate,
  });

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  dynamic _deleteItemKey;

  @override
  Widget build(BuildContext context) {
    final expensesBox = Hive.box('expenses');

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          if (_deleteItemKey != null) setState(() => _deleteItemKey = null);
        },
        child: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: expensesBox.listenable(),
            builder: (context, Box box, _) {
              final List<dynamic> allTransactions = box.values.toList();
              final List<dynamic> allKeys = box.keys.toList();

              // --- FILTRO DE DATA (IGUAL AO INCOME) ---
              List<dynamic> filteredTransactions = [];
              List<dynamic> filteredKeys = [];
              double totalExpense = 0;

              for (int i = 0; i < allTransactions.length; i++) {
                final transaction = allTransactions[i];
                final key = allKeys[i];

                final DateTime transDate = DateTime.parse(transaction['date']);
                final int installments = transaction['installments'];

                final startOfTransMonth = DateTime(transDate.year, transDate.month, 1);
                final startOfSelectedMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);

                final int monthDiff = (startOfSelectedMonth.year - startOfTransMonth.year) * 12 +
                    (startOfSelectedMonth.month - startOfTransMonth.month);

                if (monthDiff >= 0 && monthDiff < installments) {
                  filteredTransactions.add(transaction);
                  filteredKeys.add(key);
                  totalExpense += (transaction['value'] as double);
                }
              }
              // ----------------------------------------

              return Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child: filteredTransactions.isEmpty
                        ? _buildEmptyState()
                        : _buildContent(context, filteredTransactions, filteredKeys, totalExpense),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<dynamic> transactions, List<dynamic> keys, double total) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Expenses', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${total.toStringAsFixed(2)} BRL', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),

          const SizedBox(height: 32),

          // CHART
          SizedBox(
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 60,
                    sections: transactions.map((t) {
                      return PieChartSectionData(
                        color: Color(t['categoryColor']),
                        value: t['value'],
                        title: '',
                        radius: 50,
                        showTitle: false,
                        borderSide: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ),
                Container(width: 50, height: 50, decoration: const BoxDecoration(color: Color(0xFF1C1C1E), shape: BoxShape.circle), child: const Icon(Icons.arrow_upward, color: Colors.white, size: 24)),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // LISTA
          ListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final reversedIndex = transactions.length - 1 - index;
              final t = transactions[reversedIndex];
              final key = keys[reversedIndex];
              final bool isDeleteMode = (_deleteItemKey == key);

              // --- CÁLCULO DA PARCELA ---
              final int installments = t['installments'];
              final DateTime transDate = DateTime.parse(t['date']);
              final int currentParcel = ((widget.selectedDate.year - transDate.year) * 12 +
                  (widget.selectedDate.month - transDate.month)) + 1;

              return GestureDetector(
                onLongPress: () { HapticFeedback.heavyImpact(); setState(() => _deleteItemKey = key); },
                onTap: () {
                  if (isDeleteMode) {
                    Hive.box('expenses').delete(key); HapticFeedback.mediumImpact(); setState(() => _deleteItemKey = null);
                  } else {
                    showModalBottomSheet(
                      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                      builder: (_) => ExpensesTitleSheet(
                        value: t['value'].toString(),
                        category: {'name': t['categoryName'], 'color': Color(t['categoryColor']), 'icon': IconData(t['categoryIcon'], fontFamily: 'MaterialIcons')},
                        editKey: key, initialTransaction: Map<String, dynamic>.from(t),
                      ),
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDeleteMode ? const Color(0xFF251515) : const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(20),
                    border: isDeleteMode ? Border.all(color: Colors.redAccent.withOpacity(0.5)) : null,
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300), width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: isDeleteMode ? Colors.redAccent.withOpacity(0.2) : Color(t['categoryColor']),
                          shape: BoxShape.circle,
                          boxShadow: isDeleteMode ? [BoxShadow(color: Colors.redAccent.withOpacity(0.6), blurRadius: 10)] : [],
                        ),
                        child: Icon(isDeleteMode ? Icons.delete : IconData(t['categoryIcon'], fontFamily: 'MaterialIcons'), color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    isDeleteMode ? "Tap to delete" : t['title'],
                                    style: TextStyle(color: isDeleteMode ? Colors.redAccent : Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // --- INDICADOR DE PARCELA ---
                                if (!isDeleteMode && installments > 1)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$currentParcel/$installments', // <--- Ex: 2/12
                                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${t['value'].toStringAsFixed(2)} BRL', style: TextStyle(color: isDeleteMode ? Colors.redAccent : Colors.white70, fontSize: 14, fontWeight: FontWeight.w600, decoration: isDeleteMode ? TextDecoration.lineThrough : null)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    // Formata o mês correto vindo da HomePage
    final monthName = DateFormat('MMMM').format(widget.selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.04)),
      child: Row(
        children: [
          Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.2))), child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))),
          const Spacer(),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.2))),
              child: Row(children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(monthName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)) // <--- Mês correto
              ])
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 20)]),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.black),
              onPressed: () async {
                final value = await showModalBottomSheet<String>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const ValueInputSheet()
                );

                if (value != null && context.mounted) {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CategoryInputSheet(value: value, transactionType: 'expense'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No expenses yet', style: TextStyle(color: Colors.white38)));
  }
}