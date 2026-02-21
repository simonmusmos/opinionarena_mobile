import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:intra/opinion_arena_pin_screen.dart';

/// Stubbed API call – replace with real implementation when the endpoint is ready.
Future<void> _stubEnableBiometric() async {
  // TODO: POST /auth/enable-biometric
  await Future<void>.delayed(const Duration(milliseconds: 800));
}

class OpinionArenaFaceIdScreen extends StatefulWidget {
  const OpinionArenaFaceIdScreen({
    super.key,
    required this.biometricType,
  });

  /// The biometric type detected on this device (face or fingerprint).
  final BiometricType biometricType;

  @override
  State<OpinionArenaFaceIdScreen> createState() =>
      _OpinionArenaFaceIdScreenState();
}

class _OpinionArenaFaceIdScreenState extends State<OpinionArenaFaceIdScreen> {
  bool _loading = false;

  bool get _isFace => widget.biometricType == BiometricType.face;

  String get _title => _isFace ? 'Enable Face ID?' : 'Enable Fingerprint Login?';
  String get _buttonLabel => _isFace ? 'ENABLE FACE ID' : 'ENABLE FINGERPRINT';
  IconData get _biometricIcon =>
      _isFace ? Icons.face_retouching_natural : Icons.fingerprint;

  Future<void> _onEnable() async {
    setState(() => _loading = true);
    try {
      await _stubEnableBiometric();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const OpinionArenaPinScreen(),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSkip() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const OpinionArenaPinScreen(),
      ),
    );
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
                      // ── Logo ────────────────────────────────────────────
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
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Biometric illustration ───────────────────────────
                      Center(
                        child: Container(
                          width: compact ? 88 : 100,
                          height: compact ? 88 : 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F7),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFCDC8DC),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            _biometricIcon,
                            size: compact ? 52 : 60,
                            color: const Color(0xFF7A45D8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Heading ──────────────────────────────────────────
                      Center(
                        child: Text(
                          _title,
                          style: GoogleFonts.epilogue(
                            color: const Color(0xFF1B1A29),
                            fontSize: compact ? 22 : 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _isFace
                              ? 'Log in faster next time with a\nsingle glance — no password needed.'
                              : 'Log in faster next time with a\nquick touch — no password needed.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.epilogue(
                            color: const Color(0xFF5E5974),
                            fontSize: compact ? 13 : 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Benefit chips ────────────────────────────────────
                      _BenefitRow(
                        icon: Icons.bolt_rounded,
                        label: 'Instant access',
                        compact: compact,
                      ),
                      const SizedBox(height: 10),
                      _BenefitRow(
                        icon: Icons.security_rounded,
                        label: 'Secured by your device',
                        compact: compact,
                      ),
                      const SizedBox(height: 10),
                      _BenefitRow(
                        icon: Icons.no_photography_outlined,
                        label: 'No data stored on servers',
                        compact: compact,
                      ),
                      const SizedBox(height: 28),

                      // ── Enable button ────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _onEnable,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE63A42),
                            disabledBackgroundColor:
                                const Color(0xFFE63A42).withOpacity(0.55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 5,
                            shadowColor:
                                const Color(0xFFE63A42).withOpacity(0.35),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _buttonLabel,
                                  style: GoogleFonts.epilogue(
                                    color: Colors.white,
                                    fontSize: compact ? 16 : 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Skip button ──────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                          onPressed: _loading ? null : _onSkip,
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(
                                color: Color(0xFFADA5C4),
                                width: 1.2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Skip for now',
                            style: GoogleFonts.epilogue(
                              color: const Color(0xFF56506A),
                              fontSize: compact ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
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

// ── Benefit row ───────────────────────────────────────────────────────────────
class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.label,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF7A45D8).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF7A45D8)),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.epilogue(
            color: const Color(0xFF1B1A29),
            fontSize: compact ? 13 : 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

// ── Footer link ───────────────────────────────────────────────────────────────
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
