import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:intra/opinion_arena_faceid_screen.dart';
import 'package:intra/opinion_arena_pin_screen.dart';

class OpinionArenaLoginScreen extends StatefulWidget {
  const OpinionArenaLoginScreen({super.key});

  @override
  State<OpinionArenaLoginScreen> createState() => _OpinionArenaLoginScreenState();
}

class _OpinionArenaLoginScreenState extends State<OpinionArenaLoginScreen> {
  bool _obscurePassword = true;
  bool _loginLoading = false;

  final LocalAuthentication _auth = LocalAuthentication();

  /// Returns the best [BiometricType] the device supports, or null if none.
  Future<BiometricType?> _detectBiometric() async {
    final bool deviceSupported = await _auth.isDeviceSupported();
    if (!deviceSupported) return null;

    final bool canCheck = await _auth.canCheckBiometrics;
    if (!canCheck) return null;

    final List<BiometricType> available =
        await _auth.getAvailableBiometrics();

    // Face ID / face recognition
    if (available.contains(BiometricType.face)) return BiometricType.face;

    // Explicit fingerprint (older Android / iOS Touch ID)
    if (available.contains(BiometricType.fingerprint)) {
      return BiometricType.fingerprint;
    }

    // Android API 30+ reports generic strong/weak instead of fingerprint
    if (available.contains(BiometricType.strong) ||
        available.contains(BiometricType.weak)) {
      return BiometricType.fingerprint;
    }

    return null;
  }

  Future<void> _onLoginPressed() async {
    setState(() => _loginLoading = true);
    try {
      final BiometricType? type = await _detectBiometric();
      if (!mounted) return;

      if (type != null) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => OpinionArenaFaceIdScreen(biometricType: type),
          ),
        );
      } else {
        // No biometrics on this device – skip straight to PIN setup.
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const OpinionArenaPinScreen(),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loginLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool compact = width < 390;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF7A45D8), Color(0xFFE4528C)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 75),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.fromLTRB(25, 10, 25, 26),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCC7E4),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: SizedBox(
                          width: compact ? 100 : 106,
                          height: compact ? 100 : 106,
                          child: Image.asset(
                            'assets/images/header_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'OpinionArena',
                          style: GoogleFonts.epilogue(
                            color: const Color(0xFF1D1B2A),
                            fontSize: compact ? 24 : 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Hello!',
                        style: GoogleFonts.epilogue(
                          color: const Color(0xFF1B1A29),
                          fontSize: compact ? 25 : 27,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                      Text(
                        'Please enter your details to continue',
                        style: GoogleFonts.epilogue(
                          color: const Color(0xFF5E5974),
                          fontSize: compact ? 12 : 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _FieldLabel(text: 'Email', compact: compact),
                      const SizedBox(height: 8),
                      _RoundedInput(
                        hint: 'Enter your email',
                        compact: compact,
                        prefix: const Icon(Icons.mail_outline, color: Color(0xFF6A6F85)),
                      ),
                      const SizedBox(height: 14),
                      _FieldLabel(text: 'Password', compact: compact),
                      const SizedBox(height: 8),
                      _RoundedInput(
                        hint: 'Enter your password',
                        compact: compact,
                        obscureText: _obscurePassword,
                        prefix: const Icon(Icons.lock_outline, color: Color(0xFF6A6F85)),
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF6A6F85),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          Text(
                            'Forgot your password?',
                            style: GoogleFonts.epilogue(
                              color: const Color(0xFF56506A),
                              fontSize: compact ? 13 : 15,
                              letterSpacing: 0.1
                            ),
                          ),
                          const SizedBox(width: 6),
                          DecoratedBox(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF242031), width: 1),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 0),
                              child: Text(
                                'Get a new one here',
                                style: GoogleFonts.epilogue(
                                  color: const Color(0xFF242031),
                                  fontSize: compact ? 13 : 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _loginLoading ? null : _onLoginPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE63A42),
                            disabledBackgroundColor:
                                const Color(0xFFE63A42).withOpacity(0.55),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 5,
                            shadowColor: const Color(0xFFE63A42).withOpacity(0.35),
                          ),
                          child: _loginLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'LOG IN',
                                  style: GoogleFonts.epilogue(
                                    color: Colors.white,
                                    fontSize: compact ? 18 : 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          const Expanded(child: Divider(color: Color.fromARGB(255, 255, 255, 255), thickness: 2,)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                              'OR',
                              style: GoogleFonts.epilogue(
                                color: const Color(0xFF706B83),
                                fontSize: compact ? 14 : 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color.fromARGB(255, 255, 255, 255), thickness: 2,)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _SocialButton(
                        compact: compact,
                        label: 'Sign in with Google',
                        background: Colors.white,
                        textColor: const Color(0xFF222030),
                        icon: const _GoogleIcon(),
                      ),
                      const SizedBox(height: 12),
                      _SocialButton(
                        compact: compact,
                        label: 'Sign in with Facebook',
                        background: const Color(0xFF4569D8),
                        textColor: Colors.white,
                        icon: const _FacebookIcon(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'No user account yet?',
                            style: GoogleFonts.epilogue(
                              color: const Color(0xFF57526A),
                              fontSize: compact ? 13 : 15,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          DecoratedBox(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Color(0xFF222030), width: 1),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 0),
                              child: Text(
                                'Register Here',
                                style: GoogleFonts.epilogue(
                                  color: const Color(0xFF222030),
                                  fontWeight: FontWeight.w700,
                                  fontSize: compact ? 13 : 15,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Are you ready to influence the world for a better future? Your opinion matters!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.epilogue(
                      color: Colors.white,
                      fontSize: compact ? 25 : 27,
                      fontWeight: FontWeight.w800,
                      height: 1.06,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF4F4F4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.15),
                      ),
                      child: Text(
                        'LOGIN AND START EARNING',
                        style: GoogleFonts.epilogue(
                          color: const Color(0xFFE63A42),
                          fontSize: compact ? 14 : 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 42),
                _FooterLink(label: 'Terms', compact: compact),
                _FooterLink(label: 'Privacy Policy', compact: compact),
                _FooterLink(label: 'FAQ', compact: compact),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text.rich(
                    TextSpan(
                      text: 'OpinionArena is a registered trademark of ',
                      style: GoogleFonts.epilogue(
                        color: const Color(0xFFEDDFF4),
                        fontSize: compact ? 9 : 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                      children: <InlineSpan>[
                        TextSpan(
                          text: 'Intra Research',
                          style: GoogleFonts.epilogue(
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFFEDDFF4),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Google "G" icon ──────────────────────────────────────────────────────────
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.width / 2;
    final Offset c = Offset(r, r);
    // Thinner stroke = more faithful G shape
    final double sw = r * 0.28;
    final double arcR = r - sw / 2;
    const double deg = math.pi / 180;

    Paint p(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.butt;

    final Rect rect = Rect.fromCircle(center: c, radius: arcR);

    // Blue:   top → right center (-90° → 0°, 90° span)
    canvas.drawArc(rect, -90 * deg,  90 * deg, false, p(const Color(0xFF4285F4)));
    // Gap:    0° → 28° — the G mouth (no arc drawn here)
    // Red:    28° → 130° (102° span)
    canvas.drawArc(rect,  28 * deg, 102 * deg, false, p(const Color(0xFFEA4335)));
    // Yellow: 130° → 200° (70° span)
    canvas.drawArc(rect, 130 * deg,  70 * deg, false, p(const Color(0xFFFBBC05)));
    // Green:  200° → 270° (70° span, closes back to blue)
    canvas.drawArc(rect, 200 * deg,  70 * deg, false, p(const Color(0xFF34A853)));

    // White hollow
    canvas.drawCircle(c, arcR - sw / 2 - 0.5, Paint()..color = Colors.white);

    // Blue crossbar: horizontal, from canvas centre to outer ring edge at 0°
    final double barH = sw * 0.9;
    canvas.drawRect(
      Rect.fromLTWH(r, r - barH / 2, r, barH),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Facebook "f" icon ────────────────────────────────────────────────────────
class _FacebookIcon extends StatelessWidget {
  const _FacebookIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'f',
        style: GoogleFonts.epilogue(
          color: const Color(0xFF4569D8),
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, required this.compact});

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.epilogue(
        color: const Color(0xFF69657D),
        fontSize: compact ? 14 : 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}

class _RoundedInput extends StatelessWidget {
  const _RoundedInput({
    required this.hint,
    required this.compact,
    this.prefix,
    this.suffix,
    this.obscureText = false,
  });

  final String hint;
  final bool compact;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      textAlignVertical: TextAlignVertical.center,
      style: GoogleFonts.epilogue(
        color: const Color(0xFF232032),
        fontSize: compact ? 17 : 18,
        letterSpacing: 0,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F7),
        hintText: hint,
        hintStyle: GoogleFonts.epilogue(
          color: const Color(0xFF757A91),
          fontSize: compact ? 15 : 17,
          letterSpacing: 0,
        ),
        prefixIcon: prefix,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCDC8DC), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFADA5C4), width: 1.5),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.compact,
    required this.label,
    required this.background,
    required this.textColor,
    required this.icon,
  });

  final bool compact;
  final String label;
  final Color background;
  final Color textColor;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.10),
          backgroundColor: background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.epilogue(
                color: textColor,
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.compact});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        label,
        style: GoogleFonts.epilogue(
          color: Colors.white,
          fontSize: compact ? 17 : 19,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
