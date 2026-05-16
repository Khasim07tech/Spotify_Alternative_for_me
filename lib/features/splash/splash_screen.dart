import 'package:flutter/material.dart';

import '../auth/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 950), () {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 420),
          pageBuilder: (context, animation, secondaryAnimation) {
            return const AuthGate();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
                child: child,
              ),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.18),
              Theme.of(context).scaffoldBackgroundColor,
              scheme.secondary.withValues(alpha: 0.10),
            ],
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.86, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.32),
                        blurRadius: 32,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: const Center(child: _KxMark(size: 42)),
                ),
                const SizedBox(height: 22),
                Text(
                  'KX Wave',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KxMark extends StatelessWidget {
  const _KxMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      'KX',
      style: TextStyle(
        color: Colors.black,
        fontSize: size,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
