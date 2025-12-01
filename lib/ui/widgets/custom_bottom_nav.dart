import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';

const Color kPrimaryColor = Color(0xFF3bb54a);

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final kFont = GoogleFonts.cairo();
    final strings = AppLocalizations.of(context)!;

    final items = [
      {'icon': Symbols.home, 'label': strings.bottomNavHome},
      {'icon': Symbols.shopping_cart, 'label': strings.bottomNavCart},
      {'icon': Symbols.receipt_long, 'label': strings.bottomNavOrders},
      {'icon': Symbols.person, 'label': strings.bottomNavProfile},
    ];

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final bool isSelected = currentIndex == index;
          final color = isSelected ? kPrimaryColor : Colors.grey.shade600;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'] as IconData, color: color),
                const SizedBox(height: 4),
                Text(
                  item['label'] as String,
                  style: kFont.copyWith(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: color,
                  ),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    height: 2,
                    width: 30,
                    color: color,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
