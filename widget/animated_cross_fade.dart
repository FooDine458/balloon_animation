// lib/widgets/animated_cross_fade.dart
import 'package:flutter/material.dart';

class AnimatedCrossFadeWidget extends StatefulWidget {
  const AnimatedCrossFadeWidget({Key? key}) : super(key: key);

  @override
  _AnimatedCrossFadeWidgetState createState() =>
      _AnimatedCrossFadeWidgetState();
}

class _AnimatedCrossFadeWidgetState extends State<AnimatedCrossFadeWidget>
    with SingleTickerProviderStateMixin {
  bool _showDayMode = true;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _showDayMode = !_showDayMode;
      if (_showDayMode) {
        _rotateController.reverse();
      } else {
        _rotateController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title section
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 600),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _showDayMode ? Colors.deepPurple : Colors.indigo[300],
              letterSpacing: 1.2,
            ),
            child: const Text('Day & Night'),
          ),
          const SizedBox(height: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 600),
            style: TextStyle(
              fontSize: 14,
              color: _showDayMode ? Colors.grey[500] : Colors.grey[400],
            ),
            child: const Text('Experience the cross-fade transition'),
          ),
          const SizedBox(height: 28),

          // Animated background container
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _showDayMode
                  ? Colors.amber.withValues(alpha: 0.08)
                  : Colors.indigo.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _showDayMode
                    ? Colors.amber.withValues(alpha: 0.2)
                    : Colors.indigo.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Cross Fade Card
                GestureDetector(
                  onTap: _toggleMode,
                  child: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 800),
                    sizeCurve: Curves.easeInOutCubic,
                    firstCurve: Curves.easeInOutCubic,
                    secondCurve: Curves.easeInOutCubic,
                    crossFadeState: _showDayMode
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: _buildModeCard(
                      icon: Icons.wb_sunny_rounded,
                      title: 'Day Mode',
                      subtitle: 'The sun is shining bright ☀️',
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFA726),
                          Color(0xFFFF7043),
                          Color(0xFFEF5350),
                        ],
                      ),
                      iconColor: Colors.white,
                      accentColor: Colors.orange[200]!,
                    ),
                    secondChild: _buildModeCard(
                      icon: Icons.nightlight_round,
                      title: 'Night Mode',
                      subtitle: 'Stars light up the sky 🌙',
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1A237E),
                          Color(0xFF283593),
                          Color(0xFF5C6BC0),
                        ],
                      ),
                      iconColor: Colors.yellow[200]!,
                      accentColor: Colors.indigo[200]!,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Toggle Button
                ElevatedButton.icon(
                  onPressed: _toggleMode,
                  icon: RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5)
                        .animate(_rotateController),
                    child: Icon(
                      _showDayMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      size: 20,
                    ),
                  ),
                  label: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _showDayMode ? 'Switch to Night' : 'Switch to Day',
                      key: ValueKey<bool>(_showDayMode),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _showDayMode ? Colors.deepPurple : Colors.amber[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Status indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _showDayMode
                  ? Colors.orange.withValues(alpha: 0.1)
                  : Colors.indigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _showDayMode ? Colors.orange : Colors.indigo,
                    boxShadow: [
                      BoxShadow(
                        color: (_showDayMode ? Colors.orange : Colors.indigo)
                            .withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _showDayMode ? 'Day mode active' : 'Night mode active',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _showDayMode ? Colors.orange[800] : Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required Color iconColor,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top-right decorative circle
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Bottom-left decorative circle
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Small floating circles
          Positioned(
            top: 20,
            left: 30,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 50,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.85),
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