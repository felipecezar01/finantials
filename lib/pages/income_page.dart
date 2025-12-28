import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../widgets/value_input_sheet.dart';
import '../widgets/category_input_sheet.dart';
import '../widgets/income_title_sheet.dart';

class IncomePage extends StatefulWidget {
  final DateTime selectedDate;

  const IncomePage({
    super.key,
    required this.selectedDate,
  });

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  dynamic _deleteItemKey;

  @override
  Widget build(BuildContext context) {
    final incomesBox = Hive.box('incomes');

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          if (_deleteItemKey != null) {
            setState(() {
              _deleteItemKey = null;
            });
          }
        },
        child: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: incomesBox.listenable(),
            builder: (context, Box box, _) {
              final List<dynamic> allTransactions = box.values.toList();
              final List<dynamic> allKeys = box.keys.toList();

              List<dynamic> filteredTransactions = [];
              List<dynamic> filteredKeys = [];
              double totalIncome = 0;

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
                  totalIncome += (transaction['value'] as double);
                }
              }

              return Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child: filteredTransactions.isEmpty
                        ? _buildEmptyState()
                        : _buildContent(context, filteredTransactions, filteredKeys, totalIncome),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<dynamic> transactions, List<dynamic> keys, double totalIncome) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Income', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${totalIncome.toStringAsFixed(2)} BRL', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),

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
                      final value = t['value'] as double;
                      final color = Color(t['categoryColor']);
                      return PieChartSectionData(
                        color: color,
                        value: value,
                        title: '',
                        radius: 50,
                        showTitle: false,
                        borderSide: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(color: Color(0xFF1C1C1E), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_downward, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // LISTA
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final reversedIndex = transactions.length - 1 - index;
              final transaction = transactions[reversedIndex];
              final key = keys[reversedIndex];

              final bool isDeleteMode = (_deleteItemKey == key);

              final color = Color(transaction['categoryColor']);
              final icon = IconData(transaction['categoryIcon'], fontFamily: 'MaterialIcons');
              final title = transaction['title'];
              final value = transaction['value'] as double;
              final percent = (totalIncome > 0) ? (value / totalIncome * 100) : 0.0;

              // --- CÁLCULO DA PARCELA ---
              final int installments = transaction['installments'];
              final DateTime transDate = DateTime.parse(transaction['date']);
              final int currentParcel = ((widget.selectedDate.year - transDate.year) * 12 + (widget.selectedDate.month - transDate.month)) + 1;
              // --------------------------

              return GestureDetector(
                onLongPress: () {
                  HapticFeedback.heavyImpact();
                  setState(() {
                    _deleteItemKey = key;
                  });
                },
                onTap: () {
                  if (isDeleteMode) {
                    Hive.box('incomes').delete(key);
                    HapticFeedback.mediumImpact();
                    setState(() {
                      _deleteItemKey = null;
                    });
                  } else {
                    final categoryMap = {
                      'name': transaction['categoryName'],
                      'color': color,
                      'icon': icon,
                    };

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => IncomeTitleSheet(
                        value: value.toString(),
                        category: categoryMap,
                        editKey: key,
                        initialTransaction: Map<String, dynamic>.from(transaction),
                      ),
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDeleteMode ? const Color(0xFF251515) : const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(20),
                    border: isDeleteMode
                        ? Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1)
                        : null,
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: isDeleteMode ? Colors.redAccent.withOpacity(0.2) : color,
                          shape: BoxShape.circle,
                          boxShadow: isDeleteMode ? [
                            BoxShadow(color: Colors.redAccent.withOpacity(0.6), blurRadius: 10, spreadRadius: 2)
                          ] : [],
                        ),
                        child: Icon(
                            isDeleteMode ? Icons.delete : icon,
                            color: Colors.white,
                            size: 24
                        ),
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
                                    isDeleteMode ? "Tap to delete" : title,
                                    style: TextStyle(
                                        color: isDeleteMode ? Colors.redAccent : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // --- MOSTRAR PARCELA OU PORCENTAGEM ---
                                if (!isDeleteMode)
                                  if (installments > 1)
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
                                    )
                                  else
                                    Text(
                                      '${percent.toStringAsFixed(2)}%',
                                      style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                // ---------------------------------------
                              ],
                            ),

                            const SizedBox(height: 4),

                            Text(
                              '${value.toStringAsFixed(2)} BRL',
                              style: TextStyle(
                                color: isDeleteMode ? Colors.redAccent : Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: isDeleteMode ? TextDecoration.lineThrough : null,
                              ),
                            ),
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
    final monthName = DateFormat('MMMM').format(widget.selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.04)),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.2))),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(monthName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: const Color(0xFF2DE6A4).withOpacity(0.5), blurRadius: 20, spreadRadius: -2, offset: const Offset(0, 4)),
              ],
              gradient: const LinearGradient(colors: [Color(0xFF2DE6A4), Color(0xFF1FBF8A)]),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final value = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const ValueInputSheet(),
                );
                if (value == null) return;
                if (context.mounted) {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CategoryInputSheet(value: value),
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.sentiment_dissatisfied, color: Colors.white38, size: 56),
          SizedBox(height: 12),
          Text('No values yet', style: TextStyle(color: Colors.white38, fontSize: 16)),
        ],
      ),
    );
  }
}