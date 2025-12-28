import 'dart:ui';
import 'package:flutter/material.dart';
import 'icon_picker_sheet.dart';

class CreateCategorySheet extends StatefulWidget {
  const CreateCategorySheet({super.key});

  @override
  State<CreateCategorySheet> createState() => _CreateCategorySheetState();
}

class _CreateCategorySheetState extends State<CreateCategorySheet> {
  final TextEditingController _controller = TextEditingController();

  IconData selectedIcon = Icons.category;
  Color selectedColor = const Color(0xFF7B61FF);

  // --- LISTA EXPANDIDA DE 42 CORES ---
  final List<Color> colors = const [
    // Roxos e Rosas
    Color(0xFF7B61FF), Color(0xFFAA00FF), Color(0xFFEA80FC), Color(0xFFFF4081),
    Color(0xFFF50057), Color(0xFFFF80AB), Color(0xFFFF1744),

    // Vermelhos e Laranjas
    Color(0xFFFF5252), Color(0xFFFF6E40), Color(0xFFFF9100), Color(0xFFFFAB00),
    Color(0xFFFFEA00), Color(0xFFFFD600), Color(0xFFFFC400),

    // Verdes e Limas
    Color(0xFF76FF03), Color(0xFF64DD17), Color(0xFF00E676), Color(0xFF1DE9B6),
    Color(0xFF00BFA5), Color(0xFF00B8D4), Color(0xFF00E5FF),

    // Azuis e Turquesas
    Color(0xFF00B0FF), Color(0xFF40C4FF), Color(0xFF448AFF), Color(0xFF2979FF),
    Color(0xFF2962FF), Color(0xFF304FFE), Color(0xFF3D5AFE),

    // Tons Pastéis e Variados
    Color(0xFF8C9EFF), Color(0xFFB388FF), Color(0xFFD500F9), Color(0xFFFF8A80),
    Color(0xFFFFD180), Color(0xFFFFFF8D), Color(0xFFCCFF90),
    Color(0xFFA7FFEB), Color(0xFF84FFFF), Color(0xFF80D8FF),
    Color(0xFF82B1FF), Color(0xFFB9F6CA), Color(0xFFE0F2F1),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bool isValid = _controller.text.trim().isNotEmpty;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Conteúdo Scrollável
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Create category',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Input e Ícone
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final icon = await showModalBottomSheet<IconData>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const IconPickerSheet(),
                                );
                                if (icon != null) {
                                  setState(() { selectedIcon = icon; });
                                }
                              },
                              child: Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selectedColor,
                                ),
                                child: Icon(selectedIcon, color: Colors.white, size: 28),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                autofocus: true,
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                                decoration: const InputDecoration(
                                  hintText: 'Category name',
                                  hintStyle: TextStyle(color: Colors.white38),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white24),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Select a color',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // LISTA DE CORES
                      SizedBox(
                        height: 56,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (_, index) {
                            final color = colors[index];
                            final selected = color == selectedColor;
                            return GestureDetector(
                              onTap: () => setState(() => selectedColor = color),
                              child: Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: selected
                                      ? Border.all(color: Colors.white, width: 3)
                                      : null,
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemCount: colors.length,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Footer (Botões)
              Container(
                padding: EdgeInsets.only(
                  top: 0,
                  bottom: bottomPadding > 0 ? bottomPadding + 16 : 24,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(height: 1, width: double.infinity, color: Colors.white.withOpacity(0.1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1C1C1E),
                                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                              ),
                              child: const Center(child: Icon(Icons.close, color: Colors.white, size: 22)),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: isValid ? null : const Color(0xFF38383A),
                              gradient: isValid ? const LinearGradient(
                                colors: [Color(0xFF1FBF8A), Color(0xFF2DE6A4)],
                              ) : null,
                              boxShadow: isValid ? [
                                BoxShadow(
                                  color: const Color(0xFF2DE6A4).withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: -2,
                                  offset: const Offset(0, 4),
                                ),
                              ] : [],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (!isValid) return;
                                Navigator.pop(context, {
                                  'name': _controller.text.trim(),
                                  'color': selectedColor,
                                  'icon': selectedIcon,
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: isValid ? Colors.white : Colors.white.withOpacity(0.5), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add',
                                    style: TextStyle(
                                      color: isValid ? Colors.white : Colors.white.withOpacity(0.5),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
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
      ),
    );
  }
}