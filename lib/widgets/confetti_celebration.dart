import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiCelebration extends StatefulWidget {
  const ConfettiCelebration({super.key});

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_particles.isEmpty) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 70; i++) {
        _particles.add(_ConfettiParticle(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * -size.height - 20,
          size: _random.nextDouble() * 8 + 6,
          speedY: _random.nextDouble() * 3 + 2,
          speedX: _random.nextDouble() * 2 - 1,
          spinSpeed: _random.nextDouble() * 0.1 - 0.05,
          color: Colors.primaries[_random.nextInt(Colors.primaries.length)]
              .withOpacity(0.8),
          shape: _random.nextBool() ? _ConfettiShape.rectangle : _ConfettiShape.circle,
        ));
      }
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
        final screenSize = MediaQuery.of(context).size;
        for (var p in _particles) {
          p.update(screenSize.height, screenSize.width);
        }
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(particles: _particles),
        );
      },
    );
  }
}

enum _ConfettiShape { rectangle, circle }

class _ConfettiParticle {
  double x;
  double y;
  double size;
  double speedY;
  double speedX;
  double rotation = 0;
  double spinSpeed;
  Color color;
  _ConfettiShape shape;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.spinSpeed,
    required this.color,
    required this.shape,
  });

  void update(double maxHeight, double maxWidth) {
    y += speedY;
    x += speedX + math.sin(y / 30) * 0.5;
    rotation += spinSpeed;

    // Reset when off bottom
    if (y > maxHeight) {
      y = -20;
      x = math.Random().nextDouble() * maxWidth;
    }
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      if (p.shape == _ConfettiShape.circle) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
