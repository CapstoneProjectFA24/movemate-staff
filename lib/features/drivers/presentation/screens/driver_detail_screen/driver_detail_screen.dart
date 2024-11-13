import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:geolocator/geolocator.dart';
import 'package:movemate_staff/features/drivers/presentation/widgets/draggable_sheet/location_draggable_sheet.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/models/user_model.dart';
import 'package:movemate_staff/utils/commons/functions/functions_common_export.dart';
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
  MapNavigationViewController? _navigationController;
  late MapOptions _navigationOption;
  final _vietmapNavigationPlugin = VietMapNavigationPlugin();
  Position? _currentPosition;
  Position? _lastPosition;
  bool _isMapReady = false; // Thêm biến để track trạng thái map
  bool _showNavigationButton = true;
  Widget recenterButton = const SizedBox.shrink();
  Widget instructionImage = const SizedBox.shrink();
  bool _isNavigationStarted = false;
  RouteProgressEvent? routeProgressEvent;

  //Location tracking
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _locationUpdateTimer;

  // realtime
  UserModel? user;
  final DatabaseReference locationRef =
      FirebaseDatabase.instance.ref().child('tracking_locations');

  @override
  void initState() {
    super.initState();
    _initUserId();
    _initNavigation();
    _getCurrentLocation();
    _startTrackingLocation();
  }

  void _updateLocation(Position position, String role) {
    final String bookingId = widget.job.id.toString();
    if (user?.id != null) {
      locationRef.child('$bookingId/$role/${user?.id}').set({
        'lat': position.latitude,
        'long': position.longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  void updateLocationFormStaff(Position position) {
    for (var assignment in widget.job.assignments) {
      if (assignment.userId == user?.id) {
        String role = assignment.staffType;
        _updateLocation(position, role);
        break;
      }
    }
  }

  void _startTrackingLocation() {
    _positionStreamSubscription?.cancel();
    _locationUpdateTimer?.cancel();

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // chỉnh ở đây nếu muốn timing nhanh hơn nhé
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _lastPosition = position;
        });

        _locationUpdateTimer =
            Timer.periodic(const Duration(seconds: 10), (timer) {
          if (_lastPosition != null) {
            updateLocationFormStaff(_lastPosition!);
            print('Location updated to Firebase at ${DateTime.now()}');
          }
        });
      }
    });
  }

  Future<void> _initUserId() async {
    user = await SharedPreferencesUtils.getInstance("user_token");
  }

  Future<void> _initNavigation() async {
    if (!mounted) return;
    _navigationOption = _vietmapNavigationPlugin.getDefaultOptions();
    _navigationOption.simulateRoute =
        true; // chỉnh lại true khi muốn test trên máy thật
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
    _positionStreamSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    _getCurrentLocation();
    _startTrackingLocation();
    if (_navigationController != null) {
      _navigationController!.onDispose();
    }
    if (_isNavigationStarted) {
      _stopNavigation();
    }
    super.dispose();
  }
}
