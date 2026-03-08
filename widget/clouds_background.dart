import 'package:flutter/material.dart';

// =============================================================================
// CloudsBackgroundWidget
//
// Animated sky background with:
//   • Vertical linear‑gradient sky (light blue → powder blue → cyan)
//   • 6 fluffy clouds drifting slowly left→right
//   • 3 bird silhouettes moving faster for parallax depth
//
// A single looping AnimationController (40 s) drives the scroll offset.
// =============================================================================

class CloudsBackgroundWidget extends StatefulWidget {
  const CloudsBackgroundWidget({super.key});

  @override
  State<CloudsBackgroundWidget> createState() => _CloudsBackgroundState();
}

class _CloudsBackgroundState extends State<CloudsBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(seconds: 40),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: Size.infinite,
        painter: _SkyPainter(_ctrl.value),
      ),
    );
  }
}

// =============================================================================
// _SkyPainter
// =============================================================================
class _SkyPainter extends CustomPainter {
  /// Scroll progress 0.0 → 1.0 (wraps).
  final double t;
  _SkyPainter(this.t);

  // Cloud data: (startX‑fraction, Y‑fraction, relative‑scale)
  static const _clouds = [
    (0.05, 0.06, 1.1),
    (0.30, 0.14, 0.7),
    (0.55, 0.04, 1.3),
    (0.20, 0.22, 0.55),
    (0.75, 0.10, 0.9),
    (0.90, 0.19, 0.65),
  ];

  // Bird data: (startX‑fraction, Y‑fraction, wingspan‑scale)
  static const _birds = [
    (0.15, 0.11, 0.55),
    (0.50, 0.06, 0.40),
    (0.78, 0.18, 0.48),
  ];

  @override
  void paint(Canvas canvas, Size s) {
    // ── Sky gradient ──
    canvas.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87CEEB), Color(0xFFB0E0E6), Color(0xFFE0F7FA)],
          stops: [0.0, 0.6, 1.0],
        ).createShader(Offset.zero & s),
    );

    // ── Clouds (slow) ──
    for (final (xf, yf, sc) in _clouds) {
      final double x = ((xf + t * 0.5) % 1.3 - 0.15) * s.width;
      _drawCloud(canvas, Offset(x, yf * s.height), sc * 55);
    }

    // ── Birds (faster → parallax) ──
    for (final (xf, yf, sc) in _birds) {
      final double x = ((xf + t * 1.1) % 1.4 - 0.2) * s.width;
      _drawBird(canvas, Offset(x, yf * s.height), sc * 18);
    }
  }

  /// Five overlapping ovals — shadow layer + white layer.
  void _drawCloud(Canvas canvas, Offset c, double r) {
    final Paint shadow = Paint()..color = Colors.grey.withValues(alpha: 0.12);
    final Paint white = Paint()..color = Colors.white.withValues(alpha: 0.88);

    final List<Offset> offsets = [
      Offset(-r * 0.5, r * 0.1),
      Offset(r * 0.4, r * 0.15),
      Offset.zero,
      Offset(-r * 0.25, 0),
      Offset(r * 0.2, -r * 0.05),
    ];

    // Shadow pass (slightly below)
    for (final Offset o in offsets) {
      canvas.drawOval(
        Rect.fromCenter(
          center: c + o + const Offset(0, 3),
          width: r * 0.8,
          height: r * 0.42,
        ),
        shadow,
      );
    }
    // White pass
    for (final Offset o in offsets) {
      canvas.drawOval(
        Rect.fromCenter(center: c + o, width: r * 0.8, height: r * 0.42),
        white,
      );
    }
  }

  /// Simple V‑shaped bird silhouette.
  void _drawBird(Canvas canvas, Offset c, double w) {
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - w, c.dy + w * 0.3)
        ..quadraticBezierTo(c.dx - w * 0.3, c.dy - w * 0.2, c.dx, c.dy)
        ..quadraticBezierTo(
            c.dx + w * 0.3, c.dy - w * 0.2, c.dx + w, c.dy + w * 0.3),
      Paint()
        ..color = Colors.grey[700]!
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SkyPainter old) => old.t != t;
}
