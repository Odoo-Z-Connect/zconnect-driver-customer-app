import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_client.dart';
import '../../shared/models/app_user.dart';
import '../../shared/models/enums.dart';

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rxn<AppUser> currentUser = Rxn<AppUser>();
  final RxString error = ''.obs;

  bool get isAuthenticated => currentUser.value != null;
  bool get isDriver => currentUser.value?.role == UserRole.driver;

  @override
  void onInit() {
    super.onInit();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    if (sessionId != null && sessionId.isNotEmpty) {
      await fetchProfile();
    }
  }

  Future<void> fetchProfile() async {
    try {
      final res = await ApiClient().dio.get('/me');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        final isDriver = data['role'] == 'driver';

        // Driver-specific data nested under 'driver' key (from /me endpoint)
        final dp = data['driver'];
        final licence = dp?['licence'];
        final primaryVehicle = dp?['primary_vehicle'];

        // Determine availability from driver_profile if available
        DriverAvailability avail = DriverAvailability.offline;
        final availStr = dp?['availability_status']?.toString();
        if (availStr == 'available') avail = DriverAvailability.online;

        currentUser.value = AppUser(
          id: data['id']?.toString() ?? data['uid']?.toString() ?? '',
          name: data['name']?.toString() ?? '',
          email: data['email']?.toString() ?? data['login']?.toString() ?? '',
          phone: data['phone']?.toString() ?? dp?['phone']?.toString() ?? '',
          address: data['address']?.toString() ??
              data['street']?.toString() ??
              dp?['street']?.toString() ??
              '',
          role: isDriver ? UserRole.driver : UserRole.customer,
          availability: avail,
          vehicleType: primaryVehicle?['name']?.toString(),
          vehiclePlate: primaryVehicle?['license_plate']?.toString(),
          driverCode: dp?['driver_code']?.toString(),
          licenceClass: licence?['class']?.toString(),
          licenceNumber: licence?['number']?.toString(),
          nationalId: dp?['national_id']?.toString(),
          verificationStatus: dp?['verification_status']?.toString(),
        );
      }
    } catch (e) {
      // Session might be expired
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_id');
      currentUser.value = null;
    }
  }

  Future<bool> signIn(String email, String password) async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await ApiClient().dio.post('/auth/login', data: {
        'login': email,
        'password': password,
      });

      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        final sessionId = data['session_id'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_id', sessionId);

        currentUser.value = AppUser(
          id: data['uid'].toString(),
          name: data['name'] ?? '',
          email: email,
          phone: '',
          role: data['role'] == 'driver' ? UserRole.driver : UserRole.customer,
          availability: DriverAvailability.offline,
        );

        // Fetch full profile to get phone and driver details
        await fetchProfile();
        return true;
      } else {
        error.value = 'Invalid credentials';
        return false;
      }
    } on DioException catch (e) {
      error.value = e.response?.data?['error']?['message'] ??
          'Login failed. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signUp(String name, String email, String phone, String password,
      [String? address]) async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await ApiClient().dio.post('/auth/signup', data: {
        'name': name,
        'login': email,
        'password': password,
        'phone': phone,
        if (address != null && address.trim().isNotEmpty)
          'address': address.trim(),
        if (address != null && address.trim().isNotEmpty)
          'street': address.trim(),
      });

      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        final sessionId = data['session_id'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_id', sessionId);

        currentUser.value = AppUser(
          id: data['uid'].toString(),
          name: data['name'] ?? '',
          email: email,
          phone: data['phone'] ?? phone,
          address: data['address'] ?? address,
          role: data['role'] == 'driver' ? UserRole.driver : UserRole.customer,
        );
        await fetchProfile();
        return true;
      } else {
        error.value = 'Signup failed';
        return false;
      }
    } on DioException catch (e) {
      error.value = e.response?.data?['error']?['message'] ??
          'Signup failed. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_id');
    currentUser.value = null;
  }

  Future<void> updateProfile(
      {String? name, String? phone, String? address}) async {
    if (currentUser.value == null) return;
    try {
      final res = await ApiClient().dio.put('/profile', data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      });
      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        currentUser.value = currentUser.value!.copyWith(
          name: data['name'] ?? name,
          phone: data['phone'] ?? phone,
          address: data['address'] ?? address ?? currentUser.value!.address,
        );
      }
    } catch (e) {
      currentUser.value = currentUser.value!.copyWith(
        name: name,
        phone: phone,
        address: address,
      );
    }
  }

  Future<void> toggleAvailability() async {
    if (currentUser.value?.role != UserRole.driver) return;

    final current = currentUser.value!.availability;
    final next = current == DriverAvailability.online
        ? DriverAvailability.offline
        : DriverAvailability.online;

    // Optimistically update UI immediately
    currentUser.value = currentUser.value!.copyWith(availability: next);

    try {
      final res = await ApiClient().dio.put('/profile', data: {
        'availability_status':
            next == DriverAvailability.online ? 'available' : 'unavailable',
        'is_online': next == DriverAvailability.online,
      });
      if (res.statusCode == 200 && res.data['success'] == true) {
        final dp = res.data['data']?['driver'];
        if (dp != null) {
          final isAvail = dp['availability_status'] == 'available';
          currentUser.value = currentUser.value!.copyWith(
            availability: isAvail
                ? DriverAvailability.online
                : DriverAvailability.offline,
          );
        }
      }
    } catch (e) {
      print('toggleAvailability error: $e');
    }
  }
}
