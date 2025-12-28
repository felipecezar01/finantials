import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelectorSheet extends StatelessWidget {
  const MonthSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // --- CONFIGURAÇÃO DAS DATAS ---

    // 1. Data de Início Fixa (O "Passado que fica")
    // Coloquei Dezembro 2025 como pediu, mas você pode mudar para antes se quiser.
    final DateTime startDate = DateTime(2025, 12);

    // 2. Data de Fim (Hoje + 24 Meses)
    final DateTime now = DateTime.now();
    final DateTime endDate = DateTime(now.year, now.month + 24);

    // 3. Gerar a lista de meses entre Start e End
    List<DateTime> months = [];
    DateTime currentIterator = startDate;

    // Loop simples para preencher a lista mês a mês
    while (currentIterator.isBefore(endDate) || currentIterator.isAtSameMomentAs(endDate)) {
      months.add(currentIterator);
      // Avança para o próximo mês
      currentIterator = DateTime(currentIterator.year, currentIterator.month + 1);
    }

    // Opcional: Inverter para o mais futuro aparecer no topo?
    // Ou manter cronológico? Vou deixar cronológico (Antigo -> Novo) pois é uma lista longa.
    // Se quiser o mais recente no topo, descomente a linha abaixo:
    // months = months.reversed.toList();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Choose month',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: months.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final date = months[index];
                  // Verifica se é o mês atual (Real Life) para destacar
                  final isCurrentRealMonth = date.year == now.year && date.month == now.month;

                  final monthName = DateFormat('MMMM, yyyy').format(date);

                  return GestureDetector(
                    onTap: () {
                      // Retorna a String formatada para a HomePage converter
                      Navigator.pop(context, monthName);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isCurrentRealMonth ? const Color(0xFF2C2C2E) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: isCurrentRealMonth
                            ? Border.all(color: const Color(0xFF2DE6A4), width: 1)
                            : Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            monthName,
                            style: TextStyle(
                              color: isCurrentRealMonth ? const Color(0xFF2DE6A4) : Colors.white,
                              fontSize: 18,
                              fontWeight: isCurrentRealMonth ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (isCurrentRealMonth)
                            const Icon(Icons.circle, color: Color(0xFF2DE6A4), size: 10),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}