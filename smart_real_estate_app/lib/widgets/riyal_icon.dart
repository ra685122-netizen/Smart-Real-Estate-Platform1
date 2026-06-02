import 'package:flutter/material.dart';

class RiyalIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const RiyalIcon({Key? key, this.size = 20, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.118),
      painter: _RiyalPainter(color: color ?? Theme.of(context).primaryColor),
    );
  }
}

class _RiyalPainter extends CustomPainter {
  final Color color;

  _RiyalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final sx = size.width / 1124.14;
    final sy = size.height / 1256.39;

    final path1 = Path();
    path1.moveTo(699.62 * sx, 1113.02 * sy);
    path1.cubicTo(
      (699.62 - 20.06) * sx, (1113.02 + 44.48) * sy,
      (699.62 - 33.32) * sx, (1113.02 + 92.75) * sy,
      (699.62 - 38.4) * sx, (1113.02 + 143.37) * sy,
    );
    path1.lineTo((699.62 - 38.4 + 424.51) * sx, (1113.02 + 143.37 - 90.24) * sy);
    path1.cubicTo(
      (699.62 - 38.4 + 424.51 + 20.06) * sx, (1113.02 + 143.37 - 90.24 - 44.47) * sy,
      (699.62 - 38.4 + 424.51 + 33.31) * sx, (1113.02 + 143.37 - 90.24 - 92.75) * sy,
      (699.62 - 38.4 + 424.51 + 38.4) * sx, (1113.02 + 143.37 - 90.24 - 143.37) * sy,
    );
    path1.close();
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(1085.73 * sx, 895.8 * sy);
    path2.cubicTo(
      (1085.73 + 20.06) * sx, (895.8 - 44.47) * sy,
      (1085.73 + 33.32) * sx, (895.8 - 92.75) * sy,
      (1085.73 + 38.4) * sx, (895.8 - 143.37) * sy,
    );
    path2.lineTo((1124.13 - 330.68) * sx, (752.43 + 70.33) * sy);
    path2.lineTo((1124.13 - 330.68) * sx, (752.43 + 70.33 - 135.2) * sy);
    path2.lineTo((1124.13 - 330.68 + 292.27) * sx, (752.43 + 70.33 - 135.2 - 62.11) * sy);
    path2.cubicTo(
      (1124.13 - 330.68 + 292.27 + 20.06) * sx, (752.43 + 70.33 - 135.2 - 62.11 - 44.47) * sy,
      (1124.13 - 330.68 + 292.27 + 33.32) * sx, (752.43 + 70.33 - 135.2 - 62.11 - 92.75) * sy,
      (1124.13 - 330.68 + 292.27 + 38.4) * sx, (752.43 + 70.33 - 135.2 - 62.11 - 143.37) * sy,
    );
    path2.lineTo((1124.13 - 330.68 + 292.27 + 38.4 - 330.68) * sx, (752.43 + 70.33 - 135.2 - 62.11 - 143.37 + 70.27) * sy);
    path2.lineTo((1124.13 - 330.68 + 292.27 + 38.4 - 330.68) * sx, 66.13 * sy);
    path2.cubicTo(
      (793.45 - 50.67) * sx, (66.13 + 28.45) * sy,
      (793.45 - 95.67) * sx, (66.13 + 66.32) * sy,
      (793.45 - 132.25) * sx, (66.13 + 110.99) * sy,
    );
    path2.lineTo(661.2 * sx, (177.12 + 403.35) * sy);
    path2.lineTo((661.2 - 132.25) * sx, (580.47 + 28.11) * sy);
    path2.lineTo(528.95 * sx, 0 * sy);
    path2.cubicTo(
      (528.95 - 50.67) * sx, 28.44 * sy,
      (528.95 - 95.67) * sx, 66.32 * sy,
      (528.95 - 132.25) * sx, 110.99 * sy,
    );
    path2.lineTo(396.7 * sx, (110.99 + 525.69) * sy);
    path2.lineTo((396.7 - 295.91) * sx, (636.68 + 62.88) * sy);
    path2.cubicTo(
      (100.79 - 20.06) * sx, (699.56 + 44.47) * sy,
      (100.79 - 33.33) * sx, (699.56 + 92.75) * sy,
      (100.79 - 38.42) * sx, (699.56 + 143.37) * sy,
    );
    path2.lineTo((62.37 + 334.33) * sx, (842.93 - 71.05) * sy);
    path2.lineTo(396.7 * sx, (771.88 + 170.26) * sy);
    path2.lineTo((396.7 - 358.3) * sx, (942.14 + 76.14) * sy);
    path2.cubicTo(
      (38.4 - 20.06) * sx, (1018.28 + 44.47) * sy,
      (38.4 - 33.32) * sx, (1018.28 + 92.75) * sy,
      (38.4 - 38.4) * sx, (1018.28 + 143.37) * sy,
    );
    path2.lineTo(375.04 * sx, (1161.65 - 79.7) * sy);
    path2.cubicTo(
      (375.04 + 30.53) * sx, (1081.95 - 6.35) * sy,
      (375.04 + 56.77) * sx, (1081.95 - 24.4) * sy,
      (375.04 + 73.83) * sx, (1081.95 - 49.24) * sy,
    );
    path2.lineTo((448.87 + 68.78) * sx, (1032.71 - 101.97) * sy);
    path2.cubicTo(
      (517.65 + 7.14) * sx, (930.74 - 10.55) * sy,
      (517.65 + 11.3) * sx, (930.74 - 23.27) * sy,
      (517.65 + 11.3) * sx, (930.74 - 36.97) * sy,
    );
    path2.lineTo(528.95 * sx, (893.77 - 149.98) * sy);
    path2.lineTo((528.95 + 132.25) * sx, (743.79 - 28.11) * sy);
    path2.lineTo(661.2 * sx, (715.68 + 270.4) * sy);
    path2.lineTo((661.2 + 424.53) * sx, (986.08 - 90.28) * sy);
    path2.close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
