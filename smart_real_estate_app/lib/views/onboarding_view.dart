import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final primary = themeProvider.currentScheme.primary;
    final secondary = themeProvider.currentScheme.secondary;

    final List<_OnboardingData> pages = [
      _OnboardingData(
        title: l.appName,
        description: l.appTagline,
        icon: Icons.search_rounded,
        colors: [primary, primary.withOpacity(0.7)],
      ),
      _OnboardingData(
        title: l.featuredProperties,
        description: l.findDreamHome,
        icon: Icons.home_work_rounded,
        colors: [secondary, secondary.withOpacity(0.7)],
      ),
      _OnboardingData(
        title: l.aiAssistant,
        description: l.aiAssistantDesc,
        icon: Icons.psychology_rounded,
        colors: [primary, secondary],
      ),
      _OnboardingData(
        title: l.securePayments,
        description: l.payNow,
        icon: Icons.verified_user_rounded,
        colors: [const Color(0xFF2ECC71), const Color(0xFF27AE60)],
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return _OnboardingPage(data: pages[index]);
            },
          ),
          Positioned(
            top: 50,
            right: l.isArabic ? null : 20,
            left: l.isArabic ? 20 : null,
            child: TextButton(
              onPressed: _finishOnboarding,
              child: Text(
                l.skip,
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 10,
                      width: _currentPage == index ? 30 : 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == pages.length - 1) {
                          _finishOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: pages[_currentPage].colors.first,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        _currentPage == pages.length - 1 ? l.startNow : l.next,
                        style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) context.go('/login');
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> colors;

  _OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.colors,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
              Icon(data.icon, size: 80, color: Colors.white),
            ],
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
