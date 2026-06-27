import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/provider/auth_provider.dart';
import 'home_header_stat.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final int totalQuestions;
  final int totalCategories;
  final int maxScore;

  const HomeHeader({
    super.key,
    required this.onProfileTap,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.totalQuestions,
    required this.totalCategories,
    required this.maxScore,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final displayName = auth.userEmail != null
        ? auth.userEmail!.split('@').first
        : 'Guest';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, 👋',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Theme Toggle
                  IconButton(
                    onPressed: onThemeToggle,
                    icon: Icon(
                      isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Profile/Logout
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: HomeHeaderStat(
                    icon: Icons.quiz_outlined,
                    value: '$totalQuestions',
                    label: 'Questions',
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.white.withOpacity(0.2),
                ),
                Expanded(
                  child: HomeHeaderStat(
                    icon: Icons.category_outlined,
                    value: '$totalCategories',
                    label: 'Categories',
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.white.withOpacity(0.2),
                ),
                Expanded(
                  child: HomeHeaderStat(
                    icon: Icons.emoji_events_outlined,
                    value: '$maxScore',
                    label: 'Max Pts',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
