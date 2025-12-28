import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'create_category_sheet.dart';
import 'income_title_sheet.dart';
import 'expenses_title_sheet.dart'; // <--- Import da nova tela de expenses

class CategoryInputSheet extends StatefulWidget {
  final String value;
  final String transactionType; // 'income' ou 'expense'

  const CategoryInputSheet({
    super.key,
    required this.value,
    this.transactionType = 'income', // Padrão income
  });

  @override
  State<CategoryInputSheet> createState() => _CategoryInputSheetState();
}

class _CategoryInputSheetState extends State<CategoryInputSheet> {
  final _categoriesBox = Hive.box('categories');
  bool _isDeleteMode = false;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: GestureDetector(
        onTap: () {
          if (_isDeleteMode) setState(() => _isDeleteMode = false);
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isDeleteMode ? 'Tap to delete' : 'Choose category',
                      style: TextStyle(color: _isDeleteMode ? Colors.redAccent : Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    if (_isDeleteMode)
                      TextButton(onPressed: () => setState(() => _isDeleteMode = false), child: const Text('Done', style: TextStyle(color: Colors.white))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _categoriesBox.listenable(),
                  builder: (context, Box box, _) {
                    List<dynamic> categoriesKeys = box.keys.toList();
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 3.2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                      ),
                      itemCount: categoriesKeys.length + 1,
                      itemBuilder: (context, index) {
                        if (index == categoriesKeys.length) {
                          return GestureDetector(
                            onTap: () async {
                              final newCategory = await showModalBottomSheet<Map<String, dynamic>>(
                                context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const CreateCategorySheet(),
                              );
                              if (newCategory != null) {
                                await _categoriesBox.add({
                                  'name': newCategory['name'],
                                  'colorValue': (newCategory['color'] as Color).value,
                                  'iconCode': (newCategory['icon'] as IconData).codePoint,
                                });
                              }
                            },
                            child: Opacity(
                              opacity: _isDeleteMode ? 0.3 : 1.0,
                              child: Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white, width: 1.5)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [Icon(Icons.add, color: Colors.white, size: 18), SizedBox(width: 8), Text('Add new', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))],
                                ),
                              ),
                            ),
                          );
                        }

                        final key = categoriesKeys[index];
                        final categoryData = box.get(key);
                        final Color catColor = Color(categoryData['colorValue']);
                        final IconData catIcon = IconData(categoryData['iconCode'], fontFamily: 'MaterialIcons');
                        final String catName = categoryData['name'];

                        return GestureDetector(
                          onTap: () {
                            if (_isDeleteMode) {
                              _categoriesBox.delete(key);
                              HapticFeedback.lightImpact();
                            } else {
                              Navigator.pop(context); // Fecha Category

                              // --- ROTEAMENTO DINÂMICO ---
                              if (widget.transactionType == 'income') {
                                showModalBottomSheet(
                                  context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                                  builder: (_) => IncomeTitleSheet(
                                    value: widget.value,
                                    category: {'name': catName, 'color': catColor, 'icon': catIcon},
                                  ),
                                );
                              } else {
                                showModalBottomSheet(
                                  context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                                  builder: (_) => ExpensesTitleSheet( // Chama a tela de Expenses
                                    value: widget.value,
                                    category: {'name': catName, 'color': catColor, 'icon': catIcon},
                                  ),
                                );
                              }
                            }
                          },
                          onLongPress: () {
                            HapticFeedback.heavyImpact();
                            setState(() => _isDeleteMode = true);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: _isDeleteMode ? Colors.red.withOpacity(0.2) : const Color(0xFF141414),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: _isDeleteMode ? Colors.red : Colors.white24, width: 1),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(4), width: 32, height: 32,
                                  decoration: BoxDecoration(color: _isDeleteMode ? Colors.red : catColor, shape: BoxShape.circle),
                                  child: Icon(_isDeleteMode ? Icons.delete : catIcon, color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(catName, style: TextStyle(color: _isDeleteMode ? Colors.red : Colors.white, fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Footer... (Mesmo código de antes para fechar/skip)
              // (Omiti o footer para economizar espaço, mantenha o que você já tinha)
            ],
          ),
        ),
      ),
    );
  }
}