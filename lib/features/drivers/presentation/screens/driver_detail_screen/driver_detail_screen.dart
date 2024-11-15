import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:movemate_staff/features/drivers/presentation/widgets/draggable_sheet/location_draggable_sheet.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/assignment_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/models/user_model.dart';
import 'package:movemate_staff/utils/commons/functions/functions_common_export.dart';
import 'package:movemate_staff/utils/commons/widgets/form_input/label_text.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
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
    _initUserIdAndStart();
  }

  Future<void> _initUserIdAndStart() async {
    await _initUserId();
    if (mounted) {
      setState(() {
        if (inPendingMoving == false) {
          _startTrackingLocation();
        }
      });
    }
  }

  bool get canStartMoving {
    final assignment = _getAssignmentForUser();
    final subStatus = assignment?.status;

    if (subStatus == null) return false;

    final bool isValidDate = _isBookingDateValid();

    return (widget.job.status == "COMING" && subStatus == "ASSIGNED") ||
        (widget.job.status == "IN_PROGRESS" &&
            (subStatus == "ARRIVED" ||
                (subStatus == "IN_PROGRESS" && isValidDate)));
  }

  bool get inPendingMoving {
    final assignment = _getAssignmentForUser();
    final subStatus = assignment?.status;

    if (subStatus == null) return false;

    final bool isValidDate = _isBookingDateValid();

    return (widget.job.status == "COMING" && subStatus == "WAITING") ||
        (subStatus == "ASSIGNED" && !isValidDate);
  }

  AssignmentsResponseEntity? _getAssignmentForUser() {
    return widget.job.assignments.firstWhere(
      (e) => e.userId == user?.id,
      orElse: () => AssignmentsResponseEntity(
        id: 0,
        userId: 0,
        bookingId: 0,
        status: '',
        staffType: '',
      ),
    );
  }

  bool _isBookingDateValid() {
    final now = DateTime.now();
    final format = DateFormat("MM/dd/yyyy HH:mm:ss");
    final bookingDateTime = format.parse(widget.job.bookingAt);
    return now.difference(bookingDateTime).inMinutes >= 30;
  }

  // void _updateLocation(Position position, String role) {
  //   final String bookingId = widget.job.id.toString();
  //   if (user?.id != null) {
  //     locationRef.child('$bookingId/$role/${user?.id}').set({
  //       'lat': position.latitude,
  //       'long': position.longitude,
  //       'timestamp': DateTime.now().millisecondsSinceEpoch,
  //     });
  //   }
  // }

  void _updateLocationOnce(Position position, String role) {
    final String bookingId = widget.job.id.toString();
    if (user?.id != null) {
      locationRef.child('$bookingId/$role/${user?.id}').set({
        'lat': position.latitude,
        'long': position.longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  void _updateLocationRealtime(Position position, String role) {
    final String bookingId = widget.job.id.toString();
    if (user?.id != null) {
      locationRef.child('$bookingId/$role/${user?.id}').update({
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
        _updateLocationRealtime(position, role);
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
        final assignment = _getAssignmentForUser();
        final subStatus = assignment?.status;
        if (subStatus == "INCOMING" || subStatus == "IN_PROGRESS") {
          _locationUpdateTimer =
              Timer.periodic(const Duration(seconds: 10), (timer) {
            if (_lastPosition != null) {
              _updateLocationRealtime(_lastPosition!, "DRIVER");
              print('Location updated to Firebase at ${DateTime.now()}');
            }
          });
        }
      }
    });
  }

  Future<void> _initUserId() async {
    user = await SharedPreferencesUtils.getInstance("user_token");
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

  void _addMarkers() async {
    if (_navigationController != null) {
      final assignment = _getAssignmentForUser();
      final subStatus = assignment?.status;

      // Parse coordinates
      List<String> pickupCoordinates = widget.job.pickupPoint.split(',');
      List<String> deliveryCoordinates = widget.job.deliveryPoint.split(',');

      LatLng pickupPoint = LatLng(double.parse(pickupCoordinates[0].trim()),
          double.parse(pickupCoordinates[1].trim()));

      LatLng deliveryPoint = LatLng(double.parse(deliveryCoordinates[0].trim()),
          double.parse(deliveryCoordinates[1].trim()));

      List<NavigationMarker> markers = [];

      // Add markers based on status
      if ((widget.job.status == "COMING" ||
              widget.job.status == "IN_PROGRESS") &&
          (subStatus == "WAITING" ||
              subStatus == "ASSIGNED" ||
              subStatus == "INCOMING")) {
        // Add pickup point marker
        markers.add(NavigationMarker(
            height: 80,
            width: 80,
            imagePath: "assets/images/movemate_logo.png", // Đổi icon phù hợp
            latLng: pickupPoint));
      } else if ((widget.job.status == "IN_PROGRESS") &&
          (subStatus == "IN_PROGRESS" || subStatus == "ARRIVED")) {
        // Add delivery point marker
        markers.add(NavigationMarker(
            height: 80,
            width: 80,
            imagePath:
                "assets/images/booking/vehicles/truck1.png", // Đổi icon phù hợp
            latLng: deliveryPoint));
      }

      // Add all markers to the map
      await _navigationController!.addImageMarkers(markers);
      print("Markers added successfully: ${markers.length} markers");
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
          _currentPosition = position;
          _updateLocationOnce(_currentPosition!, "DRIVER");
          _buildInitialRoute();
        });
      }
    } catch (e) {
      print("Không thể lấy vị trí hiện tại: $e");
    }
  }

  void _buildInitialRoute() {
    final assignment = _getAssignmentForUser();
    final subStatus = assignment?.status;

    if (_navigationController != null && _currentPosition != null) {
      LatLng waypoint;
      if ((widget.job.status == "COMING" ||
              widget.job.status == "IN_PROGRESS") &&
          (subStatus == "WAITING" ||
              subStatus == "ASSIGNED" ||
              subStatus == "INCOMING")) {
        List<String> pickupPointCoordinates = widget.job.pickupPoint.split(',');
        waypoint = LatLng(double.parse(pickupPointCoordinates[0].trim()),
            double.parse(pickupPointCoordinates[1].trim()));
      } else if ((widget.job.status == "IN_PROGRESS") &&
          (subStatus == "IN_PROGRESS" || subStatus == "ARRIVED")) {
        List<String> deliveryPointCoordinates =
            widget.job.deliveryPoint.split(',');
        waypoint = LatLng(double.parse(deliveryPointCoordinates[0].trim()),
            double.parse(deliveryPointCoordinates[1].trim()));
      } else {
        return;
      }

      print("waypoint $waypoint");
      _navigationController?.buildRoute(
        waypoints: [
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          waypoint
        ],
        profile: DrivingProfile.cycling,
      );
    }
  }

  Future<void> _startNavigation() async {
    if (_isMapReady) {
      try {
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

  void _stopNavigation() {
    setState(() {
      _isNavigationStarted = false;
    });
    _navigationController?.finishNavigation();
    _buildInitialRoute();
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
                        _addMarkers();
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
                    onArrival: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text("Bạn đã tới nơi vận chuyển "),
                                backgroundColor: AssetsConstants.whiteColor,
                                actions: [
                                  // TextButton(
                                  //   onPressed: () => Navigator.pop(context),
                                  //   child: const LabelText(
                                  //       content: "Đóng",
                                  //       size: 16,
                                  //       fontWeight: FontWeight.bold,
                                  //       color: AssetsConstants.blackColor),
                                  // ),
                                  TextButton(
                                    onPressed: () {
                                      print("log here go");
                                      // await ref
                                      //     .read(reviewerUpdateControllerProvider
                                      //         .notifier)
                                      //     .updateReviewerStatus(
                                      //         id: job.id, context: context);
                                      // fetchResult.refresh();
                                      Navigator.pop(context);
                                      setState(() {
                                        instructionImage =
                                            const SizedBox.shrink();
                                        routeProgressEvent = null;
                                        _stopNavigation();
                                      });
                                    },
                                    child: const LabelText(
                                        content: "Xác nhận đã tới",
                                        size: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AssetsConstants.primaryLight),
                                  ),
                                ],
                              ));
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
                            GestureDetector(
                              onTap: () => _handleBackNavigation(),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.black54,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Đã giao hàng',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
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
                      userId: user?.id,
                    ),
                  Positioned(
                    bottom: _isNavigationStarted ? 20 : 280,
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
                  if (canStartMoving)
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
    if (_navigationController != null) {
      _navigationController!.onDispose();
    }
    if (_isNavigationStarted) {
      _stopNavigation();
    }
    super.dispose();
  }

  void _handleBackNavigation() {
    _positionStreamSubscription?.cancel();
    _locationUpdateTimer?.cancel();
    if (_navigationController != null && _isNavigationStarted) {
      _stopNavigation();
    }
    Navigator.of(context).pop();
  }
}
