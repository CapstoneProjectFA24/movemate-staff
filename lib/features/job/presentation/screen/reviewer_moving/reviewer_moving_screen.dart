import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/driver_controller/driver_controller.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/stream_controller/job_stream_manager.dart';
import 'package:movemate_staff/features/drivers/presentation/widgets/draggable_sheet/location_draggable_sheet.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/assignment_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/models/user_model.dart';
import 'package:movemate_staff/utils/commons/functions/functions_common_export.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:vietmap_flutter_navigation/vietmap_flutter_navigation.dart';
import 'package:flutter_svg/flutter_svg.dart';

@RoutePage()
class ReviewerMovingScreen extends StatefulWidget {
  final BookingResponseEntity job;
  final BookingStatusResult bookingStatus;
  final WidgetRef ref;
  const ReviewerMovingScreen(
      {super.key,
      required this.job,
      required this.bookingStatus,
      required this.ref});
  static const String apiKey = APIConstants.apiVietMapKey;

  @override
  State<ReviewerMovingScreen> createState() => _ReviewerMovingScreenState();
}

class _ReviewerMovingScreenState extends State<ReviewerMovingScreen> {
  MapNavigationViewController? _navigationController;
  late MapOptions _navigationOption;
  final _vietmapNavigationPlugin = VietMapNavigationPlugin();
  bool _isMapReady = false; // Thêm biến để track trạng thái map
  final bool _showNavigationButton = true;
  Widget recenterButton = const SizedBox.shrink();
  Widget instructionImage = const SizedBox.shrink();
  bool _isNavigationStarted = false;
  RouteProgressEvent? routeProgressEvent;
  LatLng? _simulatedPosition; // Thêm biến để lưu vị trí giả lập
  Timer? _locationUpdateTimer;
  LatLng? _currentPosition;
  //Location tracking
  StreamSubscription<Position>? _positionStreamSubscription;
  UserModel? user;
  final DatabaseReference locationRef =
      FirebaseDatabase.instance.ref().child('tracking_locations');

  @override
  void initState() {
    super.initState();
    _initUserId();
    _initNavigation();
    _getCurrentLocation();
    _initUserIdAndStart();
  }

  Future<void> _initNavigation() async {
    if (!mounted) return;
    _navigationOption = _vietmapNavigationPlugin.getDefaultOptions();
    _navigationOption.simulateRoute = true;
    _navigationOption.apiKey = APIConstants.apiVietMapKey;
    _navigationOption.mapStyle =
        "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${APIConstants.apiVietMapKey}";
    _vietmapNavigationPlugin.setDefaultOptions(_navigationOption);
  }

  Future<void> _initUserId() async {
    user = await SharedPreferencesUtils.getInstance("user_token");
  }

  Future<void> _initUserIdAndStart() async {
    await _initUserId();
    if (mounted) {
      setState(() {
        _startTrackingLocation();
      });
    }
  }

  void _startTrackingLocation() {
    _positionStreamSubscription?.cancel();
    _locationUpdateTimer?.cancel();

    if (_navigationOption.simulateRoute!) {
      // Nếu đang trong chế độ giả lập, chỉ cần timer để kiểm tra _simulatedPosition
      _locationUpdateTimer =
          Timer.periodic(const Duration(seconds: 10), (timer) {
        if (_simulatedPosition != null && _isNavigationStarted) {
          _updateLocationRealtime(_simulatedPosition!, "REVIEWER");
          print('Simulated location updated to Firebase at ${DateTime.now()}');
        }
      });
    } else {
      // Nếu không phải giả lập, sử dụng vị trí GPS thực
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).listen((Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
          });
          _updateLocationRealtime(_currentPosition!, "REVIEWER");
        }
      });
    }
  }

  void _updateLocationRealtime(LatLng position, String role) {
    final String bookingId = widget.job.id.toString();
    if (user?.id != null) {
      locationRef.child('$bookingId/$role/${user?.id}').update({
        'lat': position.latitude,
        'long': position.longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  LatLng _getPickupPointLatLng() {
    final pickupPointCoordinates = widget.job.pickupPoint.split(',');
    return LatLng(
      double.parse(pickupPointCoordinates[0].trim()),
      double.parse(pickupPointCoordinates[1].trim()),
    );
  }

  void _updateLocationOnce(LatLng position, String role) {
    final String bookingId = widget.job.id.toString();
    if (user?.id != null) {
      locationRef.child('$bookingId/$role/${user?.id}').set({
        'lat': position.latitude,
        'long': position.longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
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
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      }

      if (_currentPosition != null) {
        // Kiểm tra dữ liệu vị trí trên Firebase trước khi build route
        LatLng? lastLocation = await _getLastLocationFromFirebase();
        if (lastLocation != null) {
          // Sử dụng vị trí từ Firebase
          await _buildInitialRoute(useFirebaseLocation: true);
          _updateLocationOnce(lastLocation, "REVIEWER");
        } else {
          // Sử dụng vị trí hiện tại
          await _buildInitialRoute(useFirebaseLocation: false);
          _updateLocationOnce(_currentPosition!, "REVIEWER");
        }
      } else {
        print("Invalid position. Unable to update location.");
      }
    } catch (e) {
      print("Không thể lấy vị trí hiện tại: $e");
    }
  }

  Future<LatLng?> _getLastLocationFromFirebase() async {
    final String bookingId = widget.job.id.toString();
    try {
      final snapshot =
          await locationRef.child('$bookingId/REVIEWER/${user?.id}').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return LatLng(
          data['lat'] as double,
          data['long'] as double,
        );
      }
      return null;
    } catch (e) {
      print("Error getting last location from Firebase: $e");
      return null;
    }
  }

  // void _buildInitialRoute({bool useFirebaseLocation = false}) async {
  //   if (_navigationController != null && _currentPosition != null) {
  //     LatLng waypoint;
  //     LatLng? startPosition;

  //     if (useFirebaseLocation) {
  //       // Lấy vị trí từ Firebase
  //       startPosition = await _getLastLocationFromFirebase();
  //     }
  //     startPosition ??= _currentPosition;
  //     if (startPosition != null) {
  //       waypoint = _getPickupPointLatLng();

  //       await _navigationController?.buildRoute(
  //         waypoints: [
  //           LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
  //           waypoint,
  //           // LatLng(10.751169, 106.607249),
  //           // LatLng(10.775458, 106.601052)
  //         ],
  //         profile: DrivingProfile.drivingTraffic,
  //       );
  //     }
  //   }
  // }

  Future<void> _buildInitialRoute({bool useFirebaseLocation = false}) async {
    if (_navigationController != null) {
      LatLng? startPosition;

      if (useFirebaseLocation) {
        // Lấy vị trí từ Firebase
        startPosition = await _getLastLocationFromFirebase();
      }

      // Nếu không lấy được từ Firebase thì dùng vị trí hiện tại
      startPosition ??= _currentPosition;

      if (startPosition != null) {
        LatLng waypoint = _getPickupPointLatLng();

        await _navigationController?.buildRoute(
          waypoints: [
            LatLng(startPosition.latitude, startPosition.longitude),
            waypoint,
          ],
          profile: DrivingProfile.drivingTraffic,
        );
      } else {
        print("No valid starting position available");
      }
    }
  }

  Future<void> _startNavigation() async {
    if (_isMapReady) {
      try {
        await _buildInitialRoute(useFirebaseLocation: true);
        setState(() {
          _isNavigationStarted = true;
        });
        await _navigationController?.startNavigation();
      } catch (e) {
        print("Lỗi khi bắt đầu điều hướng: $e");
        setState(() {
          _isNavigationStarted = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        _buildInitialRoute();
                        // _addMarkers();
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

                          if (_isNavigationStarted &&
                              routeProgressEvent.currentLocation != null) {
                            _simulatedPosition = LatLng(
                                routeProgressEvent.currentLocation!.latitude!
                                    .toDouble(),
                                routeProgressEvent.currentLocation!.longitude!
                                    .toDouble());

                            _updateLocationRealtime(
                              _simulatedPosition!,
                              "REVIEWER",
                            );
                          }
                        });
                      }
                    },
                  )
                ],
              ),
            )
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

  _setInstructionImage(String? modifier, String? type) {
    if (modifier != null && type != null) {
      List<String> data = [
        type.replaceAll(' ', '_'),
        modifier.replaceAll(' ', '_')
      ];
      String path = 'assets/navigation_symbol/${data.join('_')}.svg';
      setState(() {
        instructionImage = SvgPicture.asset(path, color: Colors.white);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    _positionStreamSubscription?.cancel();
    _locationUpdateTimer?.cancel();

    if (_navigationController != null) {
      _navigationController!.onDispose();
    }
  }
}
