import 'package:get/get.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/sign_in_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/customer/screens/customer_shell.dart';
import '../features/customer/screens/new_shipment_screen.dart';
import '../features/driver/screens/driver_shell.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String customerShell = '/customer';
  static const String customerShipments = '/customer/shipments';
  static const String newShipment = '/customer/new-shipment';
  static const String driverShell = '/driver';

  static final List<GetPage> pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: welcome, page: () => const WelcomeScreen()),
    GetPage(
      name: signIn,
      page: () => const SignInScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: signUp,
      page: () => const SignUpScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: customerShell,
      page: () => const CustomerShell(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: newShipment,
      page: () => const NewShipmentScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: driverShell,
      page: () => const DriverShell(),
      transition: Transition.fadeIn,
    ),
  ];
}
