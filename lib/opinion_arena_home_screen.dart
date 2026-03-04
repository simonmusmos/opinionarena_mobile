import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intra/models/oa_user.dart';
import 'package:intra/opinion_arena_login_screen.dart';
import 'package:intra/services/auth_service.dart';

// ── Data models ───────────────────────────────────────────────────────────────
enum _SurveyStatus { inProgress, isNew }

// ── Surveys data ──────────────────────────────────────────────────────────────
class _AvailableSurveyItem {
  const _AvailableSurveyItem({
    required this.id,
    required this.minutes,
    required this.points,
    required this.status,
  });
  final String id;
  final int minutes;
  final int points;
  final _SurveyStatus status;
}

const List<_AvailableSurveyItem> _availableSurveyItems = <_AvailableSurveyItem>[
  _AvailableSurveyItem(id: '#SRV-6413-1166', minutes: 15, points: 500, status: _SurveyStatus.inProgress),
  _AvailableSurveyItem(id: '#SRV-5413-1762', minutes: 12, points: 450, status: _SurveyStatus.isNew),
  _AvailableSurveyItem(id: '#SRV-0217-8145', minutes: 20, points: 600, status: _SurveyStatus.isNew),
];

class _CompletedSurveyItem {
  const _CompletedSurveyItem({
    required this.id,
    required this.minutes,
    required this.points,
    required this.date,
  });
  final String id;
  final int minutes;
  final int points;
  final String date;
}

const List<_CompletedSurveyItem> _completedSurveyItems = <_CompletedSurveyItem>[
  _CompletedSurveyItem(id: '#SRV-6413-1166', minutes: 15, points: 500, date: 'February 15, 2026'),
  _CompletedSurveyItem(id: '#SRV-0217-8145', minutes: 20, points: 600, date: 'January 27, 2026'),
];

// ── Screen ────────────────────────────────────────────────────────────────────
class OpinionArenaHomeScreen extends StatefulWidget {
  const OpinionArenaHomeScreen({super.key, required this.user});

  final OAUser user;

  @override
  State<OpinionArenaHomeScreen> createState() => _OpinionArenaHomeScreenState();
}

class _OpinionArenaHomeScreenState extends State<OpinionArenaHomeScreen> {
  int _selectedTab = 0;
  int _surveySubTab = 0;
  bool _logoutLoading = false;

  OAUser get _user => widget.user;

  String _formatPoints(int n) {
    final String s = n.toString();
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildAppBar(),
            Expanded(
              child: _selectedTab == 3
                  ? _buildProfileTab()
                  : _selectedTab == 1
                      ? _buildSurveysTab()
                      : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 16),
                          _buildPointsCard(),
                          const SizedBox(height: 28),
                          _buildSurveysSection(),
                          const SizedBox(height: 28),
                          _buildRafflesSection(),
                          const SizedBox(height: 16),
                          _buildFaqCard(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: <Widget>[
          const Icon(Icons.menu_rounded, color: Color(0xFF4A4A6A), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: _selectedTab == 1
                ? Text(
                    'Surveys',
                    style: GoogleFonts.epilogue(
                      color: const Color(0xFF1A1A2E),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'WELCOME BACK',
                        style: GoogleFonts.epilogue(
                          color: const Color(0xFF9090A8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                      Text(
                        _user.firstName.toUpperCase(),
                        style: GoogleFonts.epilogue(
                          color: const Color(0xFF1A1A2E),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
          ),
          // Gradient avatar
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Color(0xFF7A45D8), Color(0xFFE4528C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _user.initials,
                style: GoogleFonts.epilogue(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // App logo button
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF0EEF8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/header_logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Points card ────────────────────────────────────────────────────────────
  Widget _buildPointsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF7A45D8), Color(0xFFE4528C)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF7A45D8).withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'AVAILABLE POINTS',
                  style: GoogleFonts.epilogue(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFFCC00), size: 28),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              _formatPoints(_user.points),
              style: GoogleFonts.epilogue(
                color: Colors.white,
                fontSize: 46,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: _PointsActionButton(
                    icon: Icons.card_giftcard_outlined,
                    label: 'Redeem Rewards',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PointsActionButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'Transaction History',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Surveys section ────────────────────────────────────────────────────────
  Widget _buildSurveysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionHeader(
            title: 'Available Surveys',
            subtitle: 'Complete surveys and keep earning rewards',
          ),
        ),
        const SizedBox(height: 14),
        ..._availableSurveyItems.take(2).map((_AvailableSurveyItem s) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: _AvailableSurveyCard(survey: s),
            )),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: _ViewAllLink(label: 'View All Surveys', onTap: () {}),
        ),
      ],
    );
  }

  // ── Raffles section ────────────────────────────────────────────────────────
  Widget _buildRafflesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SectionHeader(
            title: 'Active Raffles',
            subtitle: "Don't miss your chance to win big",
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF7A45D8), Color(0xFFE4528C)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF7A45D8).withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Label
                Row(
                  children: <Widget>[
                    Icon(Icons.emoji_events_outlined,
                        color: Colors.white.withValues(alpha: 0.9), size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'ACTIVE RAFFLE',
                      style: GoogleFonts.epilogue(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Icon + title
                Row(
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'P',
                          style: GoogleFonts.epilogue(
                            color: const Color(0xFF003087),
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Win a €300 PayPal Gift Card',
                        style: GoogleFonts.epilogue(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Ticket progress
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Your Tickets',
                            style: GoogleFonts.epilogue(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '4 / 10',
                            style: GoogleFonts.epilogue(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 4 / 10,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.25),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white),
                          minHeight: 7,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Prize pool + button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'PRIZE POOL',
                          style: GoogleFonts.epilogue(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '€300.00 EUR',
                          style: GoogleFonts.epilogue(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        elevation: 0,
                      ),
                      child: Text(
                        'View Details',
                        style: GoogleFonts.epilogue(
                          color: const Color(0xFF7A45D8),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: _ViewAllLink(label: 'Browse All Raffles', onTap: () {}),
        ),
      ],
    );
  }

  // ── FAQ card ───────────────────────────────────────────────────────────────
  Widget _buildFaqCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF00BFA5).withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  width: 5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[Color(0xFF00BFA5), Color(0xFF00ACC1)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Have questions?',
                                style: GoogleFonts.epilogue(
                                  color: const Color(0xFF1A1A2E),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Browse FAQs and quick answers',
                                style: GoogleFonts.epilogue(
                                  color: const Color(0xFF8A8A9A),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: <Color>[
                                  Color(0xFF00BFA5),
                                  Color(0xFF00ACC1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: const Color(0xFF00BFA5)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              'FAQ',
                              style: GoogleFonts.epilogue(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Surveys tab ────────────────────────────────────────────────────────────
  Widget _buildSurveysTab() {
    final List<Widget> items = _surveySubTab == 0
        ? _availableSurveyItems
            .map((_AvailableSurveyItem s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AvailableSurveyCard(survey: s),
                ))
            .toList()
        : _completedSurveyItems
            .map((_CompletedSurveyItem s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CompletedSurveyCard(survey: s),
                ))
            .toList();

    return ColoredBox(
      color: const Color(0xFFF7F5FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 12),
          // Gradient tab switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SurveyTabSwitcher(
              selected: _surveySubTab,
              availableCount: _availableSurveyItems.length,
              completedCount: _completedSurveyItems.length,
              onChanged: (int i) => setState(() => _surveySubTab = i),
            ),
          ),
          const SizedBox(height: 14),
          // Survey count label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _surveySubTab == 0
                        ? const Color(0xFF7A45D8)
                        : const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  _surveySubTab == 0
                      ? '${_availableSurveyItems.length} AVAILABLE SURVEYS'
                      : '${_completedSurveyItems.length} COMPLETED SURVEYS',
                  style: GoogleFonts.epilogue(
                    color: const Color(0xFF8A8A9A),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Survey list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile tab (placeholder) ──────────────────────────────────────────────
  Widget _buildProfileTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFF7A45D8), Color(0xFFE4528C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _user.initials,
                  style: GoogleFonts.epilogue(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${_user.firstName} ${_user.lastName}'.trim(),
              style: GoogleFonts.epilogue(
                color: const Color(0xFF1A1A2E),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _user.email,
              style: GoogleFonts.epilogue(
                color: const Color(0xFF8A8A9A),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 32),
            // TODO: full profile layout coming soon
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _logoutLoading ? null : _onLogoutPressed,
                icon: _logoutLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.logout_rounded, size: 20),
                label: Text(
                  _logoutLoading ? 'Logging out...' : 'Log Out',
                  style: GoogleFonts.epilogue(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE63A42),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFFE63A42).withValues(alpha: 0.55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onLogoutPressed() async {
    setState(() => _logoutLoading = true);
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const OpinionArenaLoginScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  // ── Bottom nav ─────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _NavItem(
                icon: _selectedTab == 0
                    ? Icons.home_rounded
                    : Icons.home_outlined,
                label: 'Home',
                selected: _selectedTab == 0,
                onTap: () => setState(() => _selectedTab = 0),
              ),
              _NavItemWithBadge(
                icon: Icons.assignment_outlined,
                label: 'Surveys',
                selected: _selectedTab == 1,
                badge: 3,
                onTap: () => setState(() => _selectedTab = 1),
              ),
              _NavItem(
                icon: _selectedTab == 2
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                label: 'Rewards',
                selected: _selectedTab == 2,
                onTap: () => setState(() => _selectedTab = 2),
              ),
              _NavItem(
                icon: _selectedTab == 3
                    ? Icons.person_rounded
                    : Icons.person_outline_rounded,
                label: 'Profile',
                selected: _selectedTab == 3,
                onTap: () => setState(() => _selectedTab = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Points action button ──────────────────────────────────────────────────────
class _PointsActionButton extends StatelessWidget {
  const _PointsActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.epilogue(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: GoogleFonts.epilogue(
            color: const Color(0xFF1A1A2E),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.epilogue(
            color: const Color(0xFF8A8A9A),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ── View all link ─────────────────────────────────────────────────────────────
class _ViewAllLink extends StatelessWidget {
  const _ViewAllLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: GoogleFonts.epilogue(
              color: const Color(0xFF7A45D8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            color: const Color(0xFF7A45D8),
            size: 18,
          ),
        ],
      ),
    );
  }
}

// ── Bottom nav item ───────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        selected ? const Color(0xFF7A45D8) : const Color(0xFFA0A0B8);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.epilogue(
                color: color,
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom nav item with badge ────────────────────────────────────────────────
class _NavItemWithBadge extends StatelessWidget {
  const _NavItemWithBadge({
    required this.icon,
    required this.label,
    required this.selected,
    required this.badge,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        selected ? const Color(0xFF7A45D8) : const Color(0xFFA0A0B8);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Icon(icon, color: color, size: 24),
                if (badge > 0)
                  PositionedDirectional(
                    end: -7,
                    top: -5,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.epilogue(
                color: color,
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Survey tab switcher ────────────────────────────────────────────────────────
class _SurveyTabSwitcher extends StatelessWidget {
  const _SurveyTabSwitcher({
    required this.selected,
    required this.onChanged,
    required this.availableCount,
    required this.completedCount,
  });
  final int selected;
  final ValueChanged<int> onChanged;
  final int availableCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF7A45D8), Color(0xFFE4528C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF7A45D8).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: _tab(0, 'Available', availableCount)),
          Expanded(child: _tab(1, 'Completed', completedCount)),
        ],
      ),
    );
  }

  Widget _tab(int index, String label, int count) {
    final bool active = selected == index;
    return GestureDetector(
      onTap: () => onChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: GoogleFonts.epilogue(
                  color: active ? const Color(0xFF7A45D8) : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF7A45D8)
                      : Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.epilogue(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Available survey card ──────────────────────────────────────────────────────
class _AvailableSurveyCard extends StatelessWidget {
  const _AvailableSurveyCard({required this.survey});
  final _AvailableSurveyItem survey;

  @override
  Widget build(BuildContext context) {
    final bool inProgress = survey.status == _SurveyStatus.inProgress;
    final Color accentColor =
        inProgress ? const Color(0xFF7A45D8) : const Color(0xFF00BCD4);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Left accent bar
            Container(
              width: 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: inProgress
                      ? const <Color>[Color(0xFF7A45D8), Color(0xFFB24DC0)]
                      : const <Color>[Color(0xFF00BCD4), Color(0xFF00ACC1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Card content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Title + badge row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Survey ID: ${survey.id}',
                            style: GoogleFonts.epilogue(
                              color: const Color(0xFF1A1A2E),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _SurveyStatusBadge(inProgress: inProgress),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Meta row: time + points
                    Row(
                      children: <Widget>[
                        const Icon(Icons.access_time_rounded,
                            size: 13, color: Color(0xFF8A8A9A)),
                        const SizedBox(width: 4),
                        Text(
                          '${survey.minutes} mins',
                          style: GoogleFonts.epilogue(
                              color: const Color(0xFF8A8A9A), fontSize: 12),
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.star_rounded,
                            size: 14, color: Color(0xFFFFB800)),
                        const SizedBox(width: 3),
                        Text(
                          '${survey.points} pts',
                          style: GoogleFonts.epilogue(
                            color: const Color(0xFFFF9800),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    // Progress bar for in-progress surveys
                    if (inProgress) ...<Widget>[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Progress',
                            style: GoogleFonts.epilogue(
                              color: const Color(0xFF8A8A9A),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '40%',
                            style: GoogleFonts.epilogue(
                              color: const Color(0xFF7A45D8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.40,
                          backgroundColor: const Color(0xFFEEEBF8),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF7A45D8)),
                          minHeight: 5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    // CTA button
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: <Color>[
                              Color(0xFF4F6CF2),
                              Color(0xFF7A45D8),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color:
                                  const Color(0xFF7A45D8).withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              inProgress ? 'Continue' : 'Start Survey',
                              style: GoogleFonts.epilogue(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              inProgress
                                  ? Icons.play_arrow_rounded
                                  : Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ── Survey status badge ────────────────────────────────────────────────────────
class _SurveyStatusBadge extends StatelessWidget {
  const _SurveyStatusBadge({required this.inProgress});
  final bool inProgress;

  @override
  Widget build(BuildContext context) {
    if (inProgress) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFFFF6B35), Color(0xFFFF3D71)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFFFF6B35).withValues(alpha: 0.30),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.radio_button_checked,
                size: 8, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              'In Progress',
              style: GoogleFonts.epilogue(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00BCD4).withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.fiber_new_rounded, size: 12, color: Color(0xFF00ACC1)),
          const SizedBox(width: 3),
          Text(
            'New',
            style: GoogleFonts.epilogue(
              color: const Color(0xFF00ACC1),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Completed survey card ──────────────────────────────────────────────────────
class _CompletedSurveyCard extends StatelessWidget {
  const _CompletedSurveyCard({required this.survey});
  final _CompletedSurveyItem survey;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Left green accent bar
            Container(
              width: 5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFF43C96A), Color(0xFF2EAF55)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Card content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 15, 16, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Title + checkmark
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Survey ID: ${survey.id}',
                            style: GoogleFonts.epilogue(
                              color: const Color(0xFF1A1A2E),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: <Color>[
                                Color(0xFF43C96A),
                                Color(0xFF2EAF55),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: const Color(0xFF4CAF50)
                                    .withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Meta row: time + date
                    Row(
                      children: <Widget>[
                        const Icon(Icons.access_time_rounded,
                            size: 13, color: Color(0xFF8A8A9A)),
                        const SizedBox(width: 4),
                        Text(
                          '${survey.minutes} mins',
                          style: GoogleFonts.epilogue(
                              color: const Color(0xFF8A8A9A), fontSize: 12),
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: Color(0xFF8A8A9A)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            survey.date,
                            style: GoogleFonts.epilogue(
                                color: const Color(0xFF8A8A9A), fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Points badge — bottom right
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFFFB800)
                                  .withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(Icons.star_rounded,
                                size: 14, color: Color(0xFFFFB800)),
                            const SizedBox(width: 4),
                            Text(
                              '+${survey.points} pts',
                              style: GoogleFonts.epilogue(
                                color: const Color(0xFFE65C00),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
