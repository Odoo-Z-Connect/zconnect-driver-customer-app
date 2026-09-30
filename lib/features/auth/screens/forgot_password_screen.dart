import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/zconnect_logo.dart';
import '../../../shared/widgets/zc_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _sent ? _successView(context) : _formView(context),
        ),
      ),
    );
  }

  Widget _formView(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Center(child: ZConnectLogo(size: 48)),
          const SizedBox(height: 32),
          Text('Reset Password',
              style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Enter your email and we\'ll send a reset link.\n(Demo: no email is actually sent.)',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.warmGrey, height: 1.5),
          ),
          const SizedBox(height: 32),
          ZCTextField(
            label: 'Email',
            hint: 'yourname@email.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.mail_outline_rounded),
            validator: (v) {
              if (v == null || v.trim().isEmpty)
                return 'Please enter your email';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 28),
          ZCButton(
              label: 'Send Reset Link', onPressed: _send, isLoading: _loading),
        ],
      ),
    );
  }

  Widget _successView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
              color: AppColors.lightGreen, shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_rounded,
              size: 40, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 24),
        Text('Check your inbox',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          'If an account exists for ${_emailCtrl.text}, a reset link will appear there.\n(Demo mode — no email sent.)',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.warmGrey, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ZCButton(label: 'Back to Sign In', onPressed: () => Get.back()),
      ],
    );
  }
}
