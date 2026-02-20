import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OpinionArenaScreen extends StatefulWidget {
  const OpinionArenaScreen({super.key});

  @override
  State<OpinionArenaScreen> createState() => _OpinionArenaScreenState();
}

class _OpinionArenaScreenState extends State<OpinionArenaScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool compact = width < 390;
    final ThemeData pageTheme = Theme.of(context).copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      primaryTextTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).primaryTextTheme),
    );

    return Theme(
      data: pageTheme,
      child: Scaffold(
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
                const SizedBox(height: 128),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 26),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCC7E4),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: SizedBox(
                          width: compact ? 78 : 84,
                          height: compact ? 78 : 84,
                          child: Image.asset(
                            'assets/images/header_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // const SizedBox(height: 2),
                      Center(
                        child: Text(
                          'OpinionArena',
                          style: TextStyle(
                            color: const Color(0xFF1D1B2A),
                            fontSize: compact ? 28 : 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Hello!',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1B1A29),
                          fontSize: compact ? 46 : 50,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Please enter your details to continue',
                        style: TextStyle(
                          color: const Color(0xFF5E5974),
                          fontSize: compact ? 21 : 23,
                          fontWeight: FontWeight.w500,
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
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: const Color(0xFF6A6F85),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          Text(
                            'Forgot your password? ',
                            style: TextStyle(
                              color: const Color(0xFF56506A),
                              fontSize: compact ? 15 : 16,
                            ),
                          ),
                          const Text(
                            'Get a new one here',
                            style: TextStyle(
                              color: Color(0xFF242031),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE63A42),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 5,
                            shadowColor: const Color(0xFFE63A42).withOpacity(0.35),
                          ),
                          child: Text(
                            'LOG IN',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: <Widget>[
                          const Expanded(child: Divider(color: Color(0xFFE8DDF0))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: const Color(0xFF706B83),
                                fontSize: compact ? 16 : 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFE8DDF0))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SocialRowButton(
                        compact: compact,
                        label: 'Sign in with Google',
                        iconColor: const Color(0xFFE3463D),
                        background: Colors.white,
                        textColor: const Color(0xFF222030),
                      ),
                      const SizedBox(height: 12),
                      _SocialRowButton(
                        compact: compact,
                        label: 'Sign in with Facebook',
                        iconColor: Colors.white,
                        background: const Color(0xFF4569D8),
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'No user account yet? ',
                            style: TextStyle(
                              color: const Color(0xFF57526A),
                              fontSize: compact ? 15 : 16,
                            ),
                            children: const <InlineSpan>[
                              TextSpan(
                                text: 'Register Here',
                                style: TextStyle(
                                  color: Color(0xFF222030),
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    'Are you ready to influence the world for a better future? Your opinion matters!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: compact ? 26 : 30,
                      fontWeight: FontWeight.w700,
                      height: 1.06,
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.15),
                      ),
                      child: Text(
                        'LOGIN AND START EARNING',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFE63A42),
                          fontSize: compact ? 24 : 26,
                          fontWeight: FontWeight.w700,
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
                      style: TextStyle(
                        color: const Color(0xFFEDDFF4),
                        fontSize: compact ? 13 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                      children: const <InlineSpan>[
                        TextSpan(
                          text: 'Intra Research',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w700,
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
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, required this.compact});

  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0xFF69657D),
        fontSize: compact ? 18 : 19,
        fontWeight: FontWeight.w700,
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
      style: TextStyle(
        color: const Color(0xFF232032),
        fontSize: compact ? 17 : 18,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F5F7),
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF757A91),
          fontSize: compact ? 17 : 18,
        ),
        prefixIcon: prefix,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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

class _SocialRowButton extends StatelessWidget {
  const _SocialRowButton({
    required this.compact,
    required this.label,
    required this.iconColor,
    required this.background,
    required this.textColor,
  });

  final bool compact;
  final String label;
  final Color iconColor;
  final Color background;
  final Color textColor;

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
            Icon(Icons.public, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: compact ? 17 : 18,
                fontWeight: FontWeight.w500,
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
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 19 : 20,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white,
        ),
      ),
    );
  }
}
