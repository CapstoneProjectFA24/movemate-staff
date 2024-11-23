import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/stream_controller/job_stream_manager.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/assignment_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/porter/presentation/controllers/porter_controller.dart';
import 'package:movemate_staff/features/porter/presentation/widgets/draggable_sheet/location_draggable_sheet.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/models/user_model.dart';
import 'package:movemate_staff/utils/commons/functions/functions_common_export.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vietmap_flutter_navigation/vietmap_flutter_navigation.dart';
import 'package:flutter_svg/flutter_svg.dart';

@RoutePage()
class PorterDetailScreen extends StatefulWidget {
  final BookingResponseEntity job;
  final BookingStatusResult bookingStatus;
  final WidgetRef ref;

  const PorterDetailScreen(
      {super.key,
      required this.job,
      required this.bookingStatus,
      required this.ref});

  static const String apiKey = APIConstants.apiVietMapKey;

  @override
  State<PorterDetailScreen> createState() => _PorterDetailScreenScreenState();
}

class _PorterDetailScreenScreenState extends State<PorterDetailScreen> {
  MapNavigationViewController? _navigationController;
  late MapOptions _navigationOption;
  final _vietmapNavigationPlugin = VietMapNavigationPlugin();
  LatLng? _currentPosition;
  LatLng? _lastPosition;
  bool _isMapReady = false; // Thêm biến để track trạng thái map
  bool _showNavigationButton = true;
  Widget recenterButton = const SizedBox.shrink();
  Widget instructionImage = const SizedBox.shrink();
  bool _isNavigationStarted = false;
  RouteProgressEvent? routeProgressEvent;
  LatLng? _simulatedPosition; // Thêm biến để lưu vị trí giả lập
  //Location tracking
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _locationUpdateTimer;
  bool _isFirstNavigation = true; // Add this flag
  LatLng? _nextDestination; // Add this to store next destination
  // realtime
  UserModel? user;
  final DatabaseReference locationRef =
      FirebaseDatabase.instance.ref().child('tracking_locations');

  late StreamSubscription<BookingResponseEntity> _jobSubscription;
  late BookingResponseEntity _currentJob;

  @override
  void initState() {
    super.initState();

    _currentJob = widget.job;
    _initStreams();
    _initUserId();
    _initNavigation();
    _getCurrentLocation();
    _initUserIdAndStart();
  }

  void _initStreams() {
    _jobSubscription = JobStreamManager().jobStream.listen((updateJob) {
      if (updateJob.id == widget.job.id) {
        print(
            'tuan Received updated order in ReviewerTrackingMap: ${updateJob.id}');
        setState(() {
          _currentJob = updateJob;
          // _buildInitialRoute();
        });
      }
    });
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

  Future<void> _initUserIdAndStart() async {
    await _initUserId();
    if (mounted) {
      setState(() {
        _startTrackingLocation();
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

  LatLng _getDeliveryPointLatLng() {
    final deliveryPointCoordinates = widget.job.deliveryPoint.split(',');
    return LatLng(
      double.parse(deliveryPointCoordinates[0].trim()),
      double.parse(deliveryPointCoordinates[1].trim()),
    );
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

  void updateLocationFormStaff(LatLng position) {
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

    if (_navigationOption.simulateRoute!) {
      // Nếu đang trong chế độ giả lập, chỉ cần timer để kiểm tra _simulatedPosition
      _locationUpdateTimer =
          Timer.periodic(const Duration(seconds: 10), (timer) {
        if (_simulatedPosition != null && _isNavigationStarted) {
          _updateLocationRealtime(_simulatedPosition!, "PORTER");
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
          _updateLocationRealtime(_currentPosition!, "PORTER");
        }
      });
    }
  }

  Future<void> _initUserId() async {
    user = await SharedPreferencesUtils.getInstance("user_token");
  }

  void _addMarkers() async {
    if (_navigationController != null) {
      final assignment = _getAssignmentForUser();
      final subStatus = assignment?.status;

      // Parse coordinates

      LatLng pickupPoint = _getPickupPointLatLng();

      LatLng deliveryPoint = _getDeliveryPointLatLng();

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
          if (widget.bookingStatus.isPorterStartPoint) {
            _currentPosition = LatLng(position.latitude, position.longitude);
          } else if (widget.bookingStatus.isPorterAtDeliveryPoint) {
            _currentPosition = _getPickupPointLatLng();
          } else if (widget.bookingStatus.isPorterEndDeliveryPoint) {
            _currentPosition = _getDeliveryPointLatLng();
          }

          if (_currentPosition != null) {
            _updateLocationOnce(_currentPosition!, "PORTER");
            _buildInitialRoute();
          } else {
            print("Invalid position. Unable to update location.");
          }
        });
      }
    } catch (e) {
      print("Không thể lấy vị trí hiện tại: $e");
    }
  }

  void _buildInitialRoute() async {
    // flag ở đây check xóa sau

    if (_navigationController != null && _currentPosition != null) {
      if (_currentPosition != null) {
        print("Current Position: $_currentPosition");
      } else {
        print("Current Position is null");
      }
      LatLng waypoint;
      if (widget.bookingStatus.isPorterStartPoint) {
        print("vinh log status build route 1");
        waypoint = _getPickupPointLatLng();
        _nextDestination = _getDeliveryPointLatLng();
      } else if (widget.bookingStatus.isPorterAtDeliveryPoint) {
        print("vinh log status build route 2");
        waypoint = _getDeliveryPointLatLng();
      } else if (widget.bookingStatus.isPorterEndDeliveryPoint) {
        print("vinh log status build route 3");
        waypoint = _getDeliveryPointLatLng();
      } else {
        return;
      }

      await _navigationController?.buildRoute(
        waypoints: [
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          waypoint,
          // LatLng(10.751169, 106.607249),
          // LatLng(10.775458, 106.601052)
        ],
        profile: DrivingProfile.drivingTraffic,
      );
    }
  }

  Future<void> _startNextRoute() async {
    if (_nextDestination != null && _currentPosition != null) {
      // Chỉ xây dựng lại lộ trình từ B đến C mà không bắt đầu điều hướng
      await _navigationController?.buildRoute(
        waypoints: [
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          _nextDestination!
        ],
        profile: DrivingProfile.drivingTraffic,
      );

      // Đợi người dùng xác nhận để bắt đầu điều hướng
      setState(() {
        _isFirstNavigation = false;
      });
    }
  }

  void onUserStartNavigation() async {
    setState(() {
      _isNavigationStarted = true;
    });

    await _navigationController?.startNavigation();
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

  Future<void> _startAssinedToComing() async {
    if (_isMapReady) {
      try {
        setState(() {
          _isNavigationStarted = true;
        });

        await _navigationController?.startNavigation();
        try {
          await widget.ref
              .read(porterControllerProvider.notifier)
              .updateStatusPorterWithoutResourse(
                id: widget.job.id,
                context: context,
              );
        } catch (driverError) {
          print(
              "Lỗi khi bắt đầu điều hướng từ assined lên incoming: $driverError");
        }
      } catch (e) {
        print("Lỗi khi bắt đầu di chuyển $e");
        setState(() {
          _isNavigationStarted = false;
        });
      }
    }
  }

  Future<void> _startPackingToOngoing() async {
    if (_isMapReady) {
      try {
        setState(() {
          _isNavigationStarted = true;
        });

        await _navigationController?.startNavigation();
        try {
          await widget.ref
              .read(porterControllerProvider.notifier)
              .updateStatusPorterWithoutResourse(
                id: widget.job.id,
                context: context,
              );
        } catch (driverError) {
          print(
              "Lỗi khi bắt đầu điều hướng  inprogres lên ongoing: ${driverError.toString()}");
        }
      } catch (e) {
        print("Lỗi khi bắt đầu di chuyển $e");
        setState(() {
          _isNavigationStarted = false;
        });
      }
    }
  }

  Future<void> _startArrivedtoProgress() async {
    if (_isMapReady) {
      try {
        await widget.ref
            .read(porterControllerProvider.notifier)
            .updateStatusPorterWithoutResourse(
              id: widget.job.id,
              context: context,
            );
        context.router.push(PorterConfirmScreenRoute(
          job: _currentJob,
        ));
      } catch (driverError) {
        print(
            "Lỗi khi bắt đầu điều hướng  inprogres lên ongoing: ${driverError.toString()}");
      }
    }
  }

  void _stopNavigation() {
    setState(() {
      _isNavigationStarted = false;
      routeProgressEvent = null;
    });
    // _navigationController?.clearRoute();  //Clear the built route and resets the map
    _navigationController
        ?.finishNavigation(); //Ends Navigation and Closes the Navigation View
    // _navigationController?.buildRoute(); //
    // Build the Route Used for the Navigation

// [waypoints] must not be null. A collection of [LatLng](longitude, latitude and name). Must be at least 2 or at most 25. Cannot use drivingWithTraffic mode if more than 3-waypoints. [options] options used to generate the route and used while navigating
    _buildInitialRoute();
  }

  void _finishNavigation() {
    setState(() {
      _isNavigationStarted = false;
    });
    _navigationController?.finishNavigation();
    _buildInitialRoute();
  }

  @override
  Widget build(BuildContext context) {
    // print("vinh log status ${widget.bookingStatus.isPorterStartPoint}");
    // print("vinh log status1 ${widget.bookingStatus.isPorterAtDeliveryPoint}");
    // print("vinh log status2 ${widget.bookingStatus.isPorterEndDeliveryPoint}");
    // print("vinh log status3 ${widget.bookingStatus.canPorterConfirmIncoming}");
    // print("vinh log status4 ${widget.bookingStatus.canPorterConfirmArrived}");
    // print(
    //     "vinh log status5 ${widget.bookingStatus.canPorterConfirmInprogress}");
    // print("vinh log status6 ${widget.bookingStatus.canPorterConfirmOngoing}");
    // print("vinh log status7 ${widget.bookingStatus.canPorterConfirmDelivered}");
    // print(
    //     "vinh log status8 ${widget.bookingStatus.canPorterCompleteUnloading}");
    // print("vinh log status9 ${widget.bookingStatus.canPorterComplete}");

    print(
        "updating status 0 ConfirmIncoming :  ${widget.bookingStatus.canPorterConfirmIncoming}");
    print(
        "updating status 1 ConfirmArrived :  ${widget.bookingStatus.canPorterConfirmArrived}");
    print(
        "updating status 2 ConfirmInprogress :  ${widget.bookingStatus.canPorterConfirmInprogress}");
    print(
        "updating status 3 ConfirmPacking :  ${widget.bookingStatus.canPorterConfirmPacking}");
    print(
        "updating status 4 ConfirmOngoing :  ${widget.bookingStatus.canPorterConfirmOngoing}");
    print(
        "updating status 5 ConfirmDelivered :  ${widget.bookingStatus.canPorterConfirmDelivered}");
    print(
        "updating status 6 CompleteUnloading :  ${widget.bookingStatus.canPorterCompleteUnloading}");
    print(
        "updating status 7 Complete :  ${widget.bookingStatus.canPorterComplete}");

    print(
        " updating vinh log status realtime ${_currentJob.assignments.map((e) => e.toJson())}");

    if (_currentPosition != null) {
      print("Current Position: $_currentPosition");
    } else {
      print("Current Position is null");
    }
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

                          if (_isNavigationStarted &&
                              routeProgressEvent.currentLocation != null) {
                            _simulatedPosition = LatLng(
                                routeProgressEvent.currentLocation!.latitude!
                                    .toDouble(),
                                routeProgressEvent.currentLocation!.longitude!
                                    .toDouble());

                            _updateLocationRealtime(
                              _simulatedPosition!,
                              "PORTER",
                            );

                            if (routeProgressEvent.distanceRemaining != null &&
                                routeProgressEvent.distanceRemaining! <= 50) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: AssetsConstants.primaryLight,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _isFirstNavigation
                                                  ? "Đã đến điểm nhận hàng"
                                                  : "Đã đến điểm giao hàng",
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    AssetsConstants.blackColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Vui lòng xác nhận để tiếp tục",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AssetsConstants
                                                    .blackColor
                                                    .withOpacity(0.7),
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: AssetsConstants.whiteColor,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(24, 20, 24, 0),
                                  actionsPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  actions: [
                                    Row(
                                      children: [
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              context.router.pop();
                                              if (_isFirstNavigation) {
                                                setState(() {
                                                  instructionImage =
                                                      const SizedBox.shrink();
                                                  // routeProgressEvent = null;
                                                });
                                                context.router.push(
                                                    PorterConfirmScreenRoute(
                                                  job: _currentJob,
                                                ));

                                                _startNextRoute();
                                              } else {
                                                setState(() {
                                                  instructionImage =
                                                      const SizedBox.shrink();
                                                  // routeProgressEvent = null;
                                                  _stopNavigation();
                                                });
                                                context.router.push(
                                                    PorterConfirmScreenRoute(
                                                  job: _currentJob,
                                                ));
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AssetsConstants.primaryLight,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: Text(
                                              _isFirstNavigation
                                                  ? "Xác nhận đã nhận hàng"
                                                  : "Xác nhận đã giao hàng",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    AssetsConstants.whiteColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
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
                      job: _currentJob,
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
                  if (widget.bookingStatus.canPorterConfirmIncoming)
                    FloatingActionButton(
                      onPressed: _isMapReady ? _startAssinedToComing : null,
                      // onPressed: _isMapReady ? _startNavigation : null,
                      child: const Icon(Icons.directions),
                    ),
                if (!_isNavigationStarted)
                  if (widget.bookingStatus.canPorterConfirmInprogress)
                    FloatingActionButton(
                      onPressed: _isMapReady ? _startArrivedtoProgress : null,
                      child: const Icon(
                        Icons.play_for_work_sharp,
                        size: 34,
                      ),
                    ),
                if (!_isNavigationStarted)
                  if (widget.bookingStatus.canPorterConfirmOngoing)
                    FloatingActionButton(
                      onPressed: _isMapReady ? _startAssinedToComing : null,
                      // onPressed: _isMapReady ? _startPackingToOngoing : null,
                      // onPressed: _isMapReady ? _startNavigation : null,
                      child: const Icon(Icons.directions_car),
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
    _jobSubscription.cancel();
    if (_navigationController != null && _isNavigationStarted) {
      _stopNavigation();
    }

    // context.router.pushAll([PorterScreenRoute()]);

    context.router.replaceAll([
      const PorterScreenRoute(),
      // const HomeScreenRoute(),
      // const TabViewScreenRoute()
    ]);
  }
}
