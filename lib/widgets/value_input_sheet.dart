import 'dart:ui';
import 'package:flutter/material.dart';

class ValueInputSheet extends StatefulWidget {
  const ValueInputSheet({super.key});

  @override
  State<ValueInputSheet> createState() => _ValueInputSheetState();
}

class _ValueInputSheetState extends State<ValueInputSheet> {
  String value = '0';

  void _addDigit(String digit) {
    setState(() {
      if (value == '0') {
        value = digit;
      } else {
        value += digit;
      }
    });
  }

  void _addDecimal() {
    if (!value.contains(',')) {
      setState(() {
        value += ',';
      });
    }
  }

  void _removeDigit() {
    setState(() {
      if (value.length <= 1) {
        value = '0';
      } else {
        value = value.substring(0, value.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Value',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const TextSpan(
                      text: ' BRL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.normal,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildKeypad(),
              const SizedBox(height: 24),
              Container(
                padding: EdgeInsets.only(
                  top: 16,
                  bottom: bottomPadding > 0 ? bottomPadding + 16 : 24,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botão X (fechar)
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1C1C1E),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 22),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),

                          // Botão Enter (Agora retorna o valor corretamente)
                          Container(
                            width: 140,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              // Neon Glow Verde Padronizado
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2DE6A4).withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: -2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFF1FBF8A),
                                  Color(0xFF2DE6A4),
                                ],
                              ),
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () {
                                // Evita retornar se for zero
                                if (value == '0') return;

                                // Retorna o valor para a página anterior (IncomePage)
                                Navigator.pop(context, value);
                              },
                              icon: const Icon(Icons.check,
                                  color: Colors.white, size: 18),
                              label: const Text(
                                'Enter',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
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

  Widget _buildKeypad() {
    final List<String> keys = [
      '7',
      '8',
      '9',
      '4',
      '5',
      '6',
      '1',
      '2',
      '3',
      ',',
      '0',
      '⌫'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: keys.map((key) {
            return SizedBox(
              width: 90,
              height: 90,
              child: _KeyButton(
                label: key,
                onTap: () {
                  if (key == '⌫') {
                    _removeDigit();
                  } else if (key == ',') {
                    _addDecimal();
                  } else {
                    _addDigit(key);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _KeyButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (label == '⌫') {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              color: Color(0xFFFF3B5C),
              size: 22,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}