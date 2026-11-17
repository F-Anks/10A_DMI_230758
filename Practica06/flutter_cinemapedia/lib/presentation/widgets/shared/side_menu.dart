import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/helpers/logo_helper.dart';
import 'package:cinemapedia/config/i18n/app_language.dart';
import 'package:cinemapedia/config/i18n/app_strings.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppStrings.of(context);
    final catalogType = ref.watch(catalogTypeProvider);
    final selectedLanguage = ref.watch(languageProvider);
    final seasonTheme = LogoHelper.getCurrentSeasonTheme();
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _DrawerHeader(
              seasonTheme: seasonTheme,
              subtitle: t.settings,
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _SectionHeader(
              title: t.content,
              subtitle: t.chooseContent,
              textStyles: textStyles,
              colors: colors,
            ),
            const SizedBox(height: 8),
            _DrawerOptionTile(
              icon: Icons.movie_outlined,
              label: t.movies,
              selected: catalogType == CatalogType.movies,
              onTap: () {
                ref.read(catalogTypeProvider.notifier).state =
                    CatalogType.movies;
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 4),
            _DrawerOptionTile(
              icon: Icons.live_tv_outlined,
              label: t.series,
              selected: catalogType == CatalogType.series,
              onTap: () {
                ref.read(catalogTypeProvider.notifier).state =
                    CatalogType.series;
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _SectionHeader(
              title: t.language,
              subtitle: t.chooseLanguage,
              textStyles: textStyles,
              colors: colors,
            ),
            const SizedBox(height: 8),
            for (final lang in AppLanguages.all) ...[
              _DrawerLanguageTile(
                language: lang,
                selected: lang.apiCode == selectedLanguage.apiCode,
                onTap: () {
                  Navigator.of(context).pop();
                  changeLanguage(ref, lang);
                },
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final SeasonTheme seasonTheme;
  final String subtitle;

  const _DrawerHeader({
    required this.seasonTheme,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            seasonTheme.glowColor.withValues(alpha: 0.18),
            colors.surfaceContainerHigh.withValues(alpha: 0.7),
          ],
        ),
        border: Border.all(
          color: seasonTheme.glowColor.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: seasonTheme.glowColor.withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CinePedia',
                  style: textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textStyles.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextTheme textStyles;
  final ColorScheme colors;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.textStyles,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textStyles.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: textStyles.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerOptionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selected: selected,
      selectedTileColor: colors.primaryContainer.withValues(alpha: 0.35),
      leading: Icon(
        icon,
        color: selected ? colors.primary : colors.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? colors.onSurface : colors.onSurfaceVariant,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: colors.primary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}

class _DrawerLanguageTile extends StatelessWidget {
  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerLanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selected: selected,
      selectedTileColor: colors.primaryContainer.withValues(alpha: 0.35),
      leading: Container(
        width: 36,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          language.country,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: selected ? colors.onPrimary : colors.onSurfaceVariant,
          ),
        ),
      ),
      title: Text(
        language.nativeName,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? colors.onSurface : colors.onSurfaceVariant,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: colors.primary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
