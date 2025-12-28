import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../widgets/month_selector_sheet.dart';
import 'income_page.dart';
import 'expenses_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// ADICIONADO: WidgetsBindingObserver para escutar o ciclo de vida do app
class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  DateTime _currentDate = DateTime.now();

  // Caixas do Hive
  final Box incomesBox = Hive.box('incomes');
  final Box expensesBox = Hive.box('expenses');

  // Estado para deletar
  dynamic _deleteItemKey;
  String? _deleteItemType;

  @override
  void initState() {
    super.initState();
    // Registra o observador para saber quando o app abre/fecha
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove o observador para não dar erro de memória
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // --- LÓGICA DE ATUALIZAÇÃO AUTOMÁTICA (00:00h) ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      if (now.month != _currentDate.month || now.year != _currentDate.year) {
        setState(() {
          _currentDate = now;
        });
      }
    }
  }

  Future<void> _showMonthSelector(BuildContext context) async {
    final String? result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const MonthSelectorSheet(),
    );

    if (result != null) {
      setState(() {
        try {
          _currentDate = DateFormat('MMMM, yyyy').parse(result);
        } catch (e) {
          print("Erro data: $e");
        }
      });
    }
  }

  Map<String, double> _calculateFinance() {
    final incomes = incomesBox.values.toList();
    final expenses = expensesBox.values.toList();

    double totalIncomeAccumulated = 0;
    double totalExpenseAccumulated = 0;
    double monthlyIncome = 0;
    double monthlyExpense = 0;

    final now = DateTime.now();

    void processTransactions(List<dynamic> transactions, bool isIncome) {
      for (var item in transactions) {
        final value = item['value'] as double;
        final date = DateTime.parse(item['date']);
        final installments = item['installments'] as int;

        int monthsPassedSinceCreation =
            (now.year - date.year) * 12 + (now.month - date.month);
        if (monthsPassedSinceCreation >= 0) {
          int installmentsToCount =
          (monthsPassedSinceCreation + 1).clamp(0, installments);
          if (isIncome) {
            totalIncomeAccumulated += (value * installmentsToCount);
          } else {
            totalExpenseAccumulated += (value * installmentsToCount);
          }
        }

        int monthDiffSelected =
            (_currentDate.year - date.year) * 12 + (_currentDate.month - date.month);
        if (monthDiffSelected >= 0 && monthDiffSelected < installments) {
          if (isIncome) monthlyIncome += value;
          else monthlyExpense += value;
        }
      }
    }

    processTransactions(incomes, true);
    processTransactions(expenses, false);

    return {
      'totalBalance': totalIncomeAccumulated - totalExpenseAccumulated,
      'monthlyIncome': monthlyIncome,
      'monthlyExpense': monthlyExpense,
      'cashFlow': monthlyIncome - monthlyExpense,
    };
  }

  List<Map<String, dynamic>> _getDailyTransactions() {
    List<Map<String, dynamic>> dailyItems = [];

    void addItems(Box box, String type) {
      for (var key in box.keys) {
        final item = box.get(key);
        final date = DateTime.parse(item['date']);
        final installments = item['installments'] as int;

        int monthDiff =
            (_currentDate.year - date.year) * 12 + (_currentDate.month - date.month);

        if (monthDiff >= 0 && monthDiff < installments) {
          final displayDate = DateTime(_currentDate.year, _currentDate.month, date.day);
          dailyItems.add({
            'key': key,
            'type': type,
            'day': date.day,
            'originalData': item,
            'displayDate': displayDate
          });
        }
      }
    }

    addItems(incomesBox, 'income');
    addItems(expensesBox, 'expense');

    dailyItems.sort((a, b) => (b['day'] as int).compareTo(a['day'] as int));
    return dailyItems;
  }

  String _getMonthWithOrdinal(int month) {
    if (month == 1) return '1ˢᵗ';
    if (month == 2) return '2ⁿᵈ';
    if (month == 3) return '3ʳᵈ';
    return '${month}ᵗʰ';
  }

  @override
  Widget build(BuildContext context) {
    final String currentMonthName = DateFormat('MMMM').format(_currentDate);
    final String monthGeneralTitle =
        "$currentMonthName ${_getMonthWithOrdinal(_currentDate.month)}.";

    return ValueListenableBuilder(
      valueListenable: incomesBox.listenable(),
      builder: (context, Box boxIncomes, _) {
        return ValueListenableBuilder(
          valueListenable: expensesBox.listenable(),
          builder: (context, Box boxExpenses, _) {
            final financeData = _calculateFinance();
            final dailyTransactions = _getDailyTransactions();

            final cashFlow = financeData['cashFlow']!;
            final bool isNegativeFlow = cashFlow < 0;
            final String flowSign = cashFlow >= 0 ? '+' : '';
            final Color flowColor = isNegativeFlow
                ? const Color(0xFFFF453A)
                : const Color(0xFF2DE6A4);

            return Scaffold(
              backgroundColor: Colors.black,
              body: GestureDetector(
                onTap: () {
                  if (_deleteItemKey != null) {
                    setState(() {
                      _deleteItemKey = null;
                      _deleteItemType = null;
                    });
                  }
                },
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Text('My Finances',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600)),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => _showMonthSelector(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(24),
                                          border: Border.all(
                                              color: Colors.white24)),
                                      child: Row(children: [
                                        const Icon(Icons.calendar_today,
                                            color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Text(currentMonthName,
                                            style: const TextStyle(
                                                color: Colors.white))
                                      ]),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => _showMonthSelector(context),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white12,
                                          border: Border.all(
                                              color: Colors.white24)),
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(Icons.expand_more,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Text(
                                  'BRL ${financeData['totalBalance']!.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: _FinanceCard(
                                      title: 'Income',
                                      value:
                                      '${financeData['monthlyIncome']!.toStringAsFixed(2)} BRL',
                                      icon: Icons.arrow_downward,
                                      gradient: const [
                                        Color(0xFF2DE6A4),
                                        Color(0xFF1FBF8A)
                                      ],
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => IncomePage(
                                                selectedDate: _currentDate)),
                                      ),
                                      textColor: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _FinanceCard(
                                      title: 'Expenses',
                                      value:
                                      '${financeData['monthlyExpense']!.toStringAsFixed(2)} BRL',
                                      icon: Icons.arrow_upward,
                                      gradient: const [
                                        Color(0xFFF5F5F5),
                                        Color(0xFFDADADA)
                                      ],
                                      // <<< ALTERAÇÃO AQUI >>>
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ExpensesPage(
                                              selectedDate: _currentDate),
                                        ),
                                      ),
                                      // <<<
                                      textColor: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                  'Cash flow: $flowSign${cashFlow.toStringAsFixed(2)} BRL',
                                  style: TextStyle(
                                      color: flowColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.15)),
                              const SizedBox(height: 24),
                              Text(monthGeneralTitle,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        _buildTransactionList(dailyTransactions),
                        const SliverToBoxAdapter(
                            child: SizedBox(height: 40)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionList(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) {
      return const SliverToBoxAdapter(
          child: Center(
              child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text("No transactions this month",
                      style: TextStyle(color: Colors.white24)))));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final item = transactions[index];
          final displayDate = item['displayDate'] as DateTime;
          final itemKey = item['key'];
          final itemType = item['type'];
          final bool isDeleteMode =
          (_deleteItemKey == itemKey && _deleteItemType == itemType);
          final originalData = item['originalData'];
          final isIncome = item['type'] == 'income';
          final value = originalData['value'] as double;
          final title = originalData['title'];
          final categoryName = originalData['categoryName'];
          final categoryColor = Color(originalData['categoryColor']);
          final cardDateString =
          DateFormat('dd/MM/yyyy').format(displayDate);

          return GestureDetector(
            onLongPress: () {
              HapticFeedback.heavyImpact();
              setState(() {
                _deleteItemKey = itemKey;
                _deleteItemType = itemType;
              });
            },
            onTap: () {
              if (isDeleteMode) {
                if (itemType == 'income') {
                  incomesBox.delete(itemKey);
                } else {
                  expensesBox.delete(itemKey);
                }
                HapticFeedback.mediumImpact();
                setState(() {
                  _deleteItemKey = null;
                  _deleteItemType = null;
                });
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            IncomePage(selectedDate: _currentDate)));
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDeleteMode
                    ? const Color(0xFF251515)
                    : const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(24),
                border: isDeleteMode
                    ? Border.all(
                    color: Colors.redAccent.withOpacity(0.5), width: 1)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: categoryColor.withOpacity(0.5))),
                          child: Text(categoryName,
                              style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold))),
                      const Spacer(),
                      Text(cardDateString,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(isDeleteMode ? "Tap to delete" : title,
                      style: TextStyle(
                          color: isDeleteMode ? Colors.redAccent : Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDeleteMode
                                  ? Colors.redAccent.withOpacity(0.2)
                                  : (isIncome
                                  ? const Color(0xFF2DE6A4).withOpacity(0.1)
                                  : Colors.white.withOpacity(0.1)),
                              boxShadow: isDeleteMode
                                  ? [
                                BoxShadow(
                                    color:
                                    Colors.redAccent.withOpacity(0.6),
                                    blurRadius: 10,
                                    spreadRadius: 2)
                              ]
                                  : []),
                          child: Icon(
                              isDeleteMode
                                  ? Icons.delete
                                  : (isIncome
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward),
                              color: isDeleteMode
                                  ? Colors.white
                                  : (isIncome
                                  ? const Color(0xFF2DE6A4)
                                  : Colors.white),
                              size: 20)),
                      const SizedBox(width: 12),
                      Text('${value.toStringAsFixed(2)} BRL',
                          style: TextStyle(
                              color:
                              isDeleteMode ? Colors.redAccent : Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              decoration: isDeleteMode
                                  ? TextDecoration.lineThrough
                                  : null)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        childCount: transactions.length,
      ),
    );
  }
}

class _FinanceCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;
  final Color textColor;

  const _FinanceCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.onTap,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: gradient)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: textColor),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600))
            ]),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}