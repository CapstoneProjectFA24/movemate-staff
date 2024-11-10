import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';

import 'package:movemate_staff/features/porter/presentation/widgets/draggable_sheet/location_draggable_sheet.dart';
import 'package:movemate_staff/features/porter/presentation/widgets/map_widget/location_info_card.dart';

import 'package:movemate_staff/services/map_services/location_service.dart';
import 'package:movemate_staff/services/map_services/map_service.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vietmap_flutter_navigation/embedded/controller.dart';
import 'package:vietmap_flutter_navigation/models/options.dart';
import 'package:vietmap_flutter_navigation/models/route_progress_event.dart';
import 'package:vietmap_flutter_navigation/navigation_plugin.dart';
import 'package:vietmap_flutter_navigation/vietmap_flutter_navigation.dart';
import 'package:vietmap_flutter_navigation/views/banner_instruction.dart';
import 'package:vietmap_flutter_navigation/views/bottom_action.dart';

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});
}

class Booking {
  final String id;
  final String name;
  final Location? pickUpLocation;
  final Location? dropOffLocation;

  Booking({
    required this.id,
    required this.name,
    this.pickUpLocation,
    this.dropOffLocation,
  });
}

final fakeBookingProvider = Provider<Booking>((ref) {
  return Booking(
    id: 'fake_booking_123',
    name: 'Test Booking',
    pickUpLocation: Location(
      latitude: 10.762622,
      longitude: 106.660172,
    ),
    dropOffLocation: Location(
      latitude: 10.776889,
      longitude: 106.700981,
    ),
  );
});

@RoutePage()
class PorterDetailScreen extends StatefulWidget {
  final BookingResponseEntity job;
  const PorterDetailScreen({super.key, required this.job});

  static const String apiKey = APIConstants.apiVietMapKey;

  @override
  State<PorterDetailScreen> createState() => _PorterDetailScreenScreenState();
}

class _PorterDetailScreenScreenState extends State<PorterDetailScreen> {
  MapNavigationViewController? _navigationController; // Thay đổi thành nullable
  late MapOptions _navigationOption;
  final _vietmapNavigationPlugin = VietMapNavigationPlugin();
  Position? _currentPosition; // Thay đổi thành nullable
  bool _isMapReady = false; // Thêm biến để track trạng thái map
  bool _showNavigationButton = true;
  Widget recenterButton = const SizedBox.shrink();
  Widget instructionImage = const SizedBox.shrink();
  bool _isNavigationStarted = false;
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

  // Thêm hàm để xử lý bắt đầu điều hướng
  Future<void> _startNavigation() async {
    if (_isMapReady) {
      try {
        setState(() {
          _isNavigationStarted = true;
        });
        await _navigationController?.startNavigation();
      } catch (e) {
        print("Lỗi khi bắt đầu điều hướng: $e");
        // Nếu có lỗi, đặt lại trạng thái
        setState(() {
          _isNavigationStarted = false;
        });
      }
    }
  }

  // Thêm hàm để xử lý kết thúc điều hướng
  void _stopNavigation() {
    setState(() {
      _isNavigationStarted = false;
    });
    _navigationController?.finishNavigation();
    _buildInitialRoute(); // Xây dựng lại tuyến đường ban đầu
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
                  if (!_isNavigationStarted)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 14.0, right: 14.0, top: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Back Button
                            GestureDetector(
                              onTap: () => context.router.pop(),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.black54,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Title
                            const Text(
                              'Đã giao hàng',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            // Support Icon
                            IconButton(
                              icon: const Icon(
                                Icons.headset_mic_outlined,
                                color: Colors.black54,
                                size: 24,
                              ),
                              onPressed: () {
                                // Add support action
                              },
                            ),
                            // Help Icon
                            IconButton(
                              icon: const Icon(
                                Icons.help_outline,
                                color: Colors.black54,
                                size: 24,
                              ),
                              onPressed: () {
                                // Add help action
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!_isNavigationStarted)
                    DeliveryDetailsBottomSheet(
                      job: widget.job,
                    ),
                  Positioned(
                    bottom: _isNavigationStarted
                        ? 20
                        : 280, // Điều chỉnh vị trí dựa trên trạng thái điều hướng
                    left: 0,
                    right: 0,
                    child: BottomActionView(
                      onStopNavigationCallback: () {
                        setState(() {
                          instructionImage = const SizedBox.shrink();
                          routeProgressEvent = null;
                          _stopNavigation();
                        });
                      },
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
      floatingActionButton: _showNavigationButton
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!_isNavigationStarted)
                  FloatingActionButton(
                    onPressed: _isMapReady ? _startNavigation : null,
                    child: const Icon(Icons.directions),
                  ),

              ],
            )
          : null,
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
