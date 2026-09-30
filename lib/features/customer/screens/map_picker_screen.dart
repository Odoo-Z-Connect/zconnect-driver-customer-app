import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../../../core/app_colors.dart';
import '../../../features/shared/models/shipment.dart';

/// Full-screen map with a draggable pin for location selection.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({
    super.key,
    required this.title,
    this.initial,
  });
  final String title;
  final AppLocation? initial;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapCtrl;
  LatLng _pinPosition = const LatLng(-17.8292, 31.0522); // Harare default
  String _address = 'Move map to select location';
  bool _loadingAddress = false;
  bool _locatingUser = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      // We don't have lat/lng stored in AppLocation yet, keep default
    }
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always) {
        await _goToMyLocation();
      }
    } catch (_) {}
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locatingUser = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final newPos = LatLng(pos.latitude, pos.longitude);
      _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(newPos, 15));
      setState(() {
        _pinPosition = newPos;
        _locatingUser = false;
      });
      _reverseGeocode(newPos);
    } catch (e) {
      setState(() => _locatingUser = false);
    }
  }

  // Replaced with inline onCameraMove
  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _loadingAddress = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json'
        '&lat=${pos.latitude}&lon=${pos.longitude}&addressdetails=1',
      );
      final res = await http.get(url, headers: {
        'User-Agent': 'ZConnectApp/1.0',
      }).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final display = data['display_name'] as String? ?? '';
        final addr = data['address'] as Map<String, dynamic>? ?? {};
        final city = addr['city'] ??
            addr['town'] ??
            addr['village'] ??
            addr['county'] ??
            '';

        setState(() {
          _address = display.isNotEmpty
              ? display
              : '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
          _loadingAddress = false;
        });
      } else {
        setState(() {
          _address =
              '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
          _loadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _address =
            '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
        _loadingAddress = false;
      });
    }
  }

  AppLocation _buildLocation() {
    // Parse a cleaner name from address
    final parts = _address.split(',');
    final name = parts.isNotEmpty ? parts.first.trim() : _address;
    final street =
        parts.length > 1 ? parts.sublist(0, 2).join(',').trim() : name;
    final city = parts.length > 2 ? parts[2].trim() : '';
    return AppLocation(
      id: '${_pinPosition.latitude},${_pinPosition.longitude}',
      name: name,
      address: street,
      city: city,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pinPosition,
              zoom: 13,
            ),
            onMapCreated: (controller) => _mapCtrl = controller,
            onCameraMove: (position) {
              setState(() {
                _pinPosition = position.target;
                _address = 'Searching…';
              });
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 700), () {
                _reverseGeocode(_pinPosition);
              });
            },
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
          ),

          // ── CENTRE PIN ─────────────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(Icons.location_pin,
                      color: Colors.white, size: 26),
                ),
                // Pin shadow triangle
                CustomPaint(
                  size: const Size(16, 10),
                  painter: _PinShadowPainter(),
                ),
              ],
            ),
          ),

          // ── TOP BAR ────────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8)
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: AppColors.darkGrey),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8)
                        ],
                      ),
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── MY LOCATION BUTTON ─────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: 200,
            child: GestureDetector(
              onTap: _goToMyLocation,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8)
                  ],
                ),
                child: _locatingUser
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primaryGreen),
                      )
                    : const Icon(Icons.my_location_rounded,
                        color: AppColors.primaryGreen, size: 22),
              ),
            ),
          ),

          // ── BOTTOM ADDRESS CARD ────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  )
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const Text(
                      'Selected Location',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.warmGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_on_rounded,
                              color: AppColors.primaryGreen, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _loadingAddress
                              ? Row(
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primaryGreen),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Finding address…',
                                        style: TextStyle(
                                            color: AppColors.warmGrey,
                                            fontSize: 13)),
                                  ],
                                )
                              : Text(
                                  _address,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkGrey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loadingAddress
                            ? null
                            : () => Navigator.pop(context, _buildLocation()),
                        icon: const Icon(Icons.check_circle_rounded,
                            size: 18, color: Colors.white),
                        label: const Text(
                          'Confirm Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          disabledBackgroundColor: AppColors.divider,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tiny downward triangle drawn under the pin circle
class _PinShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
