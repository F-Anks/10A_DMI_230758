import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widgets_app/config/theme/app_theme.dart';
import 'package:flutter_widgets_app/presentation/providers/theme_provider.dart';

class ThemeChangerScreen extends ConsumerWidget {
  static const name = 'theme_changer_screen';

  const ThemeChangerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkmode = ref.watch(themeNotifierProvider).isDarkmode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Changer'),
        actions: [
          IconButton(
            icon: Icon(isDarkmode
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined),
            onPressed: () {
              ref.read(themeNotifierProvider.notifier).toggleDarkmode();
            },
          ),
        ],
      ),
      body: const _ThemeChangerView(),
    );
  }
}

class _ThemeChangerView extends ConsumerWidget {
  const _ThemeChangerView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Color> colors = ref.watch(colorListProvider);
    final int selectedColor = ref.watch(themeNotifierProvider).selectedColor;

    return ListView.builder(
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final Color color = colors[index];
        final String name = (index < themeNames.length) ? themeNames[index] : 'Color $index';
        final String logo = getLogoPath(index);
        final bool isSelected = selectedColor == index;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          elevation: isSelected ? 3 : 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: RadioListTile<int>(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            secondary: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.grey.withAlpha(70),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withAlpha(90),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  logo,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              name,
              style: TextStyle(
                color: isSelected ? color : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Hex: #${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color.withAlpha(180) : null,
              ),
            ),
            activeColor: color,
            value: index,
            groupValue: selectedColor,
            onChanged: (value) {
              if (value == null) return;
              ref.read(themeNotifierProvider.notifier).changeColorIndex(value);

              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tema e ícono cambiados a: $name'),
                  backgroundColor: color,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
