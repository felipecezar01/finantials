import 'dart:ui';
import 'package:flutter/material.dart';

class IconPickerSheet extends StatefulWidget {
  const IconPickerSheet({super.key});

  @override
  State<IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<IconPickerSheet> {
  IconData? selectedIcon;

  // Mapa de categorias expandido com novos ícones
  final Map<String, List<IconData>> iconCategories = {
    'Income & People': [
      Icons.family_restroom, // Família / Mesada
      Icons.child_care, // Filhos / Mesada
      Icons.volunteer_activism, // Gorjeta / Doação
      Icons.badge, // Trabalho / Crachá
      Icons.supervised_user_circle, // Chefe / Gerente
      Icons.face, // Pessoal
      Icons.groups, // Equipe
      Icons.handshake, // Negócios / Acordos
      Icons.card_giftcard, // Presente / Bônus
      Icons.diamond, // Extras / Luxo
    ],
    'Finance': [
      Icons.attach_money,
      Icons.savings, // Cofrinho
      Icons.account_balance, // Banco
      Icons.credit_card,
      Icons.wallet, // Carteira (Novo)
      Icons.trending_up, // Investimentos
      Icons.currency_exchange, // Câmbio (Novo)
      Icons.pie_chart, // Dividendos (Novo)
      Icons.receipt_long, // Notas Fiscais (Novo)
    ],
    'Bills & Utilities': [
      Icons.home, // Casa
      Icons.wifi,
      Icons.electrical_services,
      Icons.water_drop,
      Icons.phone_android,
      Icons.live_tv,
      Icons.cleaning_services, // Limpeza (Novo)
      Icons.build, // Reparos/Manutenção (Novo)
      Icons.security, // Seguro/Segurança (Novo)
    ],
    'Transport': [
      Icons.directions_car,
      Icons.two_wheeler, // Moto (Novo)
      Icons.pedal_bike, // Bicicleta (Novo)
      Icons.local_gas_station,
      Icons.local_parking,
      Icons.directions_bus,
      Icons.directions_subway,
      Icons.local_taxi,
      Icons.flight,
      Icons.car_repair,
    ],
    'Shopping & Food': [
      Icons.shopping_cart,
      Icons.shopping_bag, // Sacola (Novo)
      Icons.restaurant,
      Icons.fastfood,
      Icons.local_pizza, // Pizza (Novo)
      Icons.local_cafe, // Café (Novo)
      Icons.local_bar, // Bebidas (Novo)
      Icons.local_grocery_store,
      Icons.local_mall,
      Icons.local_pharmacy,
      Icons.checkroom,
    ],
    'Education & Work': [
      Icons.work,
      Icons.engineering, // Trabalho técnico (Novo)
      Icons.school,
      Icons.menu_book,
      Icons.computer,
      Icons.attach_file,
      Icons.assignment, // Tarefas (Novo)
      Icons.architecture, // Projetos (Novo)
    ],
    'Leisure & Health': [
      Icons.movie,
      Icons.music_note,
      Icons.sports_esports,
      Icons.fitness_center,
      Icons.pool, // Natação/Piscina (Novo)
      Icons.spa, // Relaxamento (Novo)
      Icons.sports_soccer,
      Icons.favorite,
      Icons.medication, // Remédios (Novo)
      Icons.beach_access,
      Icons.pets,
    ],
  };

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Drag indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select an icon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Lista Rolável de Categorias
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: iconCategories.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Cabeçalho da Seção
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Grid de ícones
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment.start,
                          children: entry.value.map((icon) {
                            final isSelected = icon == selectedIcon;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIcon = icon;
                                });
                              },
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.15)
                                      : Colors.white.withOpacity(0.06),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.6)
                                        : Colors.transparent,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            // Rodapé
            Container(
              padding: EdgeInsets.only(
                top: 16,
                bottom: bottomPadding > 0 ? bottomPadding + 16 : 32,
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1C1C1E),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
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
                            onPressed: () {
                              if (selectedIcon != null) {
                                Navigator.pop(context, selectedIcon);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                            ),
                            icon: const Icon(Icons.save,
                                color: Colors.white, size: 20),
                            label: const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
    );
  }
}