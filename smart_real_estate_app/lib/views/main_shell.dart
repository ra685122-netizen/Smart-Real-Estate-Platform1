import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import 'home_view.dart';
import 'search/search_view.dart';
import 'favorites/favorites_view.dart';
import 'chat/conversations_view.dart';
import 'profile/profile_view.dart';
import 'property/my_properties_view.dart';
import 'admin/admin_dashboard_view.dart';

const double _kSidebarWidth = 260.0;
const double _kSidebarMiniWidth = 72.0;
const double _kHeaderHeight = 64.0;
const double _kBreakpoint = 800.0;

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _sidebarCollapsed = false;
  late AnimationController _badgeCtrl;

  @override
  void initState() {
    super.initState();
    _badgeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _badgeCtrl.forward();
  }

  @override
  void dispose() {
    _badgeCtrl.dispose();
    super.dispose();
  }

  List<_NavItem> _navItems(BuildContext context, String? role, bool isLoggedIn, AppLocalizations loc) {
    if (!isLoggedIn) {
      return [
        _NavItem(Icons.home_rounded, Icons.home_outlined, loc.home, false),
        _NavItem(Icons.search_rounded, Icons.search_outlined, loc.search, false),
        _NavItem(Icons.explore_rounded, Icons.explore_outlined, loc.explore, false),
        _NavItem(Icons.person_rounded, Icons.person_outline, loc.profile, false),
      ];
    }

    switch (role) {
      case 'admin':
        return [
          _NavItem(Icons.home_rounded, Icons.home_outlined, loc.home, false),
          _NavItem(Icons.dashboard_rounded, Icons.dashboard_outlined, loc.dashboard, false),
          _NavItem(Icons.manage_search_rounded, Icons.search_outlined, loc.search, false),
          _NavItem(Icons.chat_bubble_rounded, Icons.chat_bubble_outline, loc.chat, false),
          _NavItem(Icons.person_rounded, Icons.person_outline, loc.profile, false),
        ];
      case 'seller':
      case 'owner':
      case 'agency':
        return [
          _NavItem(Icons.home_rounded, Icons.home_outlined, loc.home, false),
          _NavItem(Icons.search_rounded, Icons.search_outlined, loc.search, false),
          _NavItem(Icons.home_work_rounded, Icons.home_work_outlined, loc.myListings, false),
          _NavItem(Icons.chat_bubble_rounded, Icons.chat_bubble_outline, loc.chat, false),
          _NavItem(Icons.person_rounded, Icons.person_outline, loc.profile, false),
        ];
      default:
        return [
          _NavItem(Icons.home_rounded, Icons.home_outlined, loc.home, false),
          _NavItem(Icons.search_rounded, Icons.search_outlined, loc.search, false),
          _NavItem(Icons.favorite_rounded, Icons.favorite_outline, loc.favorites, false),
          _NavItem(Icons.chat_bubble_rounded, Icons.chat_bubble_outline, loc.chat, false),
          _NavItem(Icons.person_rounded, Icons.person_outline, loc.profile, false),
        ];
    }
  }

  List<Widget> _pages(String? role, bool isLoggedIn) {
    if (!isLoggedIn) {
      return [
        const HomeView(),
        const SearchView(),
        const _ExploreGuestView(),
        const _GuestProfileView(),
      ];
    }

    switch (role) {
      case 'admin':
        return [
          const HomeView(),
          const AdminDashboardView(),
          const SearchView(),
          const ConversationsView(),
          const ProfileView(),
        ];
      case 'seller':
      case 'owner':
      case 'agency':
        return [
          const HomeView(),
          const SearchView(),
          const MyPropertiesView(),
          const ConversationsView(),
          const ProfileView(),
        ];
      default:
        return [
          const HomeView(),
          const SearchView(),
          const FavoritesView(),
          const ConversationsView(),
          const ProfileView(),
        ];
    }
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final isLoggedIn = auth.isLoggedIn;
    final role = auth.currentUser?.role;
    final items = _navItems(context, role, isLoggedIn, loc);
    final pages = _pages(role, isLoggedIn);
    final safeIndex = _currentIndex < pages.length ? _currentIndex : 0;

    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= _kBreakpoint;

    if (isWideScreen) {
      return _WebLayout(
        currentIndex: safeIndex,
        items: items,
        pages: pages,
        sidebarCollapsed: _sidebarCollapsed,
        onTabTapped: _onTabTapped,
        onToggleSidebar: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
        auth: auth,
        loc: loc,
      );
    }

    return _MobileLayout(
      currentIndex: safeIndex,
      items: items,
      pages: pages,
      onTabTapped: _onTabTapped,
      loc: loc,
    );
  }
}

class _WebLayout extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final List<Widget> pages;
  final bool sidebarCollapsed;
  final ValueChanged<int> onTabTapped;
  final VoidCallback onToggleSidebar;
  final AuthProvider auth;
  final AppLocalizations loc;

  const _WebLayout({
    required this.currentIndex,
    required this.items,
    required this.pages,
    required this.sidebarCollapsed,
    required this.onTabTapped,
    required this.onToggleSidebar,
    required this.auth,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final gradient = themeProvider.currentScheme.gradient;
    final isDark = theme.brightness == Brightness.dark;

    final sidebarW = sidebarCollapsed ? _kSidebarMiniWidth : _kSidebarWidth;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          if (!ApiService.isConnected)
            _OfflineBanner(loc: loc),
          Expanded(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  width: sidebarW,
                  child: _Sidebar(
                    currentIndex: currentIndex,
                    items: items,
                    collapsed: sidebarCollapsed,
                    gradient: gradient,
                    auth: auth,
                    loc: loc,
                    onTabTapped: onTabTapped,
                    onToggle: onToggleSidebar,
                    isDark: isDark,
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _WebHeader(
                        auth: auth,
                        loc: loc,
                        gradient: gradient,
                        isDark: isDark,
                        theme: theme,
                        themeProvider: themeProvider,
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: currentIndex,
                          children: pages,
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
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final bool collapsed;
  final List<Color> gradient;
  final AuthProvider auth;
  final AppLocalizations loc;
  final ValueChanged<int> onTabTapped;
  final VoidCallback onToggle;
  final bool isDark;
  final ThemeData theme;

  const _Sidebar({
    required this.currentIndex,
    required this.items,
    required this.collapsed,
    required this.gradient,
    required this.auth,
    required this.loc,
    required this.onTabTapped,
    required this.onToggle,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final bgStart = isDark
        ? const Color(0xFF0F1923)
        : gradient.first.withValues(alpha: 0.92);
    final bgEnd = isDark
        ? const Color(0xFF1A2A3A)
        : gradient.last.withValues(alpha: 0.85);
    final borderColor = isDark
        ? const Color(0xFF2C2C3E)
        : gradient.first.withValues(alpha: 0.3);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgStart, bgEnd],
        ),
        border: Border(
          left: BorderSide(color: borderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.2),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _SidebarHeader(
            collapsed: collapsed,
            gradient: gradient,
            onToggle: onToggle,
            isDark: isDark,
          ),
          Divider(height: 1, thickness: 1, color: Colors.white.withValues(alpha: 0.15)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              children: [
                ...List.generate(items.length, (i) {
                  final item = items[i];
                  final isActive = currentIndex == i;
                  return _SidebarNavItem(
                    icon: isActive ? item.activeIcon : item.inactiveIcon,
                    label: item.label,
                    isActive: isActive,
                    collapsed: collapsed,
                    gradient: gradient,
                    theme: theme,
                    isDark: isDark,
                    onTap: () => onTabTapped(i),
                  );
                }),
                const SizedBox(height: 8),
                Divider(
                  color: Colors.white.withValues(alpha: 0.15),
                  thickness: 1,
                ),
                const SizedBox(height: 8),
                _SidebarNavItem(
                  icon: Icons.settings_rounded,
                  label: loc.settings,
                  isActive: false,
                  collapsed: collapsed,
                  gradient: gradient,
                  theme: theme,
                  isDark: isDark,
                  onTap: () => context.push('/settings'),
                ),
                _SidebarNavItem(
                  icon: Icons.map_rounded,
                  label: loc.isArabic ? 'الخريطة' : 'Map',
                  isActive: false,
                  collapsed: collapsed,
                  gradient: gradient,
                  theme: theme,
                  isDark: isDark,
                  onTap: () => context.push('/map'),
                ),
                _SidebarNavItem(
                  icon: Icons.description_rounded,
                  label: loc.contracts,
                  isActive: false,
                  collapsed: collapsed,
                  gradient: gradient,
                  theme: theme,
                  isDark: isDark,
                  onTap: () => context.push('/contracts'),
                ),
                _SidebarNavItem(
                  icon: Icons.smart_toy_rounded,
                  label: loc.aiAssistant,
                  isActive: false,
                  collapsed: collapsed,
                  gradient: gradient,
                  theme: theme,
                  isDark: isDark,
                  onTap: () => context.push('/ai-assistant'),
                ),
              ],
            ),
          ),
          _SidebarFooter(
            auth: auth,
            collapsed: collapsed,
            gradient: gradient,
            loc: loc,
            isDark: isDark,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final bool collapsed;
  final List<Color> gradient;
  final VoidCallback onToggle;
  final bool isDark;

  const _SidebarHeader({
    required this.collapsed,
    required this.gradient,
    required this.onToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
            ),
            child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 22),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'عقاري',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            onPressed: onToggle,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                collapsed ? Icons.menu_open_rounded : Icons.menu_rounded,
                key: ValueKey(collapsed),
                color: Colors.white.withValues(alpha: 0.8),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool collapsed;
  final List<Color> gradient;
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.collapsed,
    required this.gradient,
    required this.theme,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: collapsed ? label : '',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 14 : 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: isActive
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                  size: 22,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  final AuthProvider auth;
  final bool collapsed;
  final List<Color> gradient;
  final AppLocalizations loc;
  final bool isDark;
  final ThemeData theme;

  const _SidebarFooter({
    required this.auth,
    required this.collapsed,
    required this.gradient,
    required this.loc,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final borderColor = Colors.white.withValues(alpha: 0.15);

    if (!auth.isLoggedIn) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: collapsed
            ? IconButton(
                icon: const Icon(Icons.login_rounded, color: Colors.white),
                onPressed: () => context.push('/login'),
                tooltip: loc.login,
              )
            : ElevatedButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login_rounded, size: 18),
                label: Text(loc.login, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: gradient.first,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
      );
    }

    final user = auth.currentUser;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: collapsed
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    user?.name.isNotEmpty == true ? user!.name[0] : '?',
                    style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.nightlight_round, color: Colors.white70, size: 20),
                  onPressed: () => themeProvider.toggleTheme(),
                  tooltip: loc.darkMode,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            )
          : Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  child: Text(
                    user?.name.isNotEmpty == true ? user!.name[0] : '?',
                    style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user?.name ?? '',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        loc.getRoleName(user?.role ?? ''),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    themeProvider.themeMode == ThemeMode.dark
                        ? Icons.wb_sunny_rounded
                        : Icons.nightlight_round,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => themeProvider.toggleTheme(),
                  tooltip: loc.darkMode,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
    );
  }
}

class _WebHeader extends StatelessWidget {
  final AuthProvider auth;
  final AppLocalizations loc;
  final List<Color> gradient;
  final bool isDark;
  final ThemeData theme;
  final ThemeProvider themeProvider;

  const _WebHeader({
    required this.auth,
    required this.loc,
    required this.gradient,
    required this.isDark,
    required this.theme,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE8EAF6),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (auth.isLoggedIn) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                loc.getRoleName(auth.currentUser?.role ?? ''),
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (!ApiService.isConnected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off, color: Colors.orange, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    loc.isArabic ? 'وضع بدون إنترنت' : 'Offline Mode',
                    style: GoogleFonts.cairo(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => themeProvider.toggleTheme(),
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.wb_sunny_rounded
                  : Icons.nightlight_round,
              color: isDark ? Colors.amber : gradient.first,
            ),
            tooltip: loc.darkMode,
          ),
          const SizedBox(width: 8),
          if (auth.isLoggedIn)
            IconButton(
              onPressed: () => context.push('/notifications'),
              icon: Icon(Icons.notifications_outlined,
                  color: isDark ? Colors.white70 : gradient.first),
              tooltip: loc.notifications,
            ),
          const SizedBox(width: 4),
          if (auth.isLoggedIn)
            GestureDetector(
              onTap: () => context.push('/edit-profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: gradient.first.withValues(alpha: 0.2),
                child: Text(
                  auth.currentUser?.name.isNotEmpty == true
                      ? auth.currentUser!.name[0]
                      : '?',
                  style: GoogleFonts.cairo(
                    color: gradient.first,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: () => context.push('/login'),
              icon: Icon(Icons.login_rounded, color: gradient.first, size: 18),
              label: Text(loc.login,
                  style: GoogleFonts.cairo(color: gradient.first, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final List<Widget> pages;
  final ValueChanged<int> onTabTapped;
  final AppLocalizations loc;

  const _MobileLayout({
    required this.currentIndex,
    required this.items,
    required this.pages,
    required this.onTabTapped,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final gradient = themeProvider.currentScheme.gradient;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          if (!ApiService.isConnected) _OfflineBanner(loc: loc),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEEEE),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final item = items[i];
                final isActive = currentIndex == i;
                return Expanded(
                  child: InkWell(
                    onTap: () => onTabTapped(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: isActive
                                ? LinearGradient(colors: [
                                    gradient.first.withValues(alpha: 0.15),
                                    gradient.last.withValues(alpha: 0.08),
                                  ])
                                : null,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isActive ? item.activeIcon : item.inactiveIcon,
                            color: isActive
                                ? gradient.first
                                : (isDark ? Colors.white38 : Colors.black38),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                            color: isActive
                                ? gradient.first
                                : (isDark ? Colors.white38 : Colors.black38),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  final AppLocalizations loc;
  const _OfflineBanner({required this.loc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.orange.shade700,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            loc.isArabic ? 'وضع بدون إنترنت - عرض البيانات المحلية' : 'Offline Mode - Showing local data',
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final bool hasBadge;

  const _NavItem(this.activeIcon, this.inactiveIcon, this.label, this.hasBadge);
}

class _ExploreGuestView extends StatelessWidget {
  const _ExploreGuestView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final gradient = themeProvider.currentScheme.gradient;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.explore_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                loc.isArabic ? 'اكتشف العقارات' : 'Explore Properties',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.isArabic
                    ? 'سجّل دخول للوصول إلى ميزات الاستكشاف المتقدمة'
                    : 'Sign in to access advanced explore features',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login_rounded),
                label: Text(loc.login, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuestProfileView extends StatelessWidget {
  const _GuestProfileView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final gradient = themeProvider.currentScheme.gradient;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                loc.isArabic ? 'الملف الشخصي' : 'Profile',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.isArabic
                    ? 'سجّل دخول لإدارة ملفك الشخصي'
                    : 'Sign in to manage your profile',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login_rounded),
                label: Text(loc.login, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push('/register'),
                child: Text(
                  loc.isArabic ? 'إنشاء حساب جديد' : 'Create new account',
                  style: GoogleFonts.cairo(
                    color: gradient.first,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
