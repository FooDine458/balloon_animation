import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widget/animated_ballon.dart';
import '../widget/clouds_background.dart';

// =============================================================================
// BalloonScenePage — single page app
//
// Opens with animated cloudy sky. Two buttons at the bottom:
//   Launch → spawns 10 balloons that auto-start floating up + plays sound
//   Reset  → removes all balloons, stops sound, ready to launch again
// =============================================================================

class BalloonScenePage extends StatefulWidget {
  const BalloonScenePage({super.key});

  @override
  State<BalloonScenePage> createState() => _BalloonScenePageState();
}

class _BalloonScenePageState extends State<BalloonScenePage> {
  // Predefined balloon colours to pick from randomly.
  static const _colors = [
    Colors.red, Colors.blue, Colors.green, Colors.orange,
    Colors.purple, Colors.pink, Colors.teal, Colors.amber,
    Colors.indigo, Colors.cyan,
  ];

  final _rng = Random();

  /// Audio player instance for launch / ambient sound effects.
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Pre-loaded sound bytes from the asset bundle.
  Uint8List? _soundBytes;

  /// Each launch increments this so widget keys are always unique.
  int _batch = 0;

  /// Current set of balloon configs. Empty = nothing on screen.
  List<_B> _balloons = [];

  /// Whether balloons are currently on screen.
  bool get _hasLaunched => _balloons.isNotEmpty;

  // ---------------------------------------------------------------------------
  // initState — pre-load sound asset bytes so playback is instant on launch
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadSoundBytes();
  }

  // ---------------------------------------------------------------------------
  // _loadSoundBytes — reads the mp3 from the Flutter asset bundle into memory
  // ---------------------------------------------------------------------------
  Future<void> _loadSoundBytes() async {
    try {
      final ByteData data = await rootBundle.load('assets/sound/sound.mp3');
      _soundBytes = data.buffer.asUint8List();
    } catch (e) {
      debugPrint('Failed to load sound asset: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // _playLaunchSound — plays the pre-loaded sound bytes when balloons launch
  // ---------------------------------------------------------------------------
  Future<void> _playLaunchSound() async {
    try {
      if (_soundBytes == null) return;
      await _audioPlayer.stop();
      await _audioPlayer.play(BytesSource(_soundBytes!));
    } catch (e) {
      debugPrint('Failed to play sound: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // _stopSound — stops any currently playing sound effect
  // ---------------------------------------------------------------------------
  Future<void> _stopSound() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // _launch — generates 10 balloons with random colours, speeds, delays
  //           and horizontal positions, then plays the launch sound
  // ---------------------------------------------------------------------------
  void _launch() {
    _batch++;
    // this is where i can change how many balloons
    setState(() {
      _balloons = List.generate(10, (i) => _B(
        color: _colors[_rng.nextInt(_colors.length)],
        speed: 0.8 + _rng.nextDouble() * 0.6,
        delay: Duration(milliseconds: _rng.nextInt(2000)),
        x: 0.1 + _rng.nextDouble() * 0.8,
      ));
    });
    _playLaunchSound();
  }

  // ---------------------------------------------------------------------------
  // _reset — clears all balloons from the screen and stops sound
  // ---------------------------------------------------------------------------
  void _reset() {
    _stopSound();
    setState(() => _balloons = []);
  }

  // ---------------------------------------------------------------------------
  // dispose — release the audio player resources
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // build — assembles the background, balloons, and control buttons
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background (always visible) ──
          const Positioned.fill(
            child: RepaintBoundary(child: CloudsBackgroundWidget()),
          ),

          // ── Balloons ──
          for (int i = 0; i < _balloons.length; i++)
            Positioned(
              left: _balloons[i].x * sw - kBalloonWidth / 2,
              top: 0,
              child: RepaintBoundary(
                child: AnimatedBalloonWidget(
                  key: ValueKey('b_${_batch}_$i'),
                  color: _balloons[i].color,
                  speedMultiplier: _balloons[i].speed,
                  startDelay: _balloons[i].delay,
                ),
              ),
            ),

          // ── Bottom buttons ──
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Row(
                  children: [
                    Expanded(child: _btn(
                      icon: Icons.rocket_launch,
                      label: 'Launch',
                      color: Colors.green,
                      onPressed: _hasLaunched ? null : _launch,
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _btn(
                      icon: Icons.replay,
                      label: 'Reset',
                      color: Colors.redAccent,
                      onPressed: _hasLaunched ? _reset : null,
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // _btn — reusable styled button for Launch / Reset
  // ---------------------------------------------------------------------------
  Widget _btn({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withAlpha(80),
        disabledForegroundColor: Colors.white54,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      onPressed: onPressed,
    );
  }
}

// =============================================================================
// _B — lightweight data class holding a single balloon's configuration
// =============================================================================
class _B {
  /// The balloon's fill colour.
  final Color color;

  /// Speed multiplier controlling how fast the balloon floats up.
  final double speed;

  /// Staggered delay before the balloon starts animating.
  final Duration delay;

  /// Horizontal position as a fraction of screen width (0.0–1.0).
  final double x;

  _B({required this.color, required this.speed, required this.delay, required this.x});
}
