import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, LengthLimitingTextInputFormatter, SystemChannels, TextInputFormatter;
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';

/// Stubbed PIN verification – replace with real API call when ready.
Future<bool> _stubVerifyPin(String pin) async {
  // TODO: POST /auth/verify-pin  { "pin": pin }
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return true; // stub always succeeds
}

/// Stubbed password verification – replace with real API call when ready.
Future<bool> _stubVerifyPassword(String email, String password) async {
  // TODO: POST /auth/login  { "email": email, "password": password }
  await Future<void>.delayed(const Duration(milliseconds: 700));
  return true; // stub always succeeds
}

enum _AuthMode { detecting, biometric, pin, password }

class OpinionArenaAuthScreen extends StatefulWidget {
  const OpinionArenaAuthScreen({super.key});

  @override
  State<OpinionArenaAuthScreen> createState() => _OpinionArenaAuthScreenState();
}

class _OpinionArenaAuthScreenState extends State<OpinionArenaAuthScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 4;
  static const int _maxBiometricAttempts = 3;

  final LocalAuthentication _auth = LocalAuthentication();

  _AuthMode _mode = _AuthMode.detecting;
  BiometricType? _biometricType;
  int _biometricAttempts = 0;
  bool _biometricLoading = false;

  // PIN state
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocus = FocusNode();
  String _pin = '';
  bool _pinVerifying = false;
  String? _pinError;

  // Password state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _passwordLoading = false;
  String? _passwordError;

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

    _pinController.addListener(_onPinChanged);
    _detectAndAuthenticate();
  }

  @override
  void dispose() {
    _pinController.removeListener(_onPinChanged);
    _pinController.dispose();
    _pinFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // ── Biometric detection + auto-prompt ──────────────────────────────────────

  Future<void> _detectAndAuthenticate() async {
    final BiometricType? type = await _detectBiometric();
    if (!mounted) return;

    if (type != null) {
      setState(() {
        _biometricType = type;
        _mode = _AuthMode.biometric;
      });
      // Auto-trigger prompt as soon as the screen appears
      await _triggerBiometric();
    } else {
      _switchToPin();
    }
  }

  Future<BiometricType?> _detectBiometric() async {
    try {
      final bool deviceSupported = await _auth.isDeviceSupported();
      if (!deviceSupported) return null;

      final bool canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return null;

      final List<BiometricType> available =
          await _auth.getAvailableBiometrics();

      if (available.contains(BiometricType.face)) return BiometricType.face;
      if (available.contains(BiometricType.fingerprint)) {
        return BiometricType.fingerprint;
      }
      // Android API 30+ reports strong/weak instead of fingerprint
      if (available.contains(BiometricType.strong) ||
          available.contains(BiometricType.weak)) {
        return BiometricType.fingerprint;
      }
    } catch (_) {}
    return null;
  }

  Future<void> _triggerBiometric() async {
    if (_biometricLoading || !mounted) return;
    setState(() => _biometricLoading = true);
    try {
      final bool success = await _auth.authenticate(
        localizedReason: 'Authenticate to access OpinionArena',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (!mounted) return;
      if (success) {
        _onAuthSuccess();
      } else {
        _biometricAttempts++;
        if (_biometricAttempts >= _maxBiometricAttempts) {
          _switchToPin();
        }
      }
    } catch (_) {
      // Sensor error or not enrolled — fall back to PIN
      if (mounted) _switchToPin();
    } finally {
      if (mounted) setState(() => _biometricLoading = false);
    }
  }

  void _switchToPin() {
    setState(() => _mode = _AuthMode.pin);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocus.requestFocus();
    });
  }

  // ── PIN input ──────────────────────────────────────────────────────────────

  void _onPinChanged() {
    if (_pinVerifying) return;
    final String value = _pinController.text;
    setState(() {
      _pin = value;
      _pinError = null;
    });
    if (value.length == _pinLength) {
      _verifyPin(value);
    }
  }

  Future<void> _verifyPin(String pin) async {
    setState(() => _pinVerifying = true);
    _pinFocus.unfocus();
    try {
      final bool ok = await _stubVerifyPin(pin);
      if (!mounted) return;
      if (ok) {
        _onAuthSuccess();
      } else {
        await _shakeController.forward(from: 0);
        _shakeController.reset();
        setState(() {
          _pin = '';
          _pinError = 'Incorrect PIN. Try again.';
        });
        _pinController.clear();
        _pinFocus.requestFocus();
      }
    } finally {
      if (mounted) setState(() => _pinVerifying = false);
    }
  }

  void _switchToPassword() {
    _pinFocus.unfocus();
    setState(() {
      _mode = _AuthMode.password;
      _passwordError = null;
    });
  }

  Future<void> _loginWithPassword() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _passwordError = 'Please fill in both fields.');
      return;
    }

    setState(() {
      _passwordLoading = true;
      _passwordError = null;
    });
    FocusScope.of(context).unfocus();

    try {
      final bool ok = await _stubVerifyPassword(email, password);
      if (!mounted) return;
      if (ok) {
        _onAuthSuccess();
      } else {
        setState(() => _passwordError = 'Incorrect email or password.');
      }
    } finally {
      if (mounted) setState(() => _passwordLoading = false);
    }
  }

  void _onAuthSuccess() {
    // TODO: navigate to home / dashboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Authenticated!')),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool compact = width < 390;

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
                  child: _mode == _AuthMode.detecting
                      ? _buildDetecting(compact)
                      : _mode == _AuthMode.biometric
                          ? _buildBiometric(compact)
                          : _mode == _AuthMode.pin
                              ? _buildPin(compact)
                              : _buildPassword(compact),
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

  // ── Detecting state ────────────────────────────────────────────────────────
  Widget _buildDetecting(bool compact) {
    return Column(
      children: <Widget>[
        _Logo(compact: compact),
        const SizedBox(height: 40),
        const SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Color(0xFF7A45D8),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Checking authentication...',
          style: GoogleFonts.epilogue(
            color: const Color(0xFF5E5974),
            fontSize: compact ? 13 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Biometric state ────────────────────────────────────────────────────────
  Widget _buildBiometric(bool compact) {
    final bool isFace = _biometricType == BiometricType.face;
    final String label = isFace ? 'Face ID' : 'Fingerprint';
    final IconData icon =
        isFace ? Icons.face_retouching_natural : Icons.fingerprint;

    return Column(
      children: <Widget>[
        _Logo(compact: compact),
        const SizedBox(height: 28),

        // Icon
        Container(
          width: compact ? 88 : 100,
          height: compact ? 88 : 100,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFCDC8DC), width: 1.5),
          ),
          child: Icon(icon, size: compact ? 52 : 60, color: const Color(0xFF7A45D8)),
        ),
        const SizedBox(height: 18),

        Text(
          'Welcome back!',
          style: GoogleFonts.epilogue(
            color: const Color(0xFF1B1A29),
            fontSize: compact ? 22 : 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Use $label to continue.',
          textAlign: TextAlign.center,
          style: GoogleFonts.epilogue(
            color: const Color(0xFF5E5974),
            fontSize: compact ? 13 : 14,
            fontWeight: FontWeight.w500,
            height: 1.5,
            letterSpacing: 0,
          ),
        ),

        // Attempt warning
        if (_biometricAttempts > 0) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            '${_maxBiometricAttempts - _biometricAttempts} attempt(s) remaining',
            style: GoogleFonts.epilogue(
              color: const Color(0xFFE63A42),
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        const SizedBox(height: 28),

        // Authenticate button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _biometricLoading ? null : _triggerBiometric,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE63A42),
              disabledBackgroundColor:
                  const Color(0xFFE63A42).withOpacity(0.55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 5,
              shadowColor: const Color(0xFFE63A42).withOpacity(0.35),
            ),
            child: _biometricLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(
                    'USE ${ isFace ? "FACE ID" : "FINGERPRINT" }',
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

        // Use PIN instead
        TextButton(
          onPressed: _biometricLoading ? null : _switchToPin,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFADA5C4), width: 1.2),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(
            'Use PIN instead',
            style: GoogleFonts.epilogue(
              color: const Color(0xFF56506A),
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _PasswordFallbackLink(compact: compact, onTap: _switchToPassword),
      ],
    );
  }

  // ── PIN state ──────────────────────────────────────────────────────────────
  Widget _buildPin(bool compact) {
    return Column(
      children: <Widget>[
        _Logo(compact: compact),
        const SizedBox(height: 28),

        // Icon
        Container(
          width: compact ? 72 : 82,
          height: compact ? 72 : 82,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCDC8DC), width: 1.5),
          ),
          child: Icon(Icons.pin_outlined,
              size: compact ? 40 : 46, color: const Color(0xFF7A45D8)),
        ),
        const SizedBox(height: 18),

        Text(
          'Enter your PIN',
          style: GoogleFonts.epilogue(
            color: const Color(0xFF1B1A29),
            fontSize: compact ? 20 : 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter your 4-digit PIN to continue.',
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

        // PIN dots — tap to open keyboard
        GestureDetector(
          onTap: () {
            if (_pinFocus.hasFocus) {
              SystemChannels.textInput.invokeMethod<void>('TextInput.show');
            } else {
              _pinFocus.requestFocus();
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
              children: List<Widget>.generate(_pinLength, (int i) {
                final bool filled = i < _pin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
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

        // Hidden keyboard capture field
        SizedBox(
          height: 0,
          child: OverflowBox(
            maxHeight: 48,
            child: TextField(
              controller: _pinController,
              focusNode: _pinFocus,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: _pinLength,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_pinLength),
              ],
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              cursorColor: Colors.transparent,
              cursorWidth: 0,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
              enabled: !_pinVerifying,
            ),
          ),
        ),

        // Error / loading
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          child: _pinVerifying
              ? const Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Color(0xFF7A45D8)),
                  ),
                )
              : _pinError != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        _pinError!,
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

        // Switch back to biometrics if available
        if (_biometricType != null) ...<Widget>[
          const SizedBox(height: 14),
          TextButton(
            onPressed: () {
              setState(() => _mode = _AuthMode.biometric);
              _triggerBiometric();
            },
            child: Text(
              'Use ${_biometricType == BiometricType.face ? "Face ID" : "Fingerprint"} instead',
              style: GoogleFonts.epilogue(
                color: const Color(0xFF7A45D8),
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF7A45D8),
              ),
            ),
          ),
        ],
        const SizedBox(height: 6),
        _PasswordFallbackLink(compact: compact, onTap: _switchToPassword),
      ],
    );
  }

  // ── Password state ─────────────────────────────────────────────────────────
  Widget _buildPassword(bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Logo(compact: compact),
        const SizedBox(height: 28),

        Center(
          child: Text(
            'Login with Password',
            style: GoogleFonts.epilogue(
              color: const Color(0xFF1B1A29),
              fontSize: compact ? 20 : 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Use your account credentials to continue.',
            textAlign: TextAlign.center,
            style: GoogleFonts.epilogue(
              color: const Color(0xFF5E5974),
              fontSize: compact ? 13 : 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Email
        _FieldLabel(text: 'Email', compact: compact),
        const SizedBox(height: 8),
        _AuthInput(
          controller: _emailController,
          hint: 'Enter your email',
          compact: compact,
          keyboardType: TextInputType.emailAddress,
          prefix: const Icon(Icons.mail_outline, color: Color(0xFF6A6F85)),
          enabled: !_passwordLoading,
        ),
        const SizedBox(height: 14),

        // Password
        _FieldLabel(text: 'Password', compact: compact),
        const SizedBox(height: 8),
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setLocal) {
            return _AuthInput(
              controller: _passwordController,
              hint: 'Enter your password',
              compact: compact,
              obscureText: _obscurePassword,
              prefix: const Icon(Icons.lock_outline, color: Color(0xFF6A6F85)),
              enabled: !_passwordLoading,
              suffix: IconButton(
                onPressed: () => setState(
                    () => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF6A6F85),
                ),
              ),
            );
          },
        ),

        // Error message
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          child: _passwordError != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _passwordError!,
                    style: GoogleFonts.epilogue(
                      color: const Color(0xFFE63A42),
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 22),

        // Login button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _passwordLoading ? null : _loginWithPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE63A42),
              disabledBackgroundColor:
                  const Color(0xFFE63A42).withOpacity(0.55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 5,
              shadowColor: const Color(0xFFE63A42).withOpacity(0.35),
            ),
            child: _passwordLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
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
        const SizedBox(height: 14),

        // Back links
        if (_biometricType != null) ...<Widget>[
          TextButton(
            onPressed: () {
              setState(() => _mode = _AuthMode.biometric);
              _triggerBiometric();
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Text(
              'Use ${_biometricType == BiometricType.face ? "Face ID" : "Fingerprint"} instead',
              style: GoogleFonts.epilogue(
                color: const Color(0xFF7A45D8),
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF7A45D8),
              ),
            ),
          ),
        ] else ...<Widget>[
          TextButton(
            onPressed: _switchToPin,
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
            child: Text(
              'Use PIN instead',
              style: GoogleFonts.epilogue(
                color: const Color(0xFF7A45D8),
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF7A45D8),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── "Login with password" subtle link ────────────────────────────────────────
class _PasswordFallbackLink extends StatelessWidget {
  const _PasswordFallbackLink({required this.compact, required this.onTap});
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Forgot your PIN? ',
            style: GoogleFonts.epilogue(
              color: const Color(0xFF56506A),
              fontSize: compact ? 12 : 13,
              letterSpacing: 0,
            ),
          ),
          Text(
            'Login with password',
            style: GoogleFonts.epilogue(
              color: const Color(0xFF56506A),
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: const Color(0xFF56506A),
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Field label ───────────────────────────────────────────────────────────────
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

// ── Styled text input ─────────────────────────────────────────────────────────
class _AuthInput extends StatelessWidget {
  const _AuthInput({
    required this.controller,
    required this.hint,
    required this.compact,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hint;
  final bool compact;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCDC8DC), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFADA5C4), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFCDC8DC), width: 1),
        ),
      ),
    );
  }
}

// ── Shared logo block ─────────────────────────────────────────────────────────
class _Logo extends StatelessWidget {
  const _Logo({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
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
              letterSpacing: 0,
            ),
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
