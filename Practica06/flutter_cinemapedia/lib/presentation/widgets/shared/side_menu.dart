import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/helpers/logo_helper.dart';
import 'package:cinemapedia/config/i18n/app_language.dart';
import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppStrings.of(context);
    final catalogType = ref.watch(catalogTypeProvider);
    final selectedLanguage = ref.watch(languageProvider);
    final appTheme = ref.watch(themeNotifierProvider);
    final seasonTheme = LogoHelper.getCurrentSeasonTheme();
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          children: [
            _CenteredBrandHeader(
              seasonTheme: seasonTheme,
              subtitle: t.settings,
              activeSummary:
                  '${catalogType == CatalogType.series ? t.series : t.movies} · ${selectedLanguage.country}',
            ),
            const SizedBox(height: 14),

            // 1. Sección de Contenido (2 tarjetas en fila)
            _SectionCard(
              icon: Icons.video_library_outlined,
              title: t.content,
              subtitle: t.chooseContent,
              colors: colors,
              textStyles: textStyles,
              child: Row(
                children: [
                  Expanded(
                    child: _CatalogCardButton(
                      icon: Icons.movie_creation_outlined,
                      label: t.movies,
                      selected: catalogType == CatalogType.movies,
                      onTap: () {
                        ref.read(searchQueryProvider.notifier).state = '';
                        ref.read(catalogTypeProvider.notifier).state =
                            CatalogType.movies;
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CatalogCardButton(
                      icon: Icons.tv_rounded,
                      label: t.series,
                      selected: catalogType == CatalogType.series,
                      onTap: () {
                        ref.read(searchQueryProvider.notifier).state = '';
                        ref.read(catalogTypeProvider.notifier).state =
                            CatalogType.series;
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. Sección de Tema de la interfaz (Oscuro/Claro + Temas por fecha)
            _SectionCard(
              icon: Icons.palette_outlined,
              title: t.themeSection,
              colors: colors,
              textStyles: textStyles,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _ModeToggleButton(
                          icon: Icons.dark_mode_outlined,
                          label: t.darkMode,
                          selected: appTheme.isDarkmode,
                          onTap: () => ref
                              .read(themeNotifierProvider.notifier)
                              .setDarkMode(true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ModeToggleButton(
                          icon: Icons.light_mode_outlined,
                          label: t.lightMode,
                          selected: !appTheme.isDarkmode,
                          onTap: () => ref
                              .read(themeNotifierProvider.notifier)
                              .setDarkMode(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: seasonThemeColors.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 38,
                    ),
                    itemBuilder: (context, index) {
                      final color = seasonThemeColors[index];
                      final name = index < t.seasonThemeNames.length
                          ? t.seasonThemeNames[index]
                          : 'Tema ${index + 1}';
                      final isSelected = appTheme.selectedColor == index;

                      return _SeasonColorChip(
                        color: color,
                        label: name,
                        selected: isSelected,
                        onTap: () => ref
                            .read(themeNotifierProvider.notifier)
                            .selectColorIndex(index),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. Sección de Idioma (Cuadrícula compacta en 2 columnas)
            _SectionCard(
              icon: Icons.translate_rounded,
              title: t.language,
              subtitle: t.chooseLanguage,
              colors: colors,
              textStyles: textStyles,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: AppLanguages.all.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 44,
                ),
                itemBuilder: (context, index) {
                  final lang = AppLanguages.all[index];
                  final selected = lang.apiCode == selectedLanguage.apiCode;

                  return _LanguageGridItem(
                    language: lang,
                    selected: selected,
                    onTap: () {
                      Navigator.of(context).pop();
                      changeLanguage(ref, lang);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredBrandHeader extends StatelessWidget {
  final SeasonTheme seasonTheme;
  final String subtitle;
  final String activeSummary;

  const _CenteredBrandHeader({
    required this.seasonTheme,
    required this.subtitle,
    required this.activeSummary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Transform.scale(
                scale: seasonTheme.cropScale,
                child: Image.asset(
                  seasonTheme.logoPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'CinePedia',
            style: textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$subtitle · $activeSummary',
            style: textStyles.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final ColorScheme colors;
  final TextTheme textStyles;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.colors,
    required this.textStyles,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: textStyles.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: textStyles.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 11.5,
              ),
            ),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _CatalogCardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CatalogCardButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.15)
              : colors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? colors.primary : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? colors.primary : colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeToggleButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.16)
              : colors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? colors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? colors.primary : colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonColorChip extends StatelessWidget {
  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SeasonColorChip({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.16)
              : colors.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.3,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageGridItem extends StatelessWidget {
  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageGridItem({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.15)
              : colors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? colors.primary : Colors.transparent,
            width: 1.3,
          ),
        ),
        child: Row(
          children: [
            Text(
              language.country,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                language.nativeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
