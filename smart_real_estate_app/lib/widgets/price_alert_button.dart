import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';

class PriceAlertButton extends StatefulWidget {
  final int propertyId;
  final double propertyPrice;

  const PriceAlertButton({
    super.key,
    required this.propertyId,
    required this.propertyPrice,
  });

  @override
  State<PriceAlertButton> createState() => _PriceAlertButtonState();
}

class _PriceAlertButtonState extends State<PriceAlertButton>
    with SingleTickerProviderStateMixin {
  bool _alertEnabled = false;
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnim = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.25)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.25, end: 0.92)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.92, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 30),
    ]).animate(_ctrl);
    _shakeAnim = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: -6), weight: 20),
      TweenSequenceItem(
          tween: Tween<double>(begin: -6, end: 6), weight: 20),
      TweenSequenceItem(
          tween: Tween<double>(begin: 6, end: -4), weight: 20),
      TweenSequenceItem(
          tween: Tween<double>(begin: -4, end: 4), weight: 20),
      TweenSequenceItem(
          tween: Tween<double>(begin: 4, end: 0), weight: 20),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle(BuildContext context, AppLocalizations loc) {
    HapticFeedback.mediumImpact();
    setState(() => _alertEnabled = !_alertEnabled);
    _ctrl.forward(from: 0);

    final msg = _alertEnabled ? loc.alertEnabled : loc.alertDisabled;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _alertEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off_outlined,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: GoogleFonts.cairo(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: _alertEnabled
            ? const Color(0xFF4CAF50)
            : Colors.grey.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final gradient = themeProvider.currentScheme.gradient;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.translate(
        offset: Offset(_alertEnabled ? _shakeAnim.value : 0, 0),
        child: Transform.scale(
          scale: _scaleAnim.value,
          child: GestureDetector(
            onTap: () => _toggle(context, loc),
            onLongPress: () => _showAlertSheet(context, loc, theme, gradient),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                gradient: _alertEnabled
                    ? LinearGradient(colors: gradient)
                    : null,
                color: _alertEnabled
                    ? null
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: _alertEnabled
                    ? null
                    : Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                boxShadow: _alertEnabled
                    ? [
                        BoxShadow(
                          color: gradient.first.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _alertEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_outlined,
                    color: _alertEnabled
                        ? Colors.white
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _alertEnabled ? loc.alertEnabled : loc.setPriceAlert,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _alertEnabled
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAlertSheet(BuildContext context, AppLocalizations loc,
      ThemeData theme, List<Color> gradient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PriceAlertSheet(
        loc: loc,
        theme: theme,
        gradient: gradient,
        propertyPrice: widget.propertyPrice,
        alertEnabled: _alertEnabled,
        onToggle: () {
          Navigator.pop(context);
          _toggle(context, loc);
        },
      ),
    );
  }
}

class _PriceAlertSheet extends StatelessWidget {
  final AppLocalizations loc;
  final ThemeData theme;
  final List<Color> gradient;
  final double propertyPrice;
  final bool alertEnabled;
  final VoidCallback onToggle;

  const _PriceAlertSheet({
    required this.loc,
    required this.theme,
    required this.gradient,
    required this.propertyPrice,
    required this.alertEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 22),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.price_change, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 18),
          Text(
            loc.priceAlert,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.priceAlertDesc,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loc.notifyPriceDrop,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onToggle,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                backgroundColor:
                    alertEnabled ? Colors.grey.shade600 : gradient.first,
                foregroundColor: Colors.white,
              ),
              child: Text(
                alertEnabled ? loc.alertDisabled : loc.alertEnabled,
                style: GoogleFonts.cairo(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
