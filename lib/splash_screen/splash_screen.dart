import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/home_screen.dart';

class ProfessionalSplashScreen extends StatefulWidget {
  const ProfessionalSplashScreen({super.key});

  @override
  _ProfessionalSplashScreenState createState() => _ProfessionalSplashScreenState();
}

class _ProfessionalSplashScreenState extends State<ProfessionalSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: 20000.ms,
    )..forward();
_controller.addStatusListener((status) {
  if (status == AnimationStatus.completed) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );
  }
});}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Stack(
        children: [
          // خلفية متحركة بتأثير الجسيمات الكمومية
          _QuantumParticles(),
          
          // المحتوى الرئيسي مع تأثيرات متداخلة
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // الشعار مع تأثيرات متقدمة
                _HolographicLogo(controller: _controller),
                
                // النص مع تأثير الكتابة السائلة
                _LiquidText(),
              ],
            ),
          )
              .animate(controller: _controller)
              .shimmer(duration: 500.ms, delay: 300.ms)
              .scaleXY(begin: 0.95),
        ],
      ),
    );
  }
}

class _HolographicLogo extends StatelessWidget {
  final AnimationController controller;

  const _HolographicLogo({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Animate(
      controller: controller,
      effects: [
        ScaleEffect(
          duration: 400.ms,
          curve: Curves.easeOutExpo,
          begin: const Offset(0.8, 0.8),),
        ShimmerEffect(
          duration: 300.ms,
          angle: 0.8,
          color: Colors.blueAccent,
        ),
        _HologramEffect(),
        
      ],
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.blueGrey.shade800.withOpacity(0.9),
              Colors.blueGrey.shade900,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: const Icon(
          Icons.school,
          size: 100,
          color: Colors.white,
      ),
      ),
    );
  }
}

class _LiquidText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      """
      مرحبا بك في 
  SchoolMaster Pro
      """,
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        fontFamily: 'Cairo',
        letterSpacing: 1.5,
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scaleXY(begin: 0.9)
        .custom(
          builder: (_, value, child) => ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors:const [Colors.blueAccent, Colors.white],
              stops: [value, value + 0.1],
            ).createShader(bounds),
            child: child,
          ),
        );
  }
}

class _QuantumParticles extends StatelessWidget {
  final _particleCount = 100;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Animate(
        delay: 100.ms,
        effects: [
          ScaleEffect(
            begin: const Offset(1.2, 1.2),
            duration: 900.ms,
            curve: Curves.easeOutCirc,
          ),
        ],
        child: Stack(
          children: List.generate(
            _particleCount,
            (index) => _QuantumParticle(index: index),
          ),
        ),
      ),
    );
  }
}

class _QuantumParticle extends StatefulWidget {
  final int index;

  const _QuantumParticle({required this.index});

  @override
  __QuantumParticleState createState() => __QuantumParticleState();
}

class __QuantumParticleState extends State<_QuantumParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: (500 + widget.index % 500).ms,
      vsync: this,
    )..repeat(reverse: true);
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
      builder: (context, _) {
        final size = MediaQuery.sizeOf(context);
        return Positioned(
          left: size.width * Random().nextDouble(),
          top: size.height * _controller.value,
          child: Transform.scale(
            scale: 0.5 + _controller.value * 0.5,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.blueAccent
                    .withOpacity(0.3 - (_controller.value * 0.2)),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

// تأثير هولوجرام مخصص
class _HologramEffect extends Effect<double> {
  @override
  Duration get duration => 800.ms;

  @override
  Widget build(
    BuildContext context,
    Widget child,
    AnimationController controller,
    EffectEntry entry,
  ) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) => RadialGradient(
            colors: [
              Colors.blueAccent.withOpacity(0.8),
              Colors.transparent,
            ],
            stops: [0.5 + controller.value * 0.5, 1.0],
          ).createShader(bounds),
          blendMode: BlendMode.plus,
          child: child,
        );
      },
      child: child,
    );
  }
}