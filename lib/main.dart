import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/app_theme.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/shared/services/shipment_repository.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const ZConnectApp());
}

class ZConnectApp extends StatelessWidget {
  const ZConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ZConnect',
      debugShowCheckedModeBanner: false,
      theme: ZConnectTheme.light,

      // Initialise global controllers before any screen is shown
      initialBinding: BindingsBuilder(() {
        Get.put<AuthController>(AuthController(), permanent: true);
        Get.put<ShipmentRepository>(ShipmentRepository(), permanent: true);
      }),

      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,

      // Constrain width for tablet/web layouts
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
