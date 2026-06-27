import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_master/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;

  @override
  void initState() {
    super.initState();

    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScaleAnimation = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _logoOpacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _runAnimation();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  Future<void> _runAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      await _logoAnimationController.forward();
    }

    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      context.go(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated Logo
              AnimatedBuilder(
                animation: _logoAnimationController,
                builder: (BuildContext context, Widget? child) {
                  return Opacity(
                    opacity: _logoOpacityAnimation.value,
                    child: Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.quiz_rounded,
                          size: 80,
                          color: Color(0xFF0E4DA4),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              // App Title & Tagline
              Column(
                children: [
                  Text(
                    'Quiz Master',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Test Your Knowledge, Master Your Skills!",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Loading Dots Animation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => _AnimatedDot(delayMs: index * 200),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final int delayMs;
  const _AnimatedDot({required this.delayMs});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 10 + (6 * _animation.value),
          height: 10 + (6 * _animation.value),
          decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.3 + (0.7 * _animation.value)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
