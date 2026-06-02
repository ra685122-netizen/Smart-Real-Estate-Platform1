import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;
  bool _biometric = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [primary, secondary],
          ).createShader(bounds),
          child: Text(
            loc.settings,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(loc.preferences, Icons.tune_rounded, theme, primary),
          const SizedBox(height: 8),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: loc.notifications,
            subtitle: loc.notificationsDesc,
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
            theme: theme,
            isDark: isDark,
            primary: primary,
            secondary: secondary,
          ),
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: loc.darkMode,
            subtitle: loc.darkModeDesc,
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggleTheme(),
            theme: theme,
            isDark: isDark,
            primary: primary,
            secondary: secondary,
          ),
          _buildSwitchTile(
            icon: Icons.fingerprint,
            title: loc.biometric,
            subtitle: loc.biometricDesc,
            value: _biometric,
            onChanged: (v) => setState(() => _biometric = v),
            theme: theme,
            isDark: isDark,
            primary: primary,
            secondary: secondary,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(loc.general, Icons.settings_outlined, theme, primary),
          const SizedBox(height: 8),
          _buildTile(
            icon: Icons.palette_outlined,
            title: loc.themeSettings,
            trailing: loc.themeSettingsDesc,
            onTap: () => context.push('/theme-settings'),
            theme: theme,
            isDark: isDark,
            primary: primary,
            secondary: secondary,
          ),
          _buildTile(
            icon: Icons.language,
            title: loc.language,
            trailing: localeProvider.isArabic ? loc.arabic : loc.english,
            onTap: () => _showLanguageDialog(loc, localeProvider, theme, primary, secondary),
            theme: theme,
            isDark: isDark,
            primary: primary,
            secondary: secondary,
          ),
          _buildTile(
            icon: Icons.currency_exchange,
            title: loc.currency,
            trailing: loc.sarCurrency,
            onTap: () {},
            theme: theme,
            isDark: isDark,
            primary: primary,
            secondary: secondary,
          ),
          _buildTile(
            icon: Icons.storage_outlined,
            title: loc.clearCache,
            trailing: '',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.cacheCleared, style: GoogleFonts.cairo()),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            theme: theme,
            isDark: isDark,
            primary: primary,
            secondary: secondary,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(loc.about, Icons.info_outline, theme, primary),
          const SizedBox(height: 8),
          _buildTile(
            icon: Icons.info_outline,
            title: loc.aboutApp,
            trailing: loc.version,
            onTap: () {},
            theme: theme,
            isDark: isDark,
            primary: primary,
            secondary: secondary,
          ),
          _buildTile(
            icon: Icons.privacy_tip_outlined,
            title: loc.privacy,
            trailing: '',
            onTap: () {},
            theme: theme,
            isDark: isDark,
            primary: primary,
            secondary: secondary,
          ),
          _buildTile(
            icon: Icons.description_outlined,
            title: loc.terms,
            trailing: '',
            onTap: () {},
            theme: theme,
            isDark: isDark,
            primary: primary,
            secondary: secondary,
          ),
          _buildTile(
            icon: Icons.support_outlined,
            title: loc.contactUs,
            trailing: '',
            onTap: () {},
            theme: theme,
            isDark: isDark,
            primary: primary,
            secondary: secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ThemeData theme, Color primary) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary.withValues(alpha: 0.15), primary.withValues(alpha: 0.05)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeData theme,
    required bool isDark,
    required Color primary,
    required Color secondary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary.withValues(alpha: 0.12), secondary.withValues(alpha: 0.08)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primary, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: primary,
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String trailing,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
    required Color primary,
    required Color secondary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary.withValues(alpha: 0.12), secondary.withValues(alpha: 0.08)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primary, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 15,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing.isNotEmpty)
              Text(
                trailing,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog(
    AppLocalizations loc,
    LocaleProvider localeProvider,
    ThemeData theme,
    Color primary,
    Color secondary,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          loc.chooseLanguage,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              loc.arabic,
              'العربية',
              localeProvider.isArabic,
              () {
                localeProvider.setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
              theme,
              primary,
            ),
            const SizedBox(height: 8),
            _buildLanguageOption(
              loc.english,
              'English',
              !localeProvider.isArabic,
              () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
              theme,
              primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    String title,
    String subtitle,
    bool isSelected,
    VoidCallback onTap,
    ThemeData theme,
    Color primary,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? primary : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: primary, size: 24),
          ],
        ),
      ),
    );
  }
}
