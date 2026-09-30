import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/zconnect_logo.dart';
import '../../../shared/widgets/zc_widgets.dart';
import '../../../routes/app_routes.dart';
import '../../../features/shared/models/enums.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

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
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _auth.signIn(
      _emailCtrl.text.trim(),
      _passCtrl.text,
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
    final isDriver = _role == UserRole.driver;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkGrey),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    isDriver
                        ? 'assets/images/zconnect_dispatch.png'
                        : 'assets/images/zconnect_app.png',
                    width: 140, // Made it bigger to stand out
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  isDriver ? 'Driver Sign In' : 'Welcome back',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  isDriver
                      ? 'Sign in to manage your deliveries'
                      : 'Sign in to track and send parcels',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.warmGrey),
                ),
                const SizedBox(height: 40),

                ZCTextField(
                  label: 'Email or Phone',
                  hint: 'e.g. yourname@email.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please enter your email'
                      : null,
                ),
                const SizedBox(height: 16),

                // FIXED: Removed Obx() here because _obscure is not an Rx variable
                ZCTextField(
                  label: 'Password',
                  hint: '••••••••',
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
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please enter your password'
                      : null,
                ),

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                    child: const Text('Forgot password?',
                        style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 24),

                Obx(() => _auth.error.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(_auth.error.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 14)),
                      )
                    : const SizedBox()),

                Obx(() => ZCButton(
                      label: 'Sign In',
                      onPressed: _signIn,
                      isLoading: _auth.isLoading.value,
                    )),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.warmGrey)),
                    GestureDetector(
                      onTap: () =>
                          Get.toNamed(AppRoutes.signUp, arguments: _role),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold),
                      ),
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
