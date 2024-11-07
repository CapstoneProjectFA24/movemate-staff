import 'dart:math';

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:movemate_staff/features/drivers/presentation/widgets/draggable_sheet/location_draggable_sheet.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:vietmap_flutter_navigation/vietmap_flutter_navigation.dart';
import 'package:flutter_svg/flutter_svg.dart';

@RoutePage()
class DriverDetailScreen extends StatefulWidget {
  final BookingResponseEntity job;
  const DriverDetailScreen({super.key, required this.job});

  static const String apiKey = APIConstants.apiVietMapKey;

  @override
  State<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen> {
  MapNavigationViewController? _navigationController; // Thay đổi thành nullable
  late MapOptions _navigationOption;
  final _vietmapNavigationPlugin = VietMapNavigationPlugin();
  Position? _currentPosition; // Thay đổi thành nullable
  bool _isMapReady = false; // Thêm biến để track trạng thái map

  Widget recenterButton = const SizedBox.shrink();
  Widget instructionImage = const SizedBox.shrink();

  RouteProgressEvent? routeProgressEvent;

  @override
  void initState() {
    super.initState();
    _initNavigation();
    _getCurrentLocation();
  }

  Future<void> _initNavigation() async {
    if (!mounted) return;
    _navigationOption = _vietmapNavigationPlugin.getDefaultOptions();
    _navigationOption.simulateRoute = false;
    _navigationOption.apiKey = APIConstants.apiVietMapKey;
    _navigationOption.mapStyle =
        "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${APIConstants.apiVietMapKey}";
    _vietmapNavigationPlugin.setDefaultOptions(_navigationOption);
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Xử lý khi location service bị tắt
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _buildInitialRoute(); // Thêm hàm này để build route ngay khi có vị trí
        });
      }
    } catch (e) {
      print("Không thể lấy vị trí hiện tại: $e");
    }
  }

  void _buildInitialRoute() {
    if (_navigationController != null && _currentPosition != null) {
      List<String> deliveryPointCoordinates =
          widget.job.deliveryPoint.split(',');
      LatLng deliveryPoint = LatLng(
          double.parse(deliveryPointCoordinates[0].trim()),
          double.parse(deliveryPointCoordinates[1].trim()));

      _navigationController?.buildRoute(
        waypoints: [
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          deliveryPoint
        ],
        profile: DrivingProfile.cycling,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> deliveryPointCoordinates = widget.job.deliveryPoint.split(',');
    LatLng deliveryPoint = LatLng(
        double.parse(deliveryPointCoordinates[0].trim()),
        double.parse(deliveryPointCoordinates[1].trim()));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BannerInstructionView(
              routeProgressEvent: routeProgressEvent,
              instructionIcon: instructionImage,
            ),
            Expanded(
              child: Stack(
                children: [
                  NavigationView(
                    mapOptions: _navigationOption,
                    onMapCreated: (controller) {
                      setState(() {
                        _navigationController = controller;
                        _isMapReady = true;
                        _buildInitialRoute(); // Build route khi map đã sẵn sàng
                      });
                    },
                    onRouteProgressChange:
                        (RouteProgressEvent routeProgressEvent) {
                      if (mounted) {
                        setState(() {
                          this.routeProgressEvent = routeProgressEvent;
                          _setInstructionImage(
                              routeProgressEvent.currentModifier,
                              routeProgressEvent.currentModifierType);
                        });
                      }
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: BottomActionView(
                      recenterButton: recenterButton,
                      controller: _navigationController,
                      routeProgressEvent: routeProgressEvent,
                    ),
                  ),
                ],
              ),
            ),
            instructionImage,
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _isMapReady
                ? () async {
                    try {
                      await _navigationController?.startNavigation();
                    } catch (e) {
                      print("Lỗi khi bắt đầu điều hướng: $e");
                    }
                  }
                : null, // Disable nút khi map chưa sẵn sàng
            child: const Icon(Icons.directions),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _isMapReady
                ? () {
                    _navigationController?.overview();
                  }
                : null,
            child: const Icon(Icons.route),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _isMapReady
                ? () {
                    _navigationController?.recenter();
                  }
                : null,
            child: const Icon(Icons.center_focus_strong),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _isMapReady
                ? () {
                    _navigationController?.finishNavigation();
                  }
                : null,
            child: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  void _setInstructionImage(String? modifier, String? type) {
    if (modifier != null && type != null) {
      List<String> data = [
        type.replaceAll(' ', '_'),
        modifier.replaceAll(' ', '_')
      ];
      String path = 'assets/navigation_symbol/${data.join('_')}.svg';
      if (mounted) {
        setState(() {
          instructionImage = SvgPicture.asset(path, color: Colors.white);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          instructionImage = const SizedBox.shrink();
        });
      }
    }
  }

  @override
  void dispose() {
    _navigationController?.onDispose();
    super.dispose();
  }
}
