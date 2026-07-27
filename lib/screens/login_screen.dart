import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/provider/auth_provider.dart';
import 'package:quiz_master/provider/quiz_provider.dart';
import 'package:quiz_master/router/app_router.dart';
import 'package:quiz_master/services/bdapps_service.dart';

enum LoginStep { enterMobile, enterPassword, enterOtp, setPassword }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _mobileCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();

  final BDappsService _bdapps = BDappsService();

  LoginStep _currentStep = LoginStep.enterMobile;
  bool _isLoading = false;
  String _cleanMobile = '';
  String _referenceNo = '';
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _passwordCtrl.dispose();
    _otpCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  String _sanitizeMobile(String raw) {
    String digits = raw.replaceAll(RegExp(r'\D+'), '');
    if (digits.startsWith('880') && digits.length == 13) {
      digits = digits.substring(2);
    } else if (digits.length == 10 && digits.startsWith('1')) {
      digits = '0$digits';
    }
    return digits;
  }

  Future<void> _handleMobileSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final rawMobile = _mobileCtrl.text.trim();
    _cleanMobile = _sanitizeMobile(rawMobile);

    setState(() => _isLoading = true);

    final accountRes = await _bdapps.checkUserAccount(_cleanMobile);
    final isSubscribed = await _bdapps.checkSubscription(_cleanMobile);

    setState(() => _isLoading = false);

    final hasAccount = accountRes['hasAccount'] == true;
    final hasPassword = accountRes['hasPassword'] == true;

    if (!mounted) return;

    if (hasAccount && hasPassword) {
      // Account exists with a password -> Move to Enter Password step
      setState(() => _currentStep = LoginStep.enterPassword);
    } else if (isSubscribed && !hasPassword) {
      // Subscribed on BDApps but hasn't set password yet -> Move to Set Password step
      setState(() => _currentStep = LoginStep.setPassword);
    } else {
      // User is not registered in file or not subscribed -> Prompt options
      _showUnsubscribedPrompt();
    }
  }

  void _showUnsubscribedPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Color(0xFFE11D48)),
            SizedBox(width: 8),
            Text('Account Setup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mobile: +88 $_cleanMobile',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: Not Registered / Subscribed',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFBE123C), fontSize: 13),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tariff: 2.00 BDT + VAT + SD + SC / day.\nFor Robi & Airtel users (Auto-renewable).',
                    style: TextStyle(fontSize: 11, color: Color(0xFF881337)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Choose how to enter Prostuti:',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _enterDemoMode();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF64748B)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Demo Mode', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _triggerSendOtp();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Send OTP to Subscribe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerSendOtp() async {
    setState(() => _isLoading = true);
    final result = await _bdapps.sendOtp(_cleanMobile);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['alreadySubscribed'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ℹ️ Your mobile number is already subscribed! Please set your password.'),
          backgroundColor: Color(0xFF0284C7),
        ),
      );
      setState(() => _currentStep = LoginStep.setPassword);
      return;
    }

    final ref = result['referenceNo']?.toString() ?? '';
    if (result['success'] == true && ref.isNotEmpty) {
      _referenceNo = ref;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📩 OTP PIN code sent to +88 $_cleanMobile'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _currentStep = LoginStep.enterOtp);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Failed to send OTP.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleOtpVerify() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid OTP PIN'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await _bdapps.verifyOtp(_cleanMobile, otp, _referenceNo);
    setState(() => _isLoading = false);

    if (!mounted) return;

    final isSuccess = result['statusCode'] == 'S1000' ||
        result['subscriptionStatus'] == 'REGISTERED';

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 OTP Verified! Please set a password for your account.'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _currentStep = LoginStep.setPassword);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['statusDetail']?.toString() ?? 'OTP verification failed.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSetPassword() async {
    final newPass = _newPasswordCtrl.text.trim();
    if (newPass.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 4 characters'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final saved = await _bdapps.setUserPassword(_cleanMobile, newPass);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (saved) {
      final auth = context.read<AuthProvider>();
      final quizProvider = context.read<QuizProvider>();

      await auth.loginWithMobileDirect(_cleanMobile, forceSubscribed: true);
      quizProvider.setSubscriptionState(true, mobile: _cleanMobile);
      auth.setSubscriptionState(true, mobile: _cleanMobile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Subscription & Account Password Created Successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        context.go(AppRouter.home);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save password. Try again.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handlePasswordLogin() async {
    final password = _passwordCtrl.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await _bdapps.verifyUserPassword(_cleanMobile, password);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      final auth = context.read<AuthProvider>();
      final quizProvider = context.read<QuizProvider>();

      await auth.loginWithMobileDirect(_cleanMobile, forceSubscribed: true);
      quizProvider.setSubscriptionState(true, mobile: _cleanMobile);
      auth.setSubscriptionState(true, mobile: _cleanMobile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Welcome back! Pro Mode Unlocked.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        context.go(AppRouter.home);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Incorrect password. Try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleForgotPassword() async {
    setState(() => _isLoading = true);
    final res = await _bdapps.sendOtp(_cleanMobile);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res['alreadySubscribed'] == true) {
      setState(() {
        _currentStep = LoginStep.setPassword;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔑 Verified! Enter a new password for your account.'),
          backgroundColor: Colors.blue,
        ),
      );
    } else if (res['success'] == true && (res['referenceNo'] ?? '').toString().isNotEmpty) {
      _referenceNo = res['referenceNo'].toString();
      setState(() {
        _currentStep = LoginStep.enterOtp;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📩 OTP sent to reset your password. Enter the PIN below.'),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']?.toString() ?? 'Failed to send OTP to reset password.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _enterDemoMode() async {
    final auth = context.read<AuthProvider>();
    final quizProvider = context.read<QuizProvider>();

    await auth.loginWithMobileDirect(_cleanMobile, forceSubscribed: false);
    quizProvider.setSubscriptionState(false, mobile: _cleanMobile);
    auth.setSubscriptionState(false, mobile: _cleanMobile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ℹ️ Entered Demo Mode (20 MCQs limit, locked tabs). Subscribe anytime.'),
          backgroundColor: Color(0xFF0284C7),
          duration: Duration(seconds: 4),
        ),
      );
      context.go(AppRouter.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE11D48).withValues(alpha: 0.2),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFE11D48),
                              child: const Icon(Icons.school_rounded, color: Colors.white, size: 44),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome to Prostuti',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 6),

                    if (_currentStep == LoginStep.enterMobile) ...[
                      const Text(
                        'Enter your Robi / Airtel mobile number to check subscription and start practicing:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _mobileCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          hintText: '018XXXXXXXX',
                          prefixText: '+88 ',
                          prefixStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          prefixIcon: const Icon(Icons.phone_iphone_rounded, color: Color(0xFFE11D48)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFE11D48), width: 2),
                          ),
                        ),
                        validator: (v) {
                          final digits = (v ?? '').replaceAll(RegExp(r'\D+'), '');
                          if (digits.length < 11) return 'Enter an 11-digit mobile number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleMobileSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 4,
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                ],
                              ),
                      ),
                    ],

                    if (_currentStep == LoginStep.enterPassword) ...[
                      Text(
                        'Account found for +88 $_cleanMobile.\nEnter your password to log in:',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: !_isPasswordVisible,
                        keyboardType: TextInputType.visiblePassword,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFFE11D48)),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _isLoading ? null : _handleForgotPassword,
                          icon: const Icon(Icons.lock_reset_rounded, size: 18, color: Color(0xFFE11D48)),
                          label: const Text(
                            'Forgot Password? (Reset via OTP)',
                            style: TextStyle(
                              color: Color(0xFFE11D48),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handlePasswordLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : const Text('Login & Start', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => setState(() => _currentStep = LoginStep.enterMobile),
                        child: const Text('← Change Mobile Number', style: TextStyle(color: Color(0xFF64748B))),
                      ),
                    ],

                    if (_currentStep == LoginStep.enterOtp) ...[
                      Text(
                        'OTP PIN code sent to +88 $_cleanMobile.\nEnter the 4-6 digit PIN to verify:',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _otpCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: '••••',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleOtpVerify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : const Text('Confirm PIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => setState(() => _currentStep = LoginStep.enterMobile),
                        child: const Text('← Back', style: TextStyle(color: Color(0xFF64748B))),
                      ),
                    ],

                    if (_currentStep == LoginStep.setPassword) ...[
                      Text(
                        'Set a password for your account (+88 $_cleanMobile).\nYou will use this password for future logins:',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _newPasswordCtrl,
                        obscureText: !_isPasswordVisible,
                        keyboardType: TextInputType.visiblePassword,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          labelText: 'Create Password',
                          prefixIcon: const Icon(Icons.key_rounded, color: Color(0xFFE11D48)),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : const Text('Save Password & Start', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
