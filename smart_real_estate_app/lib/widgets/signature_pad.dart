import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';

class SignaturePad extends StatefulWidget {
  final void Function(bool hasSig) onChanged;
  final void Function()? onConfirmed;

  const SignaturePad({
    super.key,
    required this.onChanged,
    this.onConfirmed,
  });

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad>
    with SingleTickerProviderStateMixin {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  bool _isConfirmed = false;
  DateTime? _confirmedAt;

  late AnimationController _confirmCtrl;
  late Animation<double> _confirmScale;

  bool get hasSignature => _strokes.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _confirmCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _confirmScale = CurvedAnimation(
        parent: _confirmCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
      _isConfirmed = false;
      _confirmedAt = null;
    });
    widget.onChanged(false);
  }

  void confirm() {
    if (!hasSignature) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isConfirmed = true;
      _confirmedAt = DateTime.now();
    });
    _confirmCtrl.forward(from: 0);
    widget.onConfirmed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final gradient = themeProvider.currentScheme.gradient;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(loc, theme, gradient),
        const SizedBox(height: 12),
        _buildCanvas(theme, gradient),
        const SizedBox(height: 12),
        if (!_isConfirmed) _buildControls(loc, theme, gradient),
        if (_isConfirmed) _buildConfirmedBadge(loc, theme, gradient),
        const SizedBox(height: 12),
        _buildDisclaimer(loc, theme),
      ],
    );
  }

  Widget _buildHeader(
      AppLocalizations loc, ThemeData theme, List<Color> gradient) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.draw_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          loc.electronicSignature,
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildCanvas(ThemeData theme, List<Color> gradient) {
    final borderColor = _isConfirmed
        ? const Color(0xFF4CAF50)
        : hasSignature
            ? gradient.first
            : theme.colorScheme.outline.withValues(alpha: 0.3);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 170,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: _isConfirmed || hasSignature ? 2.0 : 1.5,
        ),
        boxShadow: hasSignature
            ? [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            if (!hasSignature && !_isConfirmed)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.gesture,
                        size: 38,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.2)),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).drawSignature,
                      style: GoogleFonts.cairo(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.35),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            if (_isConfirmed)
              Center(
                child: ScaleTransition(
                  scale: _confirmScale,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(220, 90),
                        painter: _SignatureRenderer(strokes: _strokes,
                            color: const Color(0xFF1565C0)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified,
                              color: Color(0xFF4CAF50), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _confirmedAt != null
                                ? '${_confirmedAt!.hour.toString().padLeft(2, '0')}:${_confirmedAt!.minute.toString().padLeft(2, '0')} — ${_confirmedAt!.day}/${_confirmedAt!.month}/${_confirmedAt!.year}'
                                : '',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              GestureDetector(
                onPanStart: (d) {
                  setState(() {
                    _currentStroke = [d.localPosition];
                  });
                },
                onPanUpdate: (d) {
                  setState(() {
                    _currentStroke.add(d.localPosition);
                  });
                  widget.onChanged(true);
                },
                onPanEnd: (_) {
                  if (_currentStroke.isNotEmpty) {
                    setState(() {
                      _strokes.add(List.from(_currentStroke));
                      _currentStroke = [];
                    });
                  }
                },
                child: CustomPaint(
                  size: const Size(double.infinity, 170),
                  painter: _SignaturePainter(
                    strokes: _strokes,
                    currentStroke: _currentStroke,
                    strokeColor: gradient.first,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(
      AppLocalizations loc, ThemeData theme, List<Color> gradient) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: hasSignature ? clear : null,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: Text(loc.clearSignature,
              style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.4)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: hasSignature ? confirm : null,
            icon: const Icon(Icons.check_circle_outline, size: 18,
                color: Colors.white),
            label: Text(loc.confirmSignature,
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor:
                  hasSignature ? gradient.first : theme.colorScheme.outline,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: hasSignature ? 4 : 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmedBadge(
      AppLocalizations loc, ThemeData theme, List<Color> gradient) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user, color: Color(0xFF4CAF50), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.signatureConfirmed,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4CAF50),
                    fontSize: 14,
                  ),
                ),
                if (_confirmedAt != null)
                  Text(
                    '${loc.signedAt}: ${_confirmedAt!.day}/${_confirmedAt!.month}/${_confirmedAt!.year} ${_confirmedAt!.hour.toString().padLeft(2, '0')}:${_confirmedAt!.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isConfirmed = false;
                _confirmedAt = null;
              });
              _confirmCtrl.reset();
            },
            child: Text(loc.clearSignature,
                style: GoogleFonts.cairo(
                    color: Colors.red, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer(AppLocalizations loc, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              loc.signatureDisclaimer,
              style: GoogleFonts.cairo(
                fontSize: 11,
                height: 1.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color strokeColor;

  _SignaturePainter({
    required this.strokes,
    required this.currentStroke,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    void drawStroke(List<Offset> pts) {
      if (pts.isEmpty) return;
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length; i++) {
        if (i < pts.length - 1) {
          final mid = Offset(
            (pts[i].dx + pts[i + 1].dx) / 2,
            (pts[i].dy + pts[i + 1].dy) / 2,
          );
          path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
        } else {
          path.lineTo(pts[i].dx, pts[i].dy);
        }
      }
      canvas.drawPath(path, paint);
    }

    for (final stroke in strokes) {
      drawStroke(stroke);
    }
    drawStroke(currentStroke);
  }

  @override
  bool shouldRepaint(_SignaturePainter old) => true;
}

class _SignatureRenderer extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color color;

  _SignatureRenderer({required this.strokes, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (strokes.isEmpty) return;

    double minX = double.infinity, maxX = 0, minY = double.infinity, maxY = 0;
    for (final s in strokes) {
      for (final p in s) {
        if (p.dx < minX) minX = p.dx;
        if (p.dx > maxX) maxX = p.dx;
        if (p.dy < minY) minY = p.dy;
        if (p.dy > maxY) maxY = p.dy;
      }
    }
    final sigW = maxX - minX;
    final sigH = maxY - minY;
    final scale = (sigW > 0 && sigH > 0)
        ? (size.width / sigW).clamp(0.0, size.height / sigH)
        : 1.0;
    final offsetX = (size.width - sigW * scale) / 2 - minX * scale;
    final offsetY = (size.height - sigH * scale) / 2 - minY * scale;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      final path = Path()
        ..moveTo(stroke[0].dx * scale + offsetX,
            stroke[0].dy * scale + offsetY);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx * scale + offsetX,
            stroke[i].dy * scale + offsetY);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignatureRenderer old) => true;
}
