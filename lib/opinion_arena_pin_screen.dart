import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, LengthLimitingTextInputFormatter, SystemChannels, TextInputFormatter;
import 'package:intra/models/oa_user.dart';
import 'package:intra/opinion_arena_home_screen.dart';
import 'package:intra/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class OpinionArenaPinScreen extends StatefulWidget {
  const OpinionArenaPinScreen({super.key, required this.user});

  final OAUser user;

  @override
  State<OpinionArenaPinScreen> createState() => _OpinionArenaPinScreenState();
}

class _OpinionArenaPinScreenState extends State<OpinionArenaPinScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 4;

  _PinStep _step = _PinStep.enter;

  String _pin = '';
  String _firstPin = '';
  bool _saving = false;
  String? _errorMessage;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Open keyboard automatically when screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_saving) return;
    final String value = _controller.text;
    setState(() {
      _pin = value;
      _errorMessage = null;
    });
    if (value.length == _pinLength) {
      _handleComplete();
    }
  }

  Future<void> _handleComplete() async {
    if (_step == _PinStep.enter) {
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _step = _PinStep.confirm;
      });
      _controller.clear();
      _focusNode.requestFocus();
    } else {
      if (_pin != _firstPin) {
        await _shakeController.forward(from: 0);
        _shakeController.reset(); // snap back to centre (value → 0)
        setState(() {
          _pin = '';
          _errorMessage = "PINs don't match. Try again.";
        });
        _controller.clear();
        _focusNode.requestFocus();
        return;
      }
      setState(() => _saving = true);
      _focusNode.unfocus();
      try {
        await AuthService.savePin(_pin);
        // Only now is setup complete — persist the token so future launches
        // go through the PIN/biometric screen instead of the login screen.
        final String? token = widget.user.accessToken;
        if (token != null) await AuthService.saveToken(token);
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => OpinionArenaHomeScreen(user: widget.user),
          ),
          (Route<dynamic> route) => false,
        );
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool compact = width < 390;

    final String title =
        _step == _PinStep.enter ? 'Set Your PIN' : 'Confirm Your PIN';
    final String subtitle = _step == _PinStep.enter
        ? 'Choose a 4-digit PIN as a\nbackup login method.'
        : 'Re-enter your PIN to confirm.';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFE4528C),
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
                  padding: const EdgeInsets.fromLTRB(25, 10, 25, 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCC7E4),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Column(
                    children: <Widget>[
                      // ── Logo ──────────────────────────────────────────
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

                      // ── Lock icon ──────────────────────────────────────
                      Container(
                        width: compact ? 72 : 82,
                        height: compact ? 72 : 82,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFCDC8DC),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.pin_outlined,
                          size: compact ? 40 : 46,
                          color: const Color(0xFF7A45D8),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── Title / subtitle ───────────────────────────────
                      Text(
                        title,
                        style: GoogleFonts.epilogue(
                          color: const Color(0xFF1B1A29),
                          fontSize: compact ? 20 : 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.epilogue(
                          color: const Color(0xFF5E5974),
                          fontSize: compact ? 13 : 14,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── PIN dots + hidden text field ───────────────────
                      // Tap the dots to re-open the keyboard if dismissed
                      GestureDetector(
                        onTap: () {
                          if (_focusNode.hasFocus) {
                            // Already focused but keyboard was dismissed —
                            // explicitly tell the system to show it again.
                            SystemChannels.textInput
                                .invokeMethod<void>('TextInput.show');
                          } else {
                            _focusNode.requestFocus();
                          }
                        },
                        child: AnimatedBuilder(
                          animation: _shakeAnim,
                          builder: (BuildContext context, Widget? child) {
                            final double t = _shakeAnim.value;
                            final double shake =
                                (t * 3).round() % 2 == 0 ? -8 * t : 8 * t;
                            return Transform.translate(
                              offset: Offset(shake * 4, 0),
                              child: child,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                List<Widget>.generate(_pinLength, (int i) {
                              final bool filled = i < _pin.length;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                width: compact ? 18 : 20,
                                height: compact ? 18 : 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: filled
                                      ? const Color(0xFF7A45D8)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: filled
                                        ? const Color(0xFF7A45D8)
                                        : const Color(0xFFADA5C4),
                                    width: 2,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),

                      // Hidden text field — captures device keyboard input
                      SizedBox(
                        height: 0,
                        child: OverflowBox(
                          maxHeight: 48,
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: _pinLength,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(_pinLength),
                            ],
                            style: const TextStyle(
                              color: Colors.transparent,
                              fontSize: 1,
                            ),
                            cursorColor: Colors.transparent,
                            cursorWidth: 0,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                            ),
                            enabled: !_saving,
                          ),
                        ),
                      ),

                      // ── Error message ──────────────────────────────────
                      AnimatedSize(
                        duration: const Duration(milliseconds: 180),
                        child: _errorMessage != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: Text(
                                  _errorMessage!,
                                  style: GoogleFonts.epilogue(
                                    color: const Color(0xFFE63A42),
                                    fontSize: compact ? 12 : 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 10),
                      Text(
                        'Tap the dots to open the keyboard',
                        style: GoogleFonts.epilogue(
                          color: const Color(0xFF9993AA),
                          fontSize: compact ? 11 : 12,
                          letterSpacing: 0,
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

// ── Step enum ─────────────────────────────────────────────────────────────────
enum _PinStep { enter, confirm }

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
