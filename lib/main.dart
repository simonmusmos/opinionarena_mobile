import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intra/opinion_arena_screen.dart';
import 'package:intra/opinion_arena_login_screen.dart';
import 'package:intra/opinion_arena_auth_screen.dart';

void main() {
  runApp(const IntraApp());
}

class IntraApp extends StatelessWidget {
  const IntraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Intra Login',
      theme: ThemeData.light().copyWith(
        textTheme: GoogleFonts.barlowTextTheme(
          ThemeData.light().textTheme,
        ).apply(fontFamilyFallback: const <String>['Arial', 'sans-serif']),
        primaryTextTheme: GoogleFonts.barlowTextTheme(
          ThemeData.light().primaryTextTheme,
        ).apply(fontFamilyFallback: const <String>['Arial', 'sans-serif']),
      ),
      home: const OpinionArenaAuthScreen(), // TODO: swap back to OpinionArenaLoginScreen() for new users
      // routes: <String, WidgetBuilder>{
      //   '/classic': (_) => const LoginScreen(),
      //   '/opinion': (_) => const OpinionArenaScreen(),
      // },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _obscurePassword = true;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool compact = width < 390;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _FadeSlideIn(
                controller: _controller,
                start: 0.00,
                end: 0.35,
                offsetY: -20,
                child: _Header(compact: compact),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _FadeSlideIn(
                      controller: _controller,
                      start: 0.20,
                      end: 0.60,
                      offsetY: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _Label('Email', compact: compact),
                          const SizedBox(height: 8),
                          _InputBox(
                            hint: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            compact: compact,
                          ),
                          const SizedBox(height: 22),
                          _Label('Password', compact: compact),
                          const SizedBox(height: 8),
                          _InputBox(
                            hint: 'Enter your password',
                            obscureText: _obscurePassword,
                            compact: compact,
                            suffix: IconButton(
                              onPressed: () => setState(() {
                                _obscurePassword = !_obscurePassword;
                              }),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF7A7A7A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: <Widget>[
                              Text(
                                'Forgot your password? ',
                                style: TextStyle(
                                  color: const Color(0xFF404040),
                                  fontSize: compact ? 17 : 18,
                                ),
                              ),
                              DecoratedBox(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xFF1C1C1C),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    'Get a new one here',
                                    style: TextStyle(
                                      color: const Color(0xFF1C1C1C),
                                      fontSize: compact ? 17 : 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _FadeSlideIn(
                      controller: _controller,
                      start: 0.45,
                      end: 0.78,
                      offsetY: 14,
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDE4D59),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 5,
                            shadowColor: const Color(0xFFDE4D59).withOpacity(0.35),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          child: Text(
                            'LOG IN',
                            style: GoogleFonts.barlowSemiCondensed(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    _FadeSlideIn(
                      controller: _controller,
                      start: 0.58,
                      end: 0.92,
                      offsetY: 12,
                      child: Column(
                        children: <Widget>[
                          _SocialButton(
                            icon: 'G',
                            label: 'Sign in with Google',
                            compact: compact,
                            textColor: const Color(0xFF404040),
                            backgroundColor: Colors.white,
                            borderColor: const Color(0xFFD9D9D9),
                          ),
                          const SizedBox(height: 14),
                          _SocialButton(
                            icon: 'f',
                            label: 'Sign in with Facebook',
                            compact: compact,
                            textColor: Colors.white,
                            backgroundColor: const Color(0xFF1F73E5),
                            borderColor: const Color(0xFF1F73E5),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: <Widget>[
                              const Expanded(child: Divider(color: Color(0xFFD0D0D0))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'or',
                                  style: TextStyle(
                                    fontSize: compact ? 17 : 19,
                                    color: const Color(0xFF7F7F7F),
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: Color(0xFFD0D0D0))),
                            ],
                          ),
                          const SizedBox(height: 34),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'No user account yet? ',
                                style: TextStyle(
                                  color: const Color(0xFF3A3A3A),
                                  fontSize: compact ? 16 : 17,
                                ),
                              ),
                              Text(
                                'Register Here',
                                style: TextStyle(
                                  color: const Color(0xFF1E1E1E),
                                  fontSize: compact ? 16 : 17,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
    this.offsetY = 16,
  });

  final AnimationController controller;
  final double start;
  final double end;
  final double offsetY;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Animation<double> curve = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curve,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final double t = curve.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * offsetY),
            child: child,
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _BottomCurveClipper(),
      child: Container(
        height: compact ? 190 : 210,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF5F2AB0), Color(0xFFBE467C)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  width: compact ? 52 : 58,
                  height: compact ? 52 : 58,
                  child: Image.asset('assets/images/header_logo.png', fit: BoxFit.contain),
                ),
                // Container(
                //   width: compact ? 46 : 52,
                //   height: compact ? 46 : 52,
                //   decoration: const BoxDecoration(
                //     shape: BoxShape.circle,
                //     color: Colors.white,
                //   ),
                //   child: const Icon(Icons.menu, color: Color(0xFF6F2FB3)),
                // ),
              ],
            ),
            // const Spacer(),
            const SizedBox(height: 20),
            Text(
              'WELCOME BACK',
              style: GoogleFonts.barlowSemiCondensed(
                color: Colors.white,
                fontSize: compact ? 36 : 42,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height - 6);
    path.cubicTo(
      size.width * 0.35,
      size.height - 2,
      size.width * 0.80,
      size.height - 20,
      size.width,
      size.height - 66,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _Label extends StatelessWidget {
  const _Label(this.text, {required this.compact});

  final String text;
  final bool compact;
 
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Color(0xFF434343),
        fontSize: compact ? 17 : 19,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({
    required this.hint,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
    this.compact = false,
  });

  final String hint;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16, color: Color(0xFF222222)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFFA2A7B0), fontSize: compact ? 17 : 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        suffixIcon: suffix,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD4D4D4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF8C8C8C)),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.compact,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String icon;
  final String label;
  final bool compact;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: compact ? 280 : 300,
        height: 48,
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: borderColor),
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 12,
                backgroundColor: icon == 'G' ? Colors.white : const Color(0xFF2066CC),
                child: Text(
                  icon,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: icon == 'G' ? const Color(0xFFE84C3D) : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.barlowSemiCondensed(
                  color: textColor,
                  fontSize: compact ? 16 : 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
