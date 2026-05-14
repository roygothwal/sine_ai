import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:sine_ai/core/routing/route_names.dart';
import 'dart:typed_data';

// ═══════════════════════════════════════════════
//  SINE AI — PRO SPLASH SCREEN
//  Psychology-timed • Zero jank • Unique FX
// ═══════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _masterCtrl;   
  late AnimationController _breathCtrl;   
  late AnimationController _rotCtrl;      
  late AnimationController _waveCtrl;     
  late AnimationController _textCtrl;     
  late AnimationController _glintCtrl;    

  late final List<_ExplosionParticle> _explosionParticles;
  late final List<_OrbitRing>         _orbitRings;
  late final List<_StarDot>           _stars;
  late final List<_NebulaCloud>       _nebulae;
  late final List<_HelixParticle>     _helix;

  double _masterT   = 0;
  double _breathT   = 0;
  double _rotT      = 0;
  double _waveT     = 0;
  double _textT     = 0;
  double _glintT    = 0;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:            Colors.transparent,
      statusBarIconBrightness:   Brightness.light,
      systemNavigationBarColor:  Colors.black,
    ));

    _explosionParticles = List.generate(350, (i) => _ExplosionParticle(i));
    _orbitRings         = List.generate(5,   (i) => _OrbitRing(i));
    _stars              = List.generate(220, (i) => _StarDot(i));
    _nebulae            = List.generate(8,   (i) => _NebulaCloud(i));
    _helix              = List.generate(120, (i) => _HelixParticle(i));

    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..addListener(() => setState(() => _masterT = _masterCtrl.value))
     ..forward();

    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addListener(() => setState(() => _breathT = _breathCtrl.value))
     ..repeat(reverse: true);

    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..addListener(() => setState(() => _rotT = _rotCtrl.value))
     ..repeat();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..addListener(() => setState(() => _waveT = _waveCtrl.value))
     ..repeat();

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addListener(() => setState(() => _textT = _textCtrl.value));

    Future.delayed(const Duration(milliseconds: 3400), () {
      if (mounted) _textCtrl.forward();
    });

    _glintCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addListener(() => setState(() => _glintT = _glintCtrl.value));

    Future.delayed(const Duration(milliseconds: 4200), () {
      if (mounted) _glintCtrl.repeat();
    });

    Future.delayed(const Duration(milliseconds: 6600), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      context.go(RouteNames.login);
    } else {
      context.go(RouteNames.home);
    }
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    _breathCtrl.dispose();
    _rotCtrl.dispose();
    _waveCtrl.dispose();
    _textCtrl.dispose();
    _glintCtrl.dispose();
    super.dispose();
  }

  double _phase(double start, double end) =>
      ((_masterT - start) / (end - start)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final silenceP    = _phase(0.000, 0.120); 
    final dotP        = _phase(0.080, 0.280); 
    final breathP     = _phase(0.200, 0.380); 
    final bangP       = _phase(0.320, 0.520); 
    final settleP     = _phase(0.500, 0.700); 
    final ringsP      = _phase(0.420, 0.680); 
    final helixP      = _phase(0.480, 0.720); 
    final waveP       = _phase(0.580, 0.820); 
    final nebulaeP    = _phase(0.300, 0.600); 

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _DeepSpaceBg(masterT: _masterT, silenceP: silenceP),
          if (nebulaeP > 0)
            CustomPaint(
              size: size,
              painter: _NebulaPainter(_nebulae, nebulaeP, _waveT),
            ),
          CustomPaint(
            size: size,
            painter: _StarPainter(_stars, _masterT, _waveT),
          ),
          if (bangP > 0)
            CustomPaint(
              size: size,
              painter: _ExplosionPainter(
                _explosionParticles, bangP, settleP, size,
              ),
            ),
          if (helixP > 0)
            CustomPaint(
              size: size,
              painter: _HelixPainter(_helix, helixP, _waveT, size),
            ),
          if (ringsP > 0)
            CustomPaint(
              size: size,
              painter: _OrbitRingPainter(_orbitRings, ringsP, _rotT),
            ),
          if (waveP > 0)
            CustomPaint(
              size: size,
              painter: _SineWavePainter(_waveT, waveP, size),
            ),
          Center(
            child: _CoreWidget(
              dotP:       dotP,
              breathP:    breathP,
              bangP:      bangP,
              breathT:    _breathT,
              size:       size,
            ),
          ),
          if (_textT > 0)
            Center(
              child: _BrandText(
                textT:  _textT,
                glintT: _glintT,
                waveT:  _waveT,
              ),
            ),
          if (_textT > 0.3)
            _ChromaticLayer(textT: _textT),
          const _Vignette(),
        ],
      ),
    );
  }
}

class _DeepSpaceBg extends StatelessWidget {
  final double masterT;
  final double silenceP;
  const _DeepSpaceBg({required this.masterT, required this.silenceP});

  @override
  Widget build(BuildContext context) {
    final colorT = (masterT * 2.5).clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.8,
          colors: [
            Color.lerp(Colors.black, const Color(0xFF0D0020), colorT)!,
            Color.lerp(Colors.black, const Color(0xFF080018), colorT)!,
            Color.lerp(Colors.black, const Color(0xFF030010), colorT)!,
            Colors.black,
          ],
          stops: const [0.0, 0.3, 0.6, 1.0],
        ),
      ),
    );
  }
}

class _CoreWidget extends StatelessWidget {
  final double dotP, breathP, bangP, breathT;
  final Size size;

  const _CoreWidget({
    required this.dotP,
    required this.breathP,
    required this.bangP,
    required this.breathT,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (dotP == 0) return const SizedBox.shrink();

    final birthSize = Curves.elasticOut.transform(
      dotP.clamp(0.0, 1.0),
    ) * 22.0;

    final breathScale = 1.0 + (Curves.easeInOut.transform(breathT)) * 0.18
        * breathP;

    final coreSize = (birthSize * breathScale).clamp(0.0, 26.0);

    final explodeFade = bangP > 0.6
        ? (1.0 - ((bangP - 0.6) / 0.4)).clamp(0.0, 1.0)
        : 1.0;

    final glowRadius = coreSize * (2.2 + breathT * 0.6);

    return Opacity(
      opacity: explodeFade,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width:  glowRadius * 4,
            height: glowRadius * 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF7C3AED).withValues(
                    alpha: 0.25 * breathP * explodeFade,
                  ),
                  const Color(0xFFEC4899).withValues(
                    alpha: 0.10 * breathP * explodeFade,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width:  glowRadius * 2.2,
            height: glowRadius * 2.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(
                    alpha: 0.55 * explodeFade,
                  ),
                  blurRadius: glowRadius * 1.5,
                  spreadRadius: glowRadius * 0.3,
                ),
              ],
            ),
          ),
          Container(
            width:  coreSize,
            height: coreSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: const [
                  Colors.white,
                  Color(0xFF7C3AED),
                  Color(0xFFEC4899),
                  Color(0xFF06B6D4),
                  Colors.white,
                ],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                transform: GradientRotation(breathT * pi * 2),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.9),
                  blurRadius: 28,
                  spreadRadius: 8,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          Positioned(
            top: coreSize * 0.12,
            left: coreSize * 0.22,
            child: Container(
              width:  coreSize * 0.28,
              height: coreSize * 0.18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.7 * dotP),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandText extends StatelessWidget {
  final double textT, glintT, waveT;
  const _BrandText({
    required this.textT,
    required this.glintT,
    required this.waveT,
  });

  @override
  Widget build(BuildContext context) {
    final slide  = Curves.easeOutExpo.transform(textT);
    final glintX = (glintT * 1.6) % 1.6 - 0.3;

    return Transform.translate(
      offset: Offset(0, 40 * (1 - slide)),
      child: Opacity(
        opacity: (textT * 1.5).clamp(0.0, 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
                stops: [
                  (glintX - 0.25).clamp(0.0, 1.0),
                  glintX.clamp(0.0, 1.0),
                  (glintX + 0.25).clamp(0.0, 1.0),
                ],
                colors: [
                  Colors.white.withValues(alpha: 0.75),
                  Colors.white,
                  Colors.white.withValues(alpha: 0.75),
                ],
              ).createShader(bounds),
              child: Text(
                'SINE AI',
                style: GoogleFonts.outfit(
                  fontSize:     60,
                  fontWeight:   FontWeight.w900,
                  letterSpacing: 12,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color:      const Color(0xFF7C3AED).withValues(alpha: 0.9),
                      blurRadius: 35,
                    ),
                    Shadow(
                      color:      const Color(0xFFEC4899).withValues(alpha: 0.5),
                      blurRadius: 70,
                    ),
                    Shadow(
                      color:      const Color(0xFF06B6D4).withValues(alpha: 0.3),
                      blurRadius: 100,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),

            TweenAnimationBuilder<double>(
              tween:    Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              builder: (_, v, __) => Container(
                width:  160 * v,
                height: 0.8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF7C3AED).withValues(alpha: 0.8),
                      const Color(0xFFEC4899).withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'BEYOND INTELLIGENCE',
              style: GoogleFonts.outfit(
                fontSize:      11,
                fontWeight:    FontWeight.w300,
                letterSpacing: 8,
                color: Colors.white.withValues(alpha: 0.55 * textT),
              ),
            ),

            const SizedBox(height: 36),

            _ProLoader(waveT: waveT, textT: textT),
          ],
        ),
      ),
    );
  }
}

class _ProLoader extends StatelessWidget {
  final double waveT, textT;
  const _ProLoader({required this.waveT, required this.textT});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 20,
      child: CustomPaint(
        painter: _LoaderPainter(waveT, textT),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  final double waveT, textT;
  _LoaderPainter(this.waveT, this.textT);

  @override
  void paint(Canvas canvas, Size size) {
    const dotCount = 5;
    final spacing  = size.width / (dotCount - 1);

    for (int i = 0; i < dotCount; i++) {
      final phase  = ((waveT - i * 0.18) % 1.0);
      final bounce = sin(phase * pi * 2) * 0.5 + 0.5;
      final radius = (2.5 + bounce * 2.5) * textT;
      final alpha  = (0.3 + bounce * 0.7) * textT;

      final color = Color.lerp(
        const Color(0xFF7C3AED),
        const Color(0xFFEC4899),
        i / (dotCount - 1),
      )!;

      final paint = Paint()
        ..color = color.withValues(alpha: alpha.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      final glowPaint = Paint()
        ..color  = color.withValues(alpha: alpha * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final offset = Offset(i * spacing, size.height / 2);
      canvas.drawCircle(offset, radius + 3, glowPaint);
      canvas.drawCircle(offset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_LoaderPainter old) => true;
}

class _ChromaticLayer extends StatelessWidget {
  final double textT;
  const _ChromaticLayer({required this.textT});

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final spread = (1.0 - textT) * 6;

    if (spread < 0.1) return const SizedBox.shrink();

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: -spread,
            top:  0,
            child: Opacity(
              opacity: 0.08 * (1 - textT),
              child: Container(
                width:  size.width,
                height: size.height,
                color: Colors.red.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            left: spread,
            top:  0,
            child: Opacity(
              opacity: 0.08 * (1 - textT),
              child: Container(
                width:  size.width,
                height: size.height,
                color: Colors.blue.withValues(alpha: 0.15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.55),
              Colors.black.withValues(alpha: 0.85),
            ],
            stops: const [0.45, 0.75, 1.0],
          ),
        ),
      ),
    );
  }
}

class _ExplosionParticle {
  final double angle;
  final double speed;
  final double size;
  final Color  color;
  final double opacity;
  final double trailLen;
  final double spiralFactor;

  _ExplosionParticle(int seed)
      : angle         = Random(seed).nextDouble() * pi * 2,
        speed         = Random(seed + 1).nextDouble() * 0.45 + 0.08,
        size          = Random(seed + 2).nextDouble() * 3.2 + 0.5,
        color         = _pick(seed),
        opacity       = Random(seed + 4).nextDouble() * 0.65 + 0.35,
        trailLen      = Random(seed + 5).nextDouble() * 0.35 + 0.08,
        spiralFactor  = Random(seed + 6).nextDouble() * 0.6 - 0.3;

  static Color _pick(int seed) {
    const palette = [
      Color(0xFF7C3AED), Color(0xFFEC4899), Color(0xFF06B6D4),
      Color(0xFFA855F7), Color(0xFFE879F9), Color(0xFF38BDF8),
      Colors.white,      Color(0xFFFDE68A),
    ];
    return palette[Random(seed).nextInt(palette.length)];
  }
}

class _OrbitRing {
  final double radius;
  final double tiltX;
  final double tiltZ;
  final double speed;
  final Color  color;
  final double width;

  _OrbitRing(int i)
      : radius = 60.0  + i * 28.0,
        tiltX  = 0.2   + i * 0.15,
        tiltZ  = i     * 0.4,
        speed  = 1.0   + i * 0.3,
        color  = [
          const Color(0xFF7C3AED),
          const Color(0xFFEC4899),
          const Color(0xFF06B6D4),
          const Color(0xFFA855F7),
          const Color(0xFF38BDF8),
        ][i % 5],
        width  = 1.2   - i * 0.15;
}

class _StarDot {
  final double x, y, size, brightness, twinkleOffset;
  _StarDot(int seed)
      : x              = Random(seed).nextDouble(),
        y              = Random(seed + 1).nextDouble(),
        size           = Random(seed + 2).nextDouble() * 1.6 + 0.2,
        brightness     = Random(seed + 3).nextDouble() * 0.55 + 0.2,
        twinkleOffset  = Random(seed + 4).nextDouble();
}

class _NebulaCloud {
  final double x, y, radius, opacity;
  final Color  color;

  _NebulaCloud(int seed)
      : x       = Random(seed).nextDouble(),
        y       = Random(seed + 1).nextDouble(),
        radius  = Random(seed + 2).nextDouble() * 120 + 60,
        opacity = Random(seed + 3).nextDouble() * 0.08 + 0.03,
        color   = [
          const Color(0xFF7C3AED),
          const Color(0xFFEC4899),
          const Color(0xFF06B6D4),
          const Color(0xFF4F46E5),
        ][Random(seed).nextInt(4)];
}

class _HelixParticle {
  final double offset;
  final double strand;   
  final double speed;
  final Color  color;
  final double size;

  _HelixParticle(int seed)
      : offset = Random(seed).nextDouble(),
        strand = (seed % 2).toDouble(),
        speed  = Random(seed + 1).nextDouble() * 0.4 + 0.6,
        color  = seed % 2 == 0
            ? const Color(0xFF7C3AED)
            : const Color(0xFF06B6D4),
        size   = Random(seed + 2).nextDouble() * 2.0 + 1.0;
}

class _NebulaPainter extends CustomPainter {
  final List<_NebulaCloud> clouds;
  final double phase, waveT;
  _NebulaPainter(this.clouds, this.phase, this.waveT);

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in clouds) {
      final alpha  = c.opacity * phase *
          (0.8 + sin(waveT * pi * 2 + c.x * 10) * 0.2);
      final paint  = Paint()
        ..color     = c.color.withValues(alpha: alpha.clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, c.radius * 0.7);

      canvas.drawCircle(
        Offset(c.x * size.width, c.y * size.height),
        c.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_NebulaPainter old) => true;
}

class _StarPainter extends CustomPainter {
  final List<_StarDot> stars;
  final double masterT, waveT;
  _StarPainter(this.stars, this.masterT, this.waveT);

  @override
  void paint(Canvas canvas, Size size) {
    final appear = (masterT * 5).clamp(0.0, 1.0);
    if (appear == 0) return;

    final paint = Paint()..style = PaintingStyle.fill;

    for (final s in stars) {
      final twinkle = sin(waveT * pi * 2 + s.twinkleOffset * pi * 6) * 0.25;
      final alpha   = ((s.brightness + twinkle) * appear).clamp(0.0, 1.0);

      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => true;
}

class _ExplosionPainter extends CustomPainter {
  final List<_ExplosionParticle> particles;
  final double bangP, settleP;
  final Size   screenSize;

  _ExplosionPainter(this.particles, this.bangP, this.settleP, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (bangP == 0) return;

    final cx      = size.width  / 2;
    final cy      = size.height / 2;
    final maxDist = size.width  * 0.65;
    final eased   = Curves.easeOutCubic.transform(bangP);
    final fadeOut = (1.0 - settleP * 1.2).clamp(0.0, 1.0);

    for (final p in particles) {
      final dist = eased * maxDist * p.speed;

      final spiralAngle = p.angle + p.spiralFactor * eased * 0.8;
      final x = cx + cos(spiralAngle) * dist;
      final y = cy + sin(spiralAngle) * dist;

      final alpha = p.opacity * fadeOut * eased;
      if (alpha <= 0.01) continue;

      final trailDist = dist * (1 - p.trailLen);
      final tx = cx + cos(spiralAngle) * trailDist;
      final ty = cy + sin(spiralAngle) * trailDist;

      final trailPaint = Paint()
        ..color      = p.color.withValues(alpha: (alpha * 0.35).clamp(0.0, 1.0))
        ..strokeWidth = p.size * 0.6
        ..strokeCap  = StrokeCap.round
        ..style      = PaintingStyle.stroke;

      canvas.drawLine(Offset(tx, ty), Offset(x, y), trailPaint);

      final glowPaint = Paint()
        ..color      = p.color.withValues(alpha: (alpha * 0.3).clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 2);
      canvas.drawCircle(Offset(x, y), p.size * 2, glowPaint);

      final dotPaint = Paint()
        ..color = p.color.withValues(alpha: alpha.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), p.size, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ExplosionPainter old) => true;
}

class _OrbitRingPainter extends CustomPainter {
  final List<_OrbitRing> rings;
  final double ringsP, rotT;
  _OrbitRingPainter(this.rings, this.ringsP, this.rotT);

  @override
  void paint(Canvas canvas, Size size) {
    if (ringsP == 0) return;

    final cx = size.width  / 2;
    final cy = size.height / 2;

    for (int i = 0; i < rings.length; i++) {
      final r       = rings[i];
      final appear  = ((ringsP - i * 0.12) / 0.4).clamp(0.0, 1.0);
      if (appear == 0) continue;

      final alpha   = appear * 0.6;
      final rotAngle = rotT * pi * 2 * r.speed + i * 0.8;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.transform(_tiltMatrix(r.tiltX, r.tiltZ + rotAngle));

      final paint = Paint()
        ..color      = r.color.withValues(alpha: alpha)
        ..strokeWidth = r.width.clamp(0.2, 2.0)
        ..style      = PaintingStyle.stroke;

      final glowPaint = Paint()
        ..color      = r.color.withValues(alpha: alpha * 0.3)
        ..strokeWidth = r.width * 4
        ..style      = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width:  r.radius * 2,
          height: r.radius * 0.55,
        ),
        glowPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width:  r.radius * 2,
          height: r.radius * 0.55,
        ),
        paint,
      );

      final dotAngle = rotAngle * 2;
      final rx = r.radius        * cos(dotAngle);
      final ry = r.radius * 0.275 * sin(dotAngle);

      final dotPaint = Paint()
        ..color = r.color.withValues(alpha: appear)
        ..style = PaintingStyle.fill;
      final dotGlow = Paint()
        ..color      = r.color.withValues(alpha: appear * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(Offset(rx, ry), 5, dotGlow);
      canvas.drawCircle(Offset(rx, ry), 2.5, dotPaint);

      canvas.restore();
    }
  }

  Float64List _tiltMatrix(double tiltX, double rotZ) {
    final cosX = cos(tiltX);
    final sinX = sin(tiltX);
    final cosZ = cos(rotZ);
    final sinZ = sin(rotZ);

    return Float64List.fromList([
      cosZ,         sinZ * cosX,  sinZ * sinX,  0,
      -sinZ,        cosZ * cosX,  cosZ * sinX,  0,
      0,            -sinX,        cosX,          0,
      0,            0,            0,             1,
    ]);
  }

  @override
  bool shouldRepaint(_OrbitRingPainter old) => true;
}

class _HelixPainter extends CustomPainter {
  final List<_HelixParticle> particles;
  final double helixP, waveT;
  final Size   screenSize;

  _HelixPainter(this.particles, this.helixP, this.waveT, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (helixP == 0) return;

    final cx = size.width  / 2;
    final cy = size.height / 2;

    for (final p in particles) {
      final t     = ((p.offset + waveT * p.speed) % 1.0);
      final angle = t * pi * 6 + (p.strand == 0 ? 0 : pi);

      final spread  = 80.0 * helixP;
      final x       = cx + cos(angle) * spread;
      final y       = cy + (t - 0.5) * size.height * 0.7;

      final depth  = sin(angle) * 0.5 + 0.5;
      final alpha  = depth * 0.7 * helixP;

      if (alpha < 0.01) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      final glowPaint = Paint()
        ..color      = p.color.withValues(alpha: (alpha * 0.3).clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 2);

      canvas.drawCircle(Offset(x, y), p.size * depth + 2, glowPaint);
      canvas.drawCircle(Offset(x, y), p.size * depth, paint);
    }
  }

  @override
  bool shouldRepaint(_HelixPainter old) => true;
}

class _SineWavePainter extends CustomPainter {
  final double waveT, waveP;
  final Size   screenSize;
  _SineWavePainter(this.waveT, this.waveP, this.screenSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (waveP == 0) return;

    final cy        = size.height * 0.73;
    final amplitude = 22.0 * waveP;
    final speed     = waveT * pi * 4;

    const layers = [
      [Color(0xFF7C3AED), 2.5, 0.0,  0.85],
      [Color(0xFFEC4899), 1.8, 0.9,  0.60],
      [Color(0xFF06B6D4), 1.2, 1.8,  0.40],
    ];

    for (final layer in layers) {
      final color    = layer[0] as Color;
      final width    = layer[1] as double;
      final phShift  = layer[2] as double;
      final opacity  = layer[3] as double;

      final glowPaint = Paint()
        ..color      = color.withValues(alpha: opacity * waveP * 0.35)
        ..strokeWidth = width * 3.5
        ..strokeCap  = StrokeCap.round
        ..style      = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      final linePaint = Paint()
        ..color      = color.withValues(alpha: opacity * waveP)
        ..strokeWidth = width
        ..strokeCap  = StrokeCap.round
        ..style      = PaintingStyle.stroke;

      final path = Path();
      bool first = true;

      for (double x = 0; x <= size.width; x += 1.5) {
        final y = cy
            + sin(x * 0.018 + speed + phShift) * amplitude
            + sin(x * 0.040 - speed * 0.6 + phShift) * (amplitude * 0.35)
            + sin(x * 0.008 + speed * 0.3)            * (amplitude * 0.2);

        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(_SineWavePainter old) => true;
}
