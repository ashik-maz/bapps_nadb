import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/provider/auth_provider.dart';
import 'package:quiz_master/provider/quiz_provider.dart';
import 'package:quiz_master/router/app_router.dart';
import 'package:quiz_master/services/bdapps_service.dart';
import 'package:quiz_master/services/firestore_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final BDappsService _bdapps = BDappsService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _refreshSubscriptionStatus();
  }

  Future<void> _refreshSubscriptionStatus() async {
    final quizProvider = context.read<QuizProvider>();
    final auth = context.read<AuthProvider>();
    final mobile = quizProvider.subscriberMobile ?? auth.userMobile;

    if (mobile != null && mobile.isNotEmpty) {
      setState(() => _isRefreshing = true);
      final isSub = await _bdapps.checkSubscription(mobile);
      final currentSub = quizProvider.isSubscribed || auth.isSubscribed;
      final finalState = isSub || currentSub;
      quizProvider.setSubscriptionState(finalState, mobile: mobile);
      auth.setSubscriptionState(finalState, mobile: mobile);
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider auth) {
    final nameCtrl = TextEditingController(text: auth.userName);
    final emailCtrl = TextEditingController(text: auth.userEmail ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit_rounded, color: Color(0xFFE11D48)),
            SizedBox(width: 8),
            Text('Edit Profile Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newName = nameCtrl.text.trim();
              if (newName.isNotEmpty) {
                auth.setUserName(newName);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showUnsubscribeDialog(BuildContext context) {
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

  void _showExamHistoryModal(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('📜 Exam History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestoreService.getUserExamHistory(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('No exam history found yet. Complete a quiz to view stats!'),
                    );
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      final score = data['totalScore'] ?? 0;
                      final maxScore = data['maxScore'] ?? 0;
                      final grade = data['grade'] ?? 'B';
                      final percentage = (data['percentage'] ?? 0).toStringAsFixed(0);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE11D48),
                            child: Text(grade, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          title: Text('Score: $score / $maxScore ($percentage%)', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Correct Answers: ${data['correctAnswers']} / ${data['totalQuestions']}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaderboardModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🏆 Global Leaderboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestoreService.getLeaderboard(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(child: Text('No leaderboard data yet. Be the first to score!'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data();
                      final name = data['name'] ?? 'Examinee';
                      final score = data['highScore'] ?? 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: index == 0 ? Colors.amber : (index == 1 ? Colors.grey : Colors.brown),
                            child: Text('#${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Text('$score Pts', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE11D48))),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final quizProvider = context.watch<QuizProvider>();
    final isSubscribed = quizProvider.isSubscribed || auth.isSubscribed;
    final mobileNumber = quizProvider.subscriberMobile ?? auth.userMobile ?? 'Not Linked';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.refresh_rounded),
            onPressed: _refreshSubscriptionStatus,
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _showEditProfileDialog(context, auth),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: const Color(0xFFFFECEB),
                  child: const Icon(Icons.person_rounded, size: 54, color: Color(0xFFE11D48)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                auth.userName ?? 'Learner',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              Text(
                auth.userEmail ?? 'No Email',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),

              // Profile Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.badge_outlined, color: Color(0xFF6366F1)),
                      title: const Text('Name', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(auth.userName ?? 'Learner', style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF6366F1)),
                        onPressed: () => _showEditProfileDialog(context, auth),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email_outlined, color: Color(0xFF10B981)),
                      title: const Text('Gmail / Email', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(auth.userEmail ?? 'No Email', style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF10B981)),
                        onPressed: () => _showEditProfileDialog(context, auth),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.phone_iphone_rounded, color: Color(0xFFE11D48)),
                      title: const Text('BDapps Mobile Number', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(mobileNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSubscribed ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isSubscribed ? 'SUBSCRIBED' : 'DEMO MODE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSubscribed ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Unsubscribe Plan Button
              if (isSubscribed) ...[
                ElevatedButton.icon(
                  onPressed: () => _showUnsubscribeDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBE123C),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.cancel_rounded, color: Colors.white),
                  label: const Text('Unsubscribe Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
              ],

              // History & Leaderboard Buttons
              ElevatedButton.icon(
                onPressed: () => _showExamHistoryModal(context, auth.user?.uid ?? ''),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.history_rounded, color: Colors.white),
                label: const Text('📜 History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _showLeaderboardModal(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.emoji_events_rounded, color: Colors.white),
                label: const Text('🏆 Leaderboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),

              // Sign Out Button - Instantly clear session and redirect to /login
              OutlinedButton.icon(
                onPressed: () async {
                  await auth.signOut();
                  if (context.mounted) {
                    context.go(AppRouter.login);
                  }
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.logout_rounded, color: Color(0xFFE11D48)),
                label: const Text('Sign Out', style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
