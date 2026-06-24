import 'dart:math';
import 'package:flutter/material.dart';
import '../services/theme_manager.dart';

class ParticleBackground extends StatefulWidget {
  final GameTheme theme;

  const ParticleBackground({super.key, required this.theme});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generate random particles
    for (int i = 0; i < 40; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 3 + 1.5,
          speedY: _random.nextDouble() * 0.02 + 0.005,
          opacity: _random.nextDouble() * 0.4 + 0.15,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Update particle positions
        for (var p in _particles) {
          p.y -= p.speedY * 0.1; // slowly drift upwards
          if (p.y < 0) {
            p.y = 1.0;
            p.x = _random.nextDouble();
          }
        }

        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            accentColor: widget.theme.accentColor,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speedY;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color accentColor;

  _ParticlePainter({required this.particles, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a very subtle grid
    final gridPaint = Paint()
      ..color = accentColor.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    double gridSpacing = 40.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw drifting glow particles
    for (var p in particles) {
      final particlePaint = Paint()
        ..color = accentColor.withOpacity(p.opacity)
        ..style = PaintingStyle.fill;

      final offset = Offset(p.x * size.width, p.y * size.height);
      
      // Draw subtle glow shadow for the particle
      final glowPaint = Paint()
        ..color = accentColor.withOpacity(p.opacity * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      
      canvas.drawCircle(offset, p.size * 2, glowPaint);
      canvas.drawCircle(offset, p.size, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
