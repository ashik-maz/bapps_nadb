import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/provider/auth_provider.dart';
import 'package:quiz_master/provider/quiz_provider.dart';
import 'package:quiz_master/services/bdapps_service.dart';
import 'home_screen.dart';
import 'ai_assistant_screen.dart';
import 'preparation_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    AiAssistantScreen(),
    PreparationScreen(),
    ProfileScreen(),
  ];

  final List<String> _tabNames = const [
    'Home',
    'AI Assistant',
    'Preparation',
    'Profile',
  ];

  Future<bool> _onWillPop(BuildContext context) async {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.exit_to_app_rounded, color: Color(0xFFE11D48)),
            SizedBox(width: 8),
            Text('Exit App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to exit Prostuti?',
          style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('No', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes, Exit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  void _showLockedFeatureModal(BuildContext context, String tabName) {
    final quizProvider = context.read<QuizProvider>();
    final auth = context.read<AuthProvider>();
    final mobile = quizProvider.subscriberMobile ?? auth.userMobile ?? '';
    final mobileCtrl = TextEditingController(text: mobile);
    final otpCtrl = TextEditingController();
    final bdapps = BDappsService();

    bool otpSent = false;
    bool loading = false;
    String referenceNo = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              const Icon(Icons.lock_rounded, color: Color(0xFFE11D48)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Subscribe to Unlock $tabName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$tabName is locked in Demo Mode. Subscribe to unlock Gemini AI Assistant, full preparation notes, and global leaderboard.',
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
              ),
              const SizedBox(height: 12),
              if (!otpSent) ...[
                TextField(
                  controller: mobileCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  decoration: InputDecoration(
                    labelText: 'Robi / Airtel Mobile',
                    prefixText: '+88 ',
                    hintText: '018XXXXXXXX',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: const Text(
                    'Tariff: 2.00 BDT + VAT + SD + SC per day.\nAuto-renewable. Unsubscribe anytime.',
                    style: TextStyle(fontSize: 11, color: Color(0xFFBE123C), fontWeight: FontWeight.bold),
                  ),
                ),
              ] else ...[
                Text(
                  'Enter OTP PIN sent to +88 ${mobileCtrl.text.trim()}:',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '••••',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final targetMobile = mobileCtrl.text.trim();
                      if (targetMobile.length < 11) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid 11-digit mobile number')),
                        );
                        return;
                      }

                      setDialogState(() => loading = true);

                      if (!otpSent) {
                        final result = await bdapps.sendOtp(targetMobile);
                        setDialogState(() => loading = false);

                        if (result['alreadySubscribed'] == true) {
                          if (context.mounted) {
                            await bdapps.setUserPassword(targetMobile, '123456');
                            await auth.loginWithMobileDirect(targetMobile, forceSubscribed: true);
                            quizProvider.setSubscriptionState(true, mobile: targetMobile);
                            auth.setSubscriptionState(true, mobile: targetMobile);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('🎉 Subscribed! Full Access Unlocked.'), backgroundColor: Colors.green),
                            );
                          }
                          return;
                        }

                        final ref = result['referenceNo']?.toString() ?? '';
                        if (result['success'] == true && ref.isNotEmpty) {
                          referenceNo = ref;
                          setDialogState(() => otpSent = true);
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result['message']?.toString() ?? 'Failed to send OTP.'), backgroundColor: Colors.red),
                          );
                        }
                      } else {
                        final result = await bdapps.verifyOtp(targetMobile, otpCtrl.text.trim(), referenceNo);
                        setDialogState(() => loading = false);

                        final isSuccess = result['statusCode'] == 'S1000' ||
                            result['subscriptionStatus'] == 'REGISTERED';

                        if (isSuccess && context.mounted) {
                          await bdapps.setUserPassword(targetMobile, '123456');
                          await auth.loginWithMobileDirect(targetMobile, forceSubscribed: true);
                          quizProvider.setSubscriptionState(true, mobile: targetMobile);
                          auth.setSubscriptionState(true, mobile: targetMobile);
                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('🎉 Subscribed successfully! Pro Mode Unlocked.'), backgroundColor: Colors.green),
                            );
                          }
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result['statusDetail']?.toString() ?? 'OTP verification failed.'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(otpSent ? 'Confirm PIN' : 'Subscribe Now', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quizProvider = context.watch<QuizProvider>();
    final auth = context.watch<AuthProvider>();
    final isSubscribed = quizProvider.isSubscribed || auth.isSubscribed;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _onWillPop(context);
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151F32) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index != 0 && !isSubscribed) {
              _showLockedFeatureModal(context, _tabNames[index]);
              return;
            }
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFE11D48),
          unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded, color: Color(0xFFE11D48)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.smart_toy_outlined),
                  if (!isSubscribed)
                    const Positioned(
                      right: -6,
                      top: -4,
                      child: Icon(Icons.lock_rounded, size: 12, color: Color(0xFFE11D48)),
                    ),
                ],
              ),
              activeIcon: const Icon(Icons.smart_toy_rounded, color: Color(0xFFE11D48)),
              label: 'AI Assistant',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.library_books_outlined),
                  if (!isSubscribed)
                    const Positioned(
                      right: -6,
                      top: -4,
                      child: Icon(Icons.lock_rounded, size: 12, color: Color(0xFFE11D48)),
                    ),
                ],
              ),
              activeIcon: const Icon(Icons.library_books_rounded, color: Color(0xFFE11D48)),
              label: 'Preparation',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.person_outline_rounded),
                  if (!isSubscribed)
                    const Positioned(
                      right: -6,
                      top: -4,
                      child: Icon(Icons.lock_rounded, size: 12, color: Color(0xFFE11D48)),
                    ),
                ],
              ),
              activeIcon: const Icon(Icons.person_rounded, color: Color(0xFFE11D48)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
