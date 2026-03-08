import 'dart:math';
import 'package:flutter/material.dart';

// =============================================================================
// AnimatedBalloonWidget — fixed-size balloon with smooth animations
//
// Features:
//   • Float-up animation with easing curves
//   • Subtle rotation (pendulum drift)
//   • Pulse animation (gentle breathing size change)
//   • Drag interaction (user can drag the balloon, springs back on release)
//   • Shadow, gradient texture, highlight for realistic look
//   • Sequential drift-away exit after reaching the top
// =============================================================================

/// Fixed balloon dimensions used across the app.
const double kBalloonWidth = 70;
const double kBalloonHeight = 100;

class AnimatedBalloonWidget extends StatefulWidget {
  final Color color;

  /// Speed multiplier for the float-up animation. >1 = slower, <1 = faster.
  final double speedMultiplier;

  /// Delay before the balloon starts its animation.
  final Duration startDelay;

  /// Called when the drift-away exit animation completes.
  final VoidCallback? onFinished;

  const AnimatedBalloonWidget({
    super.key,
    this.color = Colors.red,
    this.speedMultiplier = 1.0,
    this.startDelay = Duration.zero,
    this.onFinished,
  });

  @override
  State<AnimatedBalloonWidget> createState() => _AnimatedBalloonWidgetState();
}

class _AnimatedBalloonWidgetState extends State<AnimatedBalloonWidget>
    with TickerProviderStateMixin {
  // ── Animation controllers ──

  /// Controls the main float-up movement from bottom to top of screen.
  late final AnimationController _floatCtrl;

  /// Controls the gentle left-right rotation (pendulum effect).
  late final AnimationController _rotCtrl;

  /// Controls the subtle pulse (breathing) size animation.
  late final AnimationController _pulseCtrl;

  /// Controls the drift-away exit once the balloon reaches the top.
  late final AnimationController _driftCtrl;

  /// Controls the spring-back when user releases a drag.
  late AnimationController _springCtrl;

  // ── Animations ──

  /// Rotation angle animation: oscillates between -0.05 and 0.05 radians.
  late final Animation<double> _rotAnim;

  /// Pulse scale animation: oscillates between 0.97 and 1.03.
  late final Animation<double> _pulseAnim;

  /// Drift-away offset animation for the exit sequence.
  late final Animation<Offset> _driftAnim;

  /// Spring-back animation for returning drag offset to zero.
  late Animation<Offset> _springAnim;

  // ── Drag state ──

  /// Current drag offset applied by the user's finger.
  Offset _drag = Offset.zero;


  // ── Lifecycle flags ──

  /// True once float-up completes and drift-away begins.
  bool _drifting = false;

  /// True once the drift-away fully completes (balloon is gone).
  bool _finished = false;

  // ---------------------------------------------------------------------------
  // initState — set up all animation controllers and their curves
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    // Calculate float duration based on speed multiplier
    final int ms = (7000 * widget.speedMultiplier).round();

    // ── Float-up controller ──
    // Drives the balloon from the bottom of the screen to the top.
    // When complete, triggers the drift-away exit animation.
    _floatCtrl = AnimationController(
      duration: Duration(milliseconds: ms),
      vsync: this,
    )..addStatusListener(_onFloatComplete);

    // ── Rotation controller ──
    // Repeats back and forth to create a gentle pendulum sway.
    _rotCtrl = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rotAnim = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _rotCtrl, curve: Curves.easeInOutSine),
    );

    // ── Pulse controller ──
    // Repeats a subtle scale between 0.97x and 1.03x for a breathing effect.
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    // this is where i can change the pulse animation
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // ── Drift-away controller ──
    // Plays once after float-up finishes; moves the balloon off-screen
    // while fading it out. Calls onFinished when done.
    _driftCtrl = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..addStatusListener(_onDriftComplete);

    _driftAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(80, -400),
    ).animate(CurvedAnimation(parent: _driftCtrl, curve: Curves.easeInCubic));

    // ── Spring-back controller ──
    // Used to animate the drag offset back to zero when user releases.
    _springCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _springAnim = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _springCtrl, curve: Curves.elasticOut));

    // Begin the animation after the configured delay
    _startAfterDelay();
  }

  // ---------------------------------------------------------------------------
  // _onFloatComplete — triggers drift-away when balloon reaches the top
  // ---------------------------------------------------------------------------
  void _onFloatComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_drifting && mounted) {
      _drifting = true;
      _driftCtrl.forward();
    }
  }

  // ---------------------------------------------------------------------------
  // _onDriftComplete — marks the balloon as finished and notifies parent
  // ---------------------------------------------------------------------------
  void _onDriftComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted && !_finished) {
      _finished = true;
      widget.onFinished?.call();
    }
  }

  // ---------------------------------------------------------------------------
  // _startAfterDelay — waits for the configured delay then begins float-up
  // ---------------------------------------------------------------------------
  Future<void> _startAfterDelay() async {
    if (widget.startDelay > Duration.zero) {
      await Future.delayed(widget.startDelay);
    }
    if (mounted) _floatCtrl.forward();
  }

  // ---------------------------------------------------------------------------
  // _onDragStart — user begins dragging the balloon
  // ---------------------------------------------------------------------------
  void _onDragStart(DragStartDetails details) {
    // Stop any ongoing spring-back so the user takes control
    _springCtrl.stop();
  }

  // ---------------------------------------------------------------------------
  // _onDragUpdate — user moves finger while dragging the balloon
  // ---------------------------------------------------------------------------
  void _onDragUpdate(DragUpdateDetails details) {
    setState(() => _drag += details.delta);
  }

  // ---------------------------------------------------------------------------
  // _onDragEnd — user releases the balloon; animate it back via spring
  // ---------------------------------------------------------------------------
  void _onDragEnd(DragEndDetails details) {

    // Set up a spring-back animation from current drag offset to zero
    _springCtrl.dispose();
    _springCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _springAnim = Tween<Offset>(
      begin: _drag,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _springCtrl, curve: Curves.elasticOut),
    )..addListener(() {
        setState(() => _drag = _springAnim.value);
      });

    _springCtrl.forward();
  }

  // ---------------------------------------------------------------------------
  // dispose — clean up all animation controllers
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    _floatCtrl.dispose();
    _rotCtrl.dispose();
    _pulseCtrl.dispose();
    _driftCtrl.dispose();
    _springCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // build — composes all transforms (position, rotation, pulse, drag, drift)
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final double screenH = MediaQuery.of(context).size.height;

    // Float animation: moves Y from near bottom of screen to near top
    final Animation<double> floatAnim = Tween<double>(
      begin: screenH - kBalloonHeight - 90,
      end: 20.0,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOutCubic));

    return AnimatedBuilder(
      animation: Listenable.merge([_floatCtrl, _rotCtrl, _pulseCtrl, _driftCtrl]),
      builder: (_, child) {
        // Fade out during the drift-away phase
        final double opacity =
            _drifting ? (1.0 - _driftCtrl.value).clamp(0.0, 1.0) : 1.0;
        final Offset drift = _drifting ? _driftAnim.value : Offset.zero;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            // Combine: float position + user drag offset + drift-away offset
            offset: Offset(
              _drag.dx + drift.dx,
              floatAnim.value + _drag.dy + drift.dy,
            ),
            child: Transform.rotate(
              // Apply gentle pendulum rotation
              angle: _rotAnim.value,
              child: Transform.scale(
                // Apply subtle pulse (breathing) scale
                scale: _pulseAnim.value,
                child: child,
              ),
            ),
          ),
        );
      },
      // The child is rebuilt only when drag gestures change, not every frame
      child: SizedBox(
        width: kBalloonWidth,
        height: kBalloonHeight,
        child: GestureDetector(
          // ── Drag interaction ──
          // Allow the user to drag the balloon freely; springs back on release
          onPanStart: _onDragStart,
          onPanUpdate: _onDragUpdate,
          onPanEnd: _onDragEnd,
          child: CustomPaint(
            size: const Size(kBalloonWidth, kBalloonHeight),
            painter: BalloonPainter(color: widget.color),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// BalloonPainter — shadow + gradient body + texture overlay + highlight +
//                  knot + dangling string
//
// Draws a realistic-looking balloon entirely with CustomPaint.
// =============================================================================
class BalloonPainter extends CustomPainter {
  final Color color;
  const BalloonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double rx = size.width * 0.42;
    final double ry = size.height * 0.34;
    final double cy = size.height * 0.36;

    // Derive lighter and darker shades from the balloon's base colour
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color light =
        hsl.withLightness((hsl.lightness + 0.22).clamp(0.0, 1.0)).toColor();
    final Color dark =
        hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();
    final Rect rect =
        Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);

    // 1. Shadow — blurred oval beneath the balloon for depth
    _drawShadow(canvas, cx, cy, rx, ry);

    // 2. Body — radial gradient from light to dark gives a 3D look
    _drawBody(canvas, cx, cy, rx, ry, rect, light, dark);

    // 3. Texture overlay — sweep gradient for subtle surface detail
    _drawTexture(canvas, cx, cy, rx, ry, rect);

    // 4. Highlight — white blur spot to simulate light reflection
    _drawHighlight(canvas, cx, cy, rx, ry);

    // 5. Knot — small triangle at the bottom of the balloon
    _drawKnot(canvas, cx, cy, ry, dark);

    // 6. String — curvy line dangling below the knot
    _drawString(canvas, cx, cy, ry, size);
  }

  // ---------------------------------------------------------------------------
  // _drawShadow — blurred dark oval beneath the balloon body
  // ---------------------------------------------------------------------------
  void _drawShadow(Canvas c, double cx, double cy, double rx, double ry) {
    c.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 2, cy + ry * 0.15),
        width: rx * 1.6,
        height: ry * 1.3,
      ),
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  // ---------------------------------------------------------------------------
  // _drawBody — scaled circle with a radial gradient for the balloon shape
  // ---------------------------------------------------------------------------
  void _drawBody(Canvas c, double cx, double cy, double rx, double ry,
      Rect rect, Color light, Color dark) {
    c.save();
    c.translate(cx, cy);
    c.scale(1, ry / rx);
    c.drawCircle(
      Offset.zero,
      rx,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: [light, color, dark],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );
    c.restore();
  }

  // ---------------------------------------------------------------------------
  // _drawTexture — sweep gradient overlay for subtle surface texture
  // ---------------------------------------------------------------------------
  void _drawTexture(
      Canvas c, double cx, double cy, double rx, double ry, Rect rect) {
    c.save();
    c.translate(cx, cy);
    c.scale(1, ry / rx);
    c.drawCircle(
      Offset.zero,
      rx,
      Paint()
        ..shader = SweepGradient(
          center: const Alignment(-0.2, -0.2),
          colors: [
            Colors.white10,
            Colors.transparent,
            Colors.white10,
            Colors.transparent,
            Colors.white10,
          ],
        ).createShader(rect)
        ..blendMode = BlendMode.softLight,
    );
    c.restore();
  }

  // ---------------------------------------------------------------------------
  // _drawHighlight — blurred white oval simulating a light reflection
  // ---------------------------------------------------------------------------
  void _drawHighlight(Canvas c, double cx, double cy, double rx, double ry) {
    c.drawOval(
      Rect.fromCenter(
        center: Offset(cx - rx * 0.25, cy - ry * 0.28),
        width: rx * 0.38,
        height: ry * 0.48,
      ),
      Paint()
        ..color = Colors.white54
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  // ---------------------------------------------------------------------------
  // _drawKnot — small triangle at the base of the balloon
  // ---------------------------------------------------------------------------
  void _drawKnot(Canvas c, double cx, double cy, double ry, Color dark) {
    final double ky = cy + ry;
    c.drawPath(
      Path()
        ..moveTo(cx - 4, ky)
        ..lineTo(cx + 4, ky)
        ..lineTo(cx, ky + 8)
        ..close(),
      Paint()..color = dark,
    );
  }

  // ---------------------------------------------------------------------------
  // _drawString — cubic bezier curve dangling below the knot
  // ---------------------------------------------------------------------------
  void _drawString(Canvas c, double cx, double cy, double ry, Size size) {
    final double ky = cy + ry;
    final double tail = size.height - ky - 8;
    c.drawPath(
      Path()
        ..moveTo(cx, ky + 8)
        ..cubicTo(cx - 8, ky + 8 + tail * 0.3, cx + 8, ky + 8 + tail * 0.6,
            cx, size.height),
      Paint()
        ..color = Colors.grey[600]!
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(BalloonPainter old) => old.color != color;
}
