import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/property_provider.dart';
import '../../l10n/app_localizations.dart';

class VirtualTourView extends StatefulWidget {
  final String propertyTitle;
  final int propertyId;

  const VirtualTourView({
    super.key,
    required this.propertyTitle,
    required this.propertyId,
  });

  @override
  State<VirtualTourView> createState() => _VirtualTourViewState();
}

class _VirtualTourViewState extends State<VirtualTourView> with TickerProviderStateMixin {
  int _currentRoomIndex = 0;
  bool _isAutoRotating = false;
  bool _showRoomInfo = false;
  bool _isFullScreen = false;
  late PageController _pageController;
  List<String> _images = [];
  double _dragX = 0;
  double _dragY = 0;
  late AnimationController _rotateController;
  late AnimationController _infoController;
  late Animation<double> _infoAnimation;

  final List<Map<String, dynamic>> _rooms = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _pageController = PageController();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _infoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _infoAnimation = CurvedAnimation(
      parent: _infoController,
      curve: Curves.easeOutCubic,
    );

    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final allProps = propertyProvider.allProperties.isNotEmpty
        ? propertyProvider.allProperties
        : propertyProvider.properties;
    final property = allProps.where((p) => p.id == widget.propertyId).firstOrNull;
    _images = property?.images ?? [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    if (_rooms.isEmpty) {
      _rooms.addAll([
        {
          'name': l10n.livingRoom,
          'icon': Icons.weekend,
          'desc': l10n.isArabic ? 'صالة واسعة بإضاءة طبيعية' : 'Spacious living room with natural light',
          'area': '45 ${l10n.sqm}',
        },
        {
          'name': l10n.bedroom,
          'icon': Icons.bed,
          'desc': l10n.isArabic ? 'غرفة نوم رئيسية مع حمام خاص' : 'Master bedroom with en-suite bathroom',
          'area': '28 ${l10n.sqm}',
        },
        {
          'name': l10n.kitchen,
          'icon': Icons.kitchen,
          'desc': l10n.isArabic ? 'مطبخ حديث مجهز بالكامل' : 'Modern fully equipped kitchen',
          'area': '18 ${l10n.sqm}',
        },
        {
          'name': l10n.garden,
          'icon': Icons.park,
          'desc': l10n.isArabic ? 'حديقة خضراء مع مسبح' : 'Green garden with swimming pool',
          'area': '120 ${l10n.sqm}',
        },
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    _rotateController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  void _changeRoom(int index) {
    setState(() {
      _currentRoomIndex = index;
      _dragX = 0;
      _dragY = 0;
    });
    if (index < _images.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _toggleAutoRotate() {
    setState(() => _isAutoRotating = !_isAutoRotating);
    if (_isAutoRotating) {
      _rotateController.repeat();
    } else {
      _rotateController.stop();
    }
  }

  void _toggleRoomInfo() {
    setState(() => _showRoomInfo = !_showRoomInfo);
    if (_showRoomInfo) {
      _infoController.forward();
    } else {
      _infoController.reverse();
    }
  }

  void _toggleFullScreen() {
    setState(() => _isFullScreen = !_isFullScreen);
    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _shareTour() {
    Clipboard.setData(ClipboardData(text: '360° Virtual Tour: ${widget.propertyTitle}'));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).isArabic ? 'تم نسخ رابط الجولة' : 'Tour link copied'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final primary = themeProvider.currentScheme.primary;
    final secondary = themeProvider.currentScheme.secondary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: Text(
                widget.propertyTitle,
                style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(icon: const Icon(Icons.share), onPressed: _shareTour),
                IconButton(
                  icon: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
                  onPressed: _toggleFullScreen,
                ),
              ],
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
      body: Stack(
        children: [
          // 360° View with gesture panning
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _dragX += details.delta.dx * 0.3;
                _dragY += details.delta.dy * 0.3;
                _dragY = _dragY.clamp(-30.0, 30.0);
              });
            },
            onDoubleTap: _toggleFullScreen,
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                final autoRotation = _isAutoRotating ? _rotateController.value * 360 : 0.0;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY((_dragX + autoRotation) * pi / 180)
                    ..rotateX(_dragY * pi / 180),
                  child: _images.isEmpty
                      ? _buildPlaceholder(themeProvider)
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: _images.length,
                          onPageChanged: (i) => setState(() => _currentRoomIndex = i),
                          itemBuilder: (context, index) {
                            return Image.network(
                              _images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(themeProvider),
                            );
                          },
                        ),
                );
              },
            ),
          ),

          // Compass indicator
          Positioned(
            top: _isFullScreen ? 30 : 100,
            right: 16,
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) => Transform.rotate(
                angle: -(_dragX + (_isAutoRotating ? _rotateController.value * 360 : 0)) * pi / 180,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                  ),
                  child: const Center(
                    child: Text('N', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ),
          ),

          // Room info overlay
          if (_showRoomInfo && _currentRoomIndex < _rooms.length)
            Positioned(
              top: _isFullScreen ? 80 : 160,
              left: 16,
              right: 80,
              child: FadeTransition(
                opacity: _infoAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(_infoAnimation),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_rooms[_currentRoomIndex]['icon'] as IconData, color: Colors.white, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              _rooms[_currentRoomIndex]['name'] as String,
                              style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _rooms[_currentRoomIndex]['desc'] as String,
                          style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.square_foot, color: Colors.orangeAccent, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _rooms[_currentRoomIndex]['area'] as String,
                              style: GoogleFonts.cairo(color: Colors.orangeAccent, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Room progress dots
          Positioned(
            top: _isFullScreen ? 30 : 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _rooms.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentRoomIndex == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentRoomIndex == i ? primary : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          // Room navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildRoomNavigation(l10n, primary, secondary),
          ),

          // Control buttons
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              children: [
                _buildControlButton(
                  icon: Icons.info_outline,
                  isActive: _showRoomInfo,
                  primary: primary,
                  onTap: _toggleRoomInfo,
                ),
                const SizedBox(height: 10),
                _buildControlButton(
                  icon: Icons.view_in_ar,
                  isActive: _isAutoRotating,
                  primary: primary,
                  onTap: _toggleAutoRotate,
                ),
                const SizedBox(height: 10),
                _buildControlButton(
                  icon: _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  isActive: _isFullScreen,
                  primary: primary,
                  onTap: _toggleFullScreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required Color primary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? primary : Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
          boxShadow: isActive
              ? [BoxShadow(color: primary.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2)]
              : [],
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: themeProvider.currentScheme.gradient,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.view_in_ar, size: 80, color: Colors.white.withValues(alpha: 0.9)),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).virtualTour360,
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).isArabic ? 'اسحب للتدوير' : 'Drag to rotate',
              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomNavigation(AppLocalizations l10n, Color primary, Color secondary) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_rooms.length, (index) {
          final isSelected = _currentRoomIndex == index;
          return GestureDetector(
            onTap: () => _changeRoom(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? primary.withValues(alpha: 0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? Border.all(color: primary, width: 1.5) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _rooms[index]['icon'] as IconData,
                    color: isSelected ? primary : Colors.white60,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _rooms[index]['name'] as String,
                    style: GoogleFonts.cairo(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
