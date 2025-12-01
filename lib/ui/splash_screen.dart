import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


// --- (إضافة جديدة) ---
// --- (نهاية الإضافة) ---

// ... (الكود الخاص بك لـ brandGreen و appNameAr يبقى كما هو) ...
const Color brandGreen = Color(0xFF2BBA5A);
const String appNameAr = "\u062E\u0636\u0627\u0631\u0643\u0645"; // خضاركم


class Splash2 extends StatefulWidget {
  const Splash2({super.key});

  @override
  State<Splash2> createState() => _Splash2State();
}

class _Splash2State extends State<Splash2> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 🚀 START EVERYTHING IN PARALLEL
    // 1. Minimum branding time (so the logo animation finishes)
    final minSplash = Future.delayed(const Duration(seconds: 2));

    // 2. Heavy lifting (Auth check + Pre-caching)
    final bootstrap = _bootstrapApp();

    // ⏳ Wait for BOTH to finish
    // This means if bootstrap takes 0.5s, we wait 1.5s more.
    // If bootstrap takes 3s, we wait 3s total (no extra delay).
    final results = await Future.wait([minSplash, bootstrap]);
    
    final nextRoute = results[1] as String;

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  Future<String> _bootstrapApp() async {
    // 🖼️ Pre-cache critical Home assets while waiting
    // This makes the Home screen appear INSTANTLY with no image pop-in
    await Future.wait([
      _precache('assets/icons/categories.png'),
      _precache('assets/icons/vegetable.png'),
      _precache('assets/icons/fruit.png'),
      _precache('assets/icons/dates.png'),
      _precache('assets/icons/egg.png'),
      _precache('assets/icons/fav1.png'),
    ]);

    // 🔐 Auth Check Logic
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) return '/home';

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is signed in to Firebase, but maybe not fully registered in Firestore?
      // Let's check quickly.
      try {
         final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
         
         if (doc.exists && (doc.data()?['name'] ?? '').toString().isNotEmpty) {
           await prefs.setBool('isLoggedIn', true);
           return '/home';
         } else {
           return '/create-profile';
         }
      } catch (e) {
        // Offline or error? Fallback to login if we can't verify.
        return '/phone-login';
      }
    }

    return '/phone-login';
  }

  Future<void> _precache(String assetPath) async {
    try {
      if (!mounted) return;
      await precacheImage(AssetImage(assetPath), context);
    } catch (e) {
      // Ignore asset errors, don't crash splash
      debugPrint('Error precaching $assetPath: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF7FAF8),
      body: Stack(
        children: [
          RepaintBoundary(child: _BackgroundVeggies()),
          _AnimatedWordmark(),
        ],
      ),
    );
  }
}

// ... (باقي كود التصميم الخاص بك كما هو بالضبط) ...
// ... (_AnimatedWordmark, _CenteredWordmark, _BackgroundVeggies, ...) ...
// ... (انسخ والصق كل كلاسات الـ Painter الخاصة بك هنا) ...

// 🔹 Animated fade + scale for the logo
class _AnimatedWordmark extends StatelessWidget {
  const _AnimatedWordmark();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, 0.10),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(seconds: 2),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: child,
          ),
        ),
        child: const _CenteredWordmark(),
      ),
    );
  }
}

class _CenteredWordmark extends StatelessWidget {
  const _CenteredWordmark();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            appNameAr,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              height: 0.95,
              color: brandGreen,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Khodarkom',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 0.95,
              letterSpacing: 0.1,
              color: brandGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundVeggies extends StatelessWidget {
  const _BackgroundVeggies();

  @override
  Widget build(BuildContext context) {
    final faint = brandGreen.withOpacity(0.15);

    Widget _veg({
      double? top,
      double? left,
      double? right,
      double? bottom,
      required double size,
      required CustomPainter painter,
    }) =>
        Positioned(
          top: top,
          left: left,
          right: right,
          bottom: bottom,
          child: CustomPaint(size: Size.square(size), painter: painter),
        );

    return Stack(
      children: [
        _veg(top: 28, left: 20, size: 50, painter: _TomatoPainter(color: faint)),
        _veg(top: 90, right: 28, size: 76, painter: _LettuceHeadPainter(color: faint)),
        _veg(top: 170, left: 70, size: 60, painter: _CarrotPainter(color: faint)),
        _veg(top: 60, left: 150, size: 38, painter: _LettuceHeadPainter(color: faint)),
        _veg(top: 260, right: 30, size: 56, painter: _CarrotPainter(color: faint)),
        _veg(bottom: 120, left: 26, size: 56, painter: _LeafOutlinePainter(color: faint)),
        _veg(bottom: 60, right: 32, size: 42, painter: _TomatoPainter(color: faint)),
        _veg(bottom: 80, left: 140, size: 46, painter: _CarrotPainter(color: faint)),
        _veg(top: 40, right: 110, size: 42, painter: _LeafOutlinePainter(color: faint)),
        _veg(bottom: 70, left: 24, size: 44, painter: _CarrotPainter(color: faint)),
      ],
    );
  }
}

// 🥬 Tomato
class _TomatoPainter extends CustomPainter {
  _TomatoPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2 + 4);
    final r = math.min(size.width, size.height) * 0.38;
    canvas.drawCircle(center, r, stroke);

    final top = Offset(center.dx, center.dy - r);
    canvas.drawLine(top + const Offset(0, -2), top + const Offset(0, -10), stroke);

    final calyx = Path();
    const points = 5;
    const outer = 10.0;
    const inner = 5.0;
    for (int i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final radius = isOuter ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / points;
      final p = Offset(
        top.dx + radius * math.cos(angle),
        top.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        calyx.moveTo(p.dx, p.dy);
      } else {
        calyx.lineTo(p.dx, p.dy);
      }
    }
    calyx.close();
    canvas.drawPath(calyx, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 🥬 Lettuce
class _LettuceHeadPainter extends CustomPainter {
  _LettuceHeadPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final p = Path();
    final w = size.width, h = size.height;
    p.moveTo(w * 0.50, h * 0.05);
    p.quadraticBezierTo(w * 0.75, h * 0.08, w * 0.90, h * 0.25);
    p.quadraticBezierTo(w * 0.98, h * 0.45, w * 0.80, h * 0.70);
    p.quadraticBezierTo(w * 0.65, h * 0.90, w * 0.50, h * 0.95);
    p.quadraticBezierTo(w * 0.35, h * 0.90, w * 0.20, h * 0.70);
    p.quadraticBezierTo(w * 0.02, h * 0.45, w * 0.10, h * 0.25);
    p.quadraticBezierTo(w * 0.25, h * 0.08, w * 0.50, h * 0.05);
    canvas.drawPath(p, stroke);

    final v1 = Path()
      ..moveTo(w * 0.50, h * 0.15)
      ..quadraticBezierTo(w * 0.60, h * 0.45, w * 0.50, h * 0.80);
    final v2 = Path()
      ..moveTo(w * 0.45, h * 0.18)
      ..quadraticBezierTo(w * 0.35, h * 0.45, w * 0.42, h * 0.78);
    canvas.drawPath(v1, stroke);
    canvas.drawPath(v2, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 🌿 Leaf
class _LeafOutlinePainter extends CustomPainter {
  _LeafOutlinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final p = Path();
    p.moveTo(size.width * 0.5, 0);
    p.quadraticBezierTo(size.width * 0.95, size.height * 0.25,
        size.width * 0.62, size.height * 0.95);
    p.quadraticBezierTo(size.width * 0.45, size.height * 0.75,
        size.width * 0.1, size.height * 0.35);
    p.quadraticBezierTo(size.width * 0.35, size.height * 0.1,
        size.width * 0.5, 0);
    canvas.drawPath(p, paint);

    final vein = Path();
    vein.moveTo(size.width * 0.5, size.height * 0.1);
    vein.quadraticBezierTo(size.width * 0.55, size.height * 0.5,
        size.width * 0.52, size.height * 0.85);
    canvas.drawPath(vein, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 🥕 Carrot
class _CarrotPainter extends CustomPainter {
  _CarrotPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final body = Path();
    body.moveTo(size.width * 0.18, size.height * 0.18);
    body.lineTo(size.width * 0.78, size.height * 0.38);
    body.lineTo(size.width * 0.38, size.height * 0.90);
    body.close();
    canvas.drawPath(body, stroke);

    final leaf1 = Path();
    leaf1.moveTo(size.width * 0.20, size.height * 0.16);
    leaf1.quadraticBezierTo(size.width * 0.05, size.height * 0.02,
        size.width * 0.26, size.height * 0.10);
    canvas.drawPath(leaf1, stroke);

    final leaf2 = Path();
    leaf2.moveTo(size.width * 0.28, size.height * 0.14);
    leaf2.quadraticBezierTo(size.width * 0.18, size.height * -0.06,
        size.width * 0.36, size.height * 0.09);
    canvas.drawPath(leaf2, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}