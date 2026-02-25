import 'package:flutter/material.dart';

import 'package:intra/models/oa_user.dart';
import 'package:intra/opinion_arena_auth_screen.dart';
import 'package:intra/opinion_arena_login_screen.dart';
import 'package:intra/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final OAUser? user = await AuthService.validateToken();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => user != null
            ? OpinionArenaAuthScreen(user: user)
            : const OpinionArenaLoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF7A45D8),
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
