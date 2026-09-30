import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/zconnect_logo.dart';
import '../../../shared/widgets/zc_widgets.dart';
import '../../../routes/app_routes.dart';
import '../../../features/shared/models/enums.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  late UserRole _role;
  late AuthController _auth;

  @override
  void initState() {
    super.initState();
    _role = Get.arguments is UserRole
        ? Get.arguments as UserRole
        : UserRole.customer;
    _auth = Get.find<AuthController>();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _auth.signUp(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _phoneCtrl.text.trim(),
      _passCtrl.text,
      _addressCtrl.text.trim(),
    );
    if (ok) {
      if (_role == UserRole.customer) {
        Get.offAllNamed(AppRoutes.customerShell);
      } else {
        Get.offAllNamed(AppRoutes.driverShell);
      }
    }
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Center(child: ZConnectLogo(size: 48)),
                const SizedBox(height: 28),
                Text('Create an account',
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 6),
                Text(
                  'Sign up as a ${_role == UserRole.driver ? "driver" : "customer"}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.warmGrey),
                ),
                const SizedBox(height: 32),
                ZCTextField(
                  label: 'Full Name',
                  hint: 'Your full name',
                  controller: _nameCtrl,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please enter your name'
                      : null,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                ZCTextField(
                  label: 'Phone Number',
                  hint: '+263 77 000 0000',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please enter your phone number'
                      : null,
                ),
                const SizedBox(height: 16),
                ZCTextField(
                  label: 'Address (optional)',
                  hint: '123 Main Street, Harare',
                  controller: _addressCtrl,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                const SizedBox(height: 16),
                ZCTextField(
                  label: 'Password',
                  hint: 'Min. 6 characters',
                  controller: _passCtrl,
                  obscureText: _obscure,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Please enter a password';
                    if (v.length < 6)
                      return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ZCTextField(
                  label: 'Confirm Password',
                  hint: '••••••••',
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Please confirm your password';
                    if (v != _passCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                Obx(() => _auth.error.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_auth.error.value,
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 13)),
                      )
                    : const SizedBox()),
                Obx(() => ZCButton(
                      label: 'Create Account',
                      onPressed: _signUp,
                      isLoading: _auth.isLoading.value,
                    )),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.warmGrey)),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
