import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeColorScheme {
  final String name;
  final String nameAr;
  final Color primary;
  final Color secondary;
  final List<Color> gradient;

  const ThemeColorScheme({
    required this.name,
    required this.nameAr,
    required this.primary,
    required this.secondary,
    required this.gradient,
  });
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  int _selectedSchemeIndex = 0;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  int get selectedSchemeIndex => _selectedSchemeIndex;
  ThemeColorScheme get currentScheme => colorSchemes[_selectedSchemeIndex];

  static const List<ThemeColorScheme> colorSchemes = [
    ThemeColorScheme(
      name: 'Ocean Blue',
      nameAr: 'أزرق محيطي',
      primary: Color(0xFF1A3A5C),
      secondary: Color(0xFF2E86AB),
      gradient: [Color(0xFF1A3A5C), Color(0xFF2E86AB)],
    ),
    ThemeColorScheme(
      name: 'Royal Purple',
      nameAr: 'بنفسجي ملكي',
      primary: Color(0xFF5B2C8D),
      secondary: Color(0xFF9B59B6),
      gradient: [Color(0xFF5B2C8D), Color(0xFF9B59B6)],
    ),
    ThemeColorScheme(
      name: 'Emerald Green',
      nameAr: 'أخضر زمردي',
      primary: Color(0xFF1B5E20),
      secondary: Color(0xFF43A047),
      gradient: [Color(0xFF1B5E20), Color(0xFF43A047)],
    ),
    ThemeColorScheme(
      name: 'Sunset Orange',
      nameAr: 'برتقالي غروب',
      primary: Color(0xFFE65100),
      secondary: Color(0xFFFF8F00),
      gradient: [Color(0xFFE65100), Color(0xFFFF8F00)],
    ),
    ThemeColorScheme(
      name: 'Cherry Red',
      nameAr: 'أحمر كرزي',
      primary: Color(0xFFC62828),
      secondary: Color(0xFFEF5350),
      gradient: [Color(0xFFC62828), Color(0xFFEF5350)],
    ),
    ThemeColorScheme(
      name: 'Golden Sand',
      nameAr: 'ذهبي رملي',
      primary: Color(0xFF8D6E2F),
      secondary: Color(0xFFD4A853),
      gradient: [Color(0xFF8D6E2F), Color(0xFFD4A853)],
    ),
    ThemeColorScheme(
      name: 'Teal Wave',
      nameAr: 'أزرق مخضر',
      primary: Color(0xFF00695C),
      secondary: Color(0xFF26A69A),
      gradient: [Color(0xFF00695C), Color(0xFF26A69A)],
    ),
    ThemeColorScheme(
      name: 'Rose Pink',
      nameAr: 'وردي',
      primary: Color(0xFFAD1457),
      secondary: Color(0xFFE91E63),
      gradient: [Color(0xFFAD1457), Color(0xFFE91E63)],
    ),
    ThemeColorScheme(
      name: 'Midnight Black',
      nameAr: 'أسود منتصف الليل',
      primary: Color(0xFF212121),
      secondary: Color(0xFF616161),
      gradient: [Color(0xFF212121), Color(0xFF424242)],
    ),
    ThemeColorScheme(
      name: 'Indigo Dream',
      nameAr: 'نيلي حالم',
      primary: Color(0xFF283593),
      secondary: Color(0xFF667EEA),
      gradient: [Color(0xFF283593), Color(0xFF667EEA)],
    ),
  ];

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('dark_mode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _selectedSchemeIndex = prefs.getInt('color_scheme') ?? 0;
    if (_selectedSchemeIndex >= colorSchemes.length) _selectedSchemeIndex = 0;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDark);
  }

  Future<void> setColorScheme(int index) async {
    if (index < 0 || index >= colorSchemes.length) return;
    _selectedSchemeIndex = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('color_scheme', index);
  }
}
