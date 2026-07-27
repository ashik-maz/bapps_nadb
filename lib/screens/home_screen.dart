import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/models/question.dart';
import 'package:quiz_master/provider/auth_provider.dart';
import 'package:quiz_master/provider/quiz_provider.dart';
import 'package:quiz_master/services/bdapps_service.dart';
import 'package:quiz_master/services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String _selectedMode = 'Mixed';
  int _questionCount = 10;

  final List<String> _modes = ['IT', 'General Knowledge', 'English', 'Bangla', 'Mixed'];
  final BDappsService _bdapps = BDappsService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialSubscription();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkInitialSubscription();
    }
  }

  Future<void> _checkInitialSubscription() async {
    final quizProvider = context.read<QuizProvider>();
    final auth = context.read<AuthProvider>();
    final mobile = quizProvider.subscriberMobile ?? auth.userMobile;

    if (mobile != null && mobile.isNotEmpty) {
      final isSub = await _bdapps.checkSubscription(mobile);
      final currentSub = quizProvider.isSubscribed || auth.isSubscribed;
      // Preserve active subscription state unless explicit unsubscription occurred
      final finalState = isSub || currentSub;
      quizProvider.setSubscriptionState(finalState, mobile: mobile);
      auth.setSubscriptionState(finalState, mobile: mobile);
    }
  }

  void _showSubscriptionModal() {
    final mobileCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    bool otpSent = false;
    bool loading = false;
    String referenceNo = ''; // Store referenceNo from sendOtp response

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFE11D48)),
              const SizedBox(width: 8),
              Text(
                otpSent ? 'Enter OTP PIN' : 'Subscribe Now',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!otpSent) ...[
                const Text(
                  'Enter your Robi or Airtel mobile number to access full Prostuti prep:',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mobileCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  decoration: InputDecoration(
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
                    'Tariff: 2.00 BDT + VAT + SD + SC per day.\nFor Robi and Airtel Users only (Auto-renewable).',
                    style: TextStyle(fontSize: 11, color: Color(0xFFBE123C), fontWeight: FontWeight.bold),
                  ),
                ),
              ] else ...[
                Text(
                  'OTP PIN code sent to +88 ${mobileCtrl.text.trim()}:',
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
                      setDialogState(() => loading = true);
                      final mobile = mobileCtrl.text.trim();

                      if (!otpSent) {
                        // Step 1: Send OTP and store referenceNo
                        final result = await _bdapps.sendOtp(mobile);
                        setDialogState(() => loading = false);

                        // Check if already subscribed
                        if (result['alreadySubscribed'] == true) {
                          if (context.mounted) {
                            final quizProvider = context.read<QuizProvider>();
                            final auth = context.read<AuthProvider>();
                            await _bdapps.setUserPassword(mobile, '123456');
                            await auth.loginWithMobileDirect(mobile, forceSubscribed: true);
                            quizProvider.setSubscriptionState(true, mobile: mobile);
                            auth.setSubscriptionState(true, mobile: mobile);
                            if (auth.user != null) {
                              _firestoreService.updateUserMobile(auth.user!.uid, mobile);
                            }
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Already subscribed! Full access unlocked.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                          return;
                        }

                        // Check if OTP was sent successfully
                        final ref = result['referenceNo']?.toString() ?? '';
                        if (result['success'] == true && ref.isNotEmpty) {
                          referenceNo = ref;
                          setDialogState(() => otpSent = true);
                        } else {
                          // Show error
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message']?.toString() ?? 'Failed to send OTP. Try again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } else {
                        // Step 2: Verify OTP with referenceNo
                        final result = await _bdapps.verifyOtp(mobile, otpCtrl.text.trim(), referenceNo);
                        setDialogState(() => loading = false);

                        final isSuccess = result['statusCode'] == 'S1000' ||
                            result['subscriptionStatus'] == 'REGISTERED';

                        if (isSuccess && context.mounted) {
                          final quizProvider = context.read<QuizProvider>();
                          final auth = context.read<AuthProvider>();

                          await _bdapps.setUserPassword(mobile, '123456');
                          await auth.loginWithMobileDirect(mobile, forceSubscribed: true);
                          quizProvider.setSubscriptionState(true, mobile: mobile);
                          auth.setSubscriptionState(true, mobile: mobile);

                          if (auth.isAuthenticated && auth.user != null) {
                            _firestoreService.updateUserMobile(auth.user!.uid, mobile);
                          }

                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎉 Subscribed successfully! Pro Mode Unlocked.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['statusDetail']?.toString() ?? 'OTP verification failed. Please try again.'),
                              backgroundColor: Colors.red,
                            ),
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
                  : Text(otpSent ? 'Confirm PIN' : 'Send OTP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleUnsubscribe() {
    final quizProvider = context.read<QuizProvider>();
    final auth = context.read<AuthProvider>();
    final savedMobile = quizProvider.subscriberMobile ?? auth.userMobile ?? '';
    final mobileCtrl = TextEditingController(text: savedMobile);

    showDialog(
      context: context,
      builder: (ctx) {
        bool loading = false;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFBE123C)),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Unsubscribe Plan', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFBE123C))),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your Robi / Airtel mobile number to cancel your daily subscription:',
                  style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mobileCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  decoration: InputDecoration(
                    prefixText: '+88 ',
                    hintText: '018XXXXXXXX',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: const Text(
                    'Or send SMS: write STOP prostuti and send to 21213 from your phone.',
                    style: TextStyle(fontSize: 11, color: Color(0xFFBE123C), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: loading ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        final targetMobile = mobileCtrl.text.trim();
                        if (targetMobile.length < 11) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid 11-digit mobile number'), backgroundColor: Colors.red),
                          );
                          return;
                        }

                        setDialogState(() => loading = true);
                        final result = await _bdapps.unsubscribe(targetMobile);
                        setDialogState(() => loading = false);

                        final success = result['success'] == true;
                        if (success && context.mounted) {
                          quizProvider.setSubscriptionState(false, mobile: targetMobile);
                          auth.setSubscriptionState(false, mobile: targetMobile);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Successfully unsubscribed from Prostuti.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else if (context.mounted) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message']?.toString() ?? 'Unsubscription failed. Try SMS: STOP prostuti to 21213'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBE123C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: loading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Unsubscribe Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startQuiz() async {
    final quizProvider = context.read<QuizProvider>();
    final auth = context.read<AuthProvider>();
    final router = GoRouter.of(context);
    final isSubscribed = quizProvider.isSubscribed || auth.isSubscribed;

    int targetAmount = _questionCount;
    if (!isSubscribed) {
      if (targetAmount > 20) targetAmount = 20;
    }

    String fetchCategory = _selectedMode;
    if (_selectedMode == 'IT') fetchCategory = 'CSE/IT';
    if (_selectedMode == 'General Knowledge') fetchCategory = 'General Knowledge';

    final String userIdentifier = quizProvider.subscriberMobile ?? auth.userMobile ?? auth.userEmail ?? 'subscriber_guest';

    final fetched = await quizProvider.fetchQuestions(
      amount: targetAmount,
      category: fetchCategory,
      userIdentifier: userIdentifier,
    );

    if (fetched != null && fetched.isNotEmpty) {
      fetched.shuffle();
      router.push('/quiz/$_selectedMode', extra: fetched);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(quizProvider.errorMessage ?? 'Failed to load questions. Please retry.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quizProvider = context.watch<QuizProvider>();
    final auth = context.watch<AuthProvider>();
    final isSubscribed = quizProvider.isSubscribed || auth.isSubscribed;

    final maxQuestionLimit = isSubscribed ? 50 : 20;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prostuti', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: SizedBox(
                height: 32,
                child: isSubscribed
                    ? OutlinedButton.icon(
                        onPressed: _handleUnsubscribe,
                        icon: const Icon(Icons.cancel_rounded, size: 14, color: Color(0xFFBE123C)),
                        label: const Text('Unsubscribe', style: TextStyle(fontSize: 11, color: Color(0xFFBE123C), fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFECDD3), width: 1.5),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _showSubscriptionModal,
                        icon: const Icon(Icons.star_rounded, size: 14, color: Colors.white),
                        label: const Text('Subscribe Now', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w900)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isSubscribed) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded, color: Color(0xFFE11D48), size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'To access full Prostuti, subscribe now.',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF881337)),
                            ),
                            const Text(
                              'Demo Mode is limited to 20 MCQs. Tariff: 2.00 BDT/day.',
                              style: TextStyle(fontSize: 11, color: Color(0xFFBE123C)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _showSubscriptionModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Subscribe', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              Text(
                'Select Quiz Mode',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D1B2A),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _modes.map((mode) {
                  final isSelected = _selectedMode == mode;
                  return ChoiceChip(
                    label: Text(
                      mode == 'Mixed' ? '🔥 Mixed Mode' : mode,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFE11D48),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedMode = mode;
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Number of Questions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D1B2A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_questionCount MCQs',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Slider(
                value: _questionCount.toDouble(),
                min: 5,
                max: maxQuestionLimit.toDouble(),
                divisions: (maxQuestionLimit - 5) ~/ 5 > 0 ? (maxQuestionLimit - 5) ~/ 5 : 1,
                activeColor: const Color(0xFFE11D48),
                inactiveColor: const Color(0xFFFECDD3),
                label: '$_questionCount Questions',
                onChanged: (val) {
                  setState(() {
                    _questionCount = val.toInt();
                  });
                },
              ),

              if (!isSubscribed)
                const Padding(
                  padding: EdgeInsets.only(left: 4, top: 2),
                  child: Text(
                    '🔒 Demo limit: 20 MCQs max per exam. Subscribe for unlimited (50+ MCQs).',
                    style: TextStyle(fontSize: 11, color: Color(0xFFBE123C), fontWeight: FontWeight.w600),
                  ),
                ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: quizProvider.isLoading ? null : _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
                icon: quizProvider.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                label: Text(
                  quizProvider.isLoading ? 'Preparing Quiz...' : 'Start Exam Now',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
