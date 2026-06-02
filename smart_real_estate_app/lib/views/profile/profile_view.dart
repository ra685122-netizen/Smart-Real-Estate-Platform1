import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final primary = themeProvider.currentScheme.primary;
    final secondary = themeProvider.currentScheme.secondary;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [primary, secondary]),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user?.name[0] ?? '?',
                        style: GoogleFonts.cairo(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? (l.isArabic ? 'زائر' : 'Guest'),
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (user != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary.withValues(alpha: 0.15), secondary.withValues(alpha: 0.15)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l.getRoleName(user.role),
                        style: GoogleFonts.cairo(
                          color: primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.push('/edit-profile'),
                      child: Text(l.editProfile),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (user?.role == 'owner' ||
                user?.role == 'seller' ||
                user?.role == 'agency') ...[
              _buildSection(context, l.isArabic ? 'إدارة العقارات' : 'Property Management', [
                _MenuItem(Icons.home_work_outlined, l.myProperties,
                    () => context.push('/my-properties')),
                _MenuItem(Icons.add_home_outlined, l.addProperty,
                    () => context.push('/add-property')),
              ], primary, cardBg, theme),
              const SizedBox(height: 16),
            ],
            if (user?.role == 'admin') ...[
              _buildSection(context, l.adminDashboard, [
                _MenuItem(Icons.dashboard_outlined, l.adminDashboard,
                    () => context.push('/admin')),
                _MenuItem(Icons.people_outlined, l.manageUsers,
                    () => context.push('/admin/users')),
                _MenuItem(Icons.home_work_outlined, l.manageProperties,
                    () => context.push('/admin/properties')),
              ], primary, cardBg, theme),
              const SizedBox(height: 16),
            ],
            _buildSection(context, l.isArabic ? 'العقود والمدفوعات' : 'Contracts & Payments', [
              _MenuItem(Icons.description_outlined, l.isArabic ? 'عقودي' : 'My Contracts',
                  () => context.push('/contracts')),
              _MenuItem(Icons.payment_outlined, l.isArabic ? 'سجل المدفوعات' : 'Payment History',
                  () => context.push('/payment', extra: {'amount': 0.0, 'title': ''})),
              _MenuItem(Icons.smart_toy_outlined, l.isArabic ? 'المساعد الذكي' : 'AI Assistant',
                  () => context.push('/ai-assistant')),
              _MenuItem(Icons.map_outlined, l.isArabic ? 'خريطة العقارات' : 'Property Map',
                  () => context.push('/map')),
            ], primary, cardBg, theme),
            const SizedBox(height: 16),
            _buildSection(context, l.general, [
              _MenuItem(Icons.notifications_outlined, l.notifications,
                  () => context.push('/notifications')),
              _MenuItem(Icons.palette_outlined, l.themeSettings,
                  () => context.push('/theme-settings')),
              _MenuItem(Icons.settings_outlined, l.settings,
                  () => context.push('/settings')),
            ], primary, cardBg, theme),
            const SizedBox(height: 16),
            if (user != null)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout, color: Color(0xFFE74C3C)),
                  label: Text(
                    l.logout,
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFE74C3C),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<_MenuItem> items,
      Color primary, Color cardBg, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          ...items.map((item) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: primary, size: 22),
                ),
                title: Text(item.title, style: const TextStyle(fontSize: 15)),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                onTap: item.onTap,
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem(this.icon, this.title, this.onTap);
}
