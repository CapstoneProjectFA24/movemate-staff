import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/stream_controller/job_stream_manager.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/assignment_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/porter/presentation/controllers/porter_controller.dart';
import 'package:movemate_staff/features/porter/presentation/widgets/draggable_sheet/location_draggable_sheet.dart';
import 'package:movemate_staff/features/porter/presentation/widgets/porter_update_or_report_modal/porter_update_or_incidents_content_modal.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/models/user_model.dart';
import 'package:movemate_staff/utils/commons/functions/functions_common_export.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vietmap_flutter_navigation/vietmap_flutter_navigation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

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
  final bool _showNavigationButton = true;
  Widget recenterButton = const SizedBox.shrink();
  Widget instructionImage = const SizedBox.shrink();
  bool _isNavigationStarted = false;
  RouteProgressEvent? routeProgressEvent;
  LatLng? _simulatedPosition; // Thêm biến để lưu vị trí giả lập
  //Location tracking
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _locationUpdateTimer;
  bool _isFirstNavigation = true;
  LatLng? _nextDestination;

  bool canPorterConfirmIncomingFlag = false;
  bool canPorterConfirmToUploadInprogress = false;
  bool canPorterConfirmToOngoingToEnd = false;
  bool canPorterActiveModal = false;
  bool canPorterTimingToStart = false;


  // realtime
  UserModel? user;
  final DatabaseReference locationRef =
      FirebaseDatabase.instance.ref().child('tracking_locations');

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

        setState(() {
          _currentJob = updateJob;
          // _buildInitialRoute();
        });
      }
    });
  }

  Future<Map<String, dynamic>?> _getBookingData() async {
    try {
      final docSnapshot = await _firestore
          .collection('bookings')
          .doc(widget.job.id.toString())
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      print("Error getting Firestore data: $e");
      return null;
    }
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
        setState(() async {
          final bookingData = await _getBookingData();

          if (bookingData != null &&
              bookingData["Assignments"] != null &&
              bookingData["Status"] != null) {
            final assignments = bookingData["Assignments"] as List;
            final fireStoreBookingStatus = bookingData["Status"] as String;

            final porterAssignmentStatus =
                _getPorterAssignmentStatus(assignments);
            final buildRouteFlags = _getBuildRouteFlags(
                porterAssignmentStatus, fireStoreBookingStatus);

            if (buildRouteFlags['isPorterStartBuildRoute']!) {
              _currentPosition = LatLng(position.latitude, position.longitude);
            } else if (buildRouteFlags['isPorterAtDeliveryPointBuildRoute']!) {
              _currentPosition = _getPickupPointLatLng();
            } else if (buildRouteFlags['isPorterEndDeliveryPointBuildRoute']!) {
              _currentPosition = _getDeliveryPointLatLng();
            } else if (buildRouteFlags["isFailedRoute"]!) {
              _currentPosition = _getDeliveryPointLatLng();
            } else if (buildRouteFlags["isPorterPause"]!) {
              _currentPosition = _getPickupPointLatLng();
            }

            if (_currentPosition != null) {
              LatLng? lastLocation = await _getLastLocationFromFirebase();

              if (lastLocation != null) {
                await _buildInitialRoute(useFirebaseLocation: true);
                _updateLocationOnce(lastLocation!, "PORTER");
              } else {
                await _buildInitialRoute(useFirebaseLocation: false);
                _updateLocationOnce(_currentPosition!, "PORTER");
              }
            } else {
              print("Invalid position. Unable to update location.");
            }
          }
        });
      }
    } catch (e) {
      print("Không thể lấy vị trí hiện tại: $e");
    }
  }

  Map<String, bool> _getPorterAssignmentStatus(List assignments) {
    final staffAssignment = assignments.firstWhere(
        (a) => a['StaffType'] == 'PORTER' && a['UserId'] == user?.id,
        orElse: () => null);

    if (staffAssignment == null) {
      return {
        'isPorterWaiting': false,
        'isPorterAssigned': false,
        'isPorterIncoming': false,
        'isPorterArrived': false,
        'isPorterInprogress': false,
        'isPorterPacking': false,
        'isPorterOngoing': false,
        'isPorterDelivered': false,
        'isPorterUnloaded': false,
        'isPorterCompleted': false,
        'isPorterFailed': false,
      };
    }

    return {
      'isPorterWaiting': staffAssignment['Status'] == "WAITING",
      'isPorterAssigned': staffAssignment['Status'] == "ASSIGNED",
      'isPorterIncoming': staffAssignment['Status'] == "INCOMING",
      'isPorterArrived': staffAssignment['Status'] == "ARRIVED",
      'isPorterInprogress': staffAssignment['Status'] == "IN_PROGRESS",
      'isPorterPacking': staffAssignment['Status'] == "PACKING",
      'isPorterOngoing': staffAssignment['Status'] == "ONGOING",
      'isPorterDelivered': staffAssignment['Status'] == "DELIVERED",
      'isPorterUnloaded': staffAssignment['Status'] == "UNLOADED",
      'isPorterCompleted': staffAssignment['Status'] == "COMPLETED",
      'isPorterFailed': staffAssignment['Status'] == "FAILED",
    };
  }

  Map<String, bool> _getBuildRouteFlags(
      Map<String, bool> porterAssignmentStatus, String fireStoreBookingStatus) {
    bool isPorterStartBuildRoute = false;
    bool isPorterAtDeliveryPointBuildRoute = false;
    bool isPorterEndDeliveryPointBuildRoute = false;

    bool isFailedRoute = false;
    bool isPorterPause = false;

    switch (fireStoreBookingStatus) {
      case "COMING":
        isPorterStartBuildRoute = porterAssignmentStatus['isPorterWaiting']! ||
            porterAssignmentStatus['isPorterAssigned']! ||
            porterAssignmentStatus['isPorterIncoming']! ||
            (!porterAssignmentStatus['isPorterInprogress']! &&
                !porterAssignmentStatus['isPorterCompleted']! &&
                !porterAssignmentStatus['isPorterFailed']!);

        isFailedRoute = porterAssignmentStatus["isPorterFailed"]!;

        if (porterAssignmentStatus['isPorterIncoming']! ||
            porterAssignmentStatus['isPorterAssigned']!) {
          setState(() {
            canPorterConfirmIncomingFlag = true;
          });
        } else {
          setState(() {
            canPorterConfirmIncomingFlag = false;
          });
        }

        break;
      case "IN_PROGRESS":
        isPorterStartBuildRoute = porterAssignmentStatus['isPorterWaiting']! ||
            porterAssignmentStatus['isPorterAssigned']! ||
            porterAssignmentStatus['isPorterIncoming']! ||
            (!porterAssignmentStatus['isPorterInprogress']! &&
                !porterAssignmentStatus['isPorterArrived']! &&
                !porterAssignmentStatus['isPorterPacking']! &&
                !porterAssignmentStatus['isPorterDelivered']! &&
                !porterAssignmentStatus['isPorterOngoing']! &&
                !porterAssignmentStatus['isPorterCompleted']! &&
                !porterAssignmentStatus['isPorterFailed']!);

        isPorterAtDeliveryPointBuildRoute =
            (porterAssignmentStatus['isPorterArrived']! ||
                    porterAssignmentStatus['isPorterInprogress']! ||
                    porterAssignmentStatus["isPorterPacking"]! ||
                    porterAssignmentStatus["isPorterOngoing"]!) &&
                (!porterAssignmentStatus["isPorterUnloaded"]! ||
                    !porterAssignmentStatus['isPorterDelivered']! ||
                    !porterAssignmentStatus['isPorterCompleted']! ||
                    !porterAssignmentStatus['isPorterIncoming']! ||
                    !porterAssignmentStatus['isPorterAssigned']! ||
                    !porterAssignmentStatus['isPorterUnloaded']! ||
                    !porterAssignmentStatus['isPorterFailed']!);

        isPorterEndDeliveryPointBuildRoute =
            (porterAssignmentStatus['isPorterCompleted']! ||
                    porterAssignmentStatus["isPorterDelivered"]! ||
                    porterAssignmentStatus["isPorterUnloaded"]!) &&
                !porterAssignmentStatus['isPorterFailed']!;

        isFailedRoute = porterAssignmentStatus["isPorterFailed"]!;

        if (porterAssignmentStatus['isPorterIncoming']! ||
            porterAssignmentStatus['isPorterAssigned']!) {
          setState(() {
            canPorterConfirmIncomingFlag = true;
          });
        } else if (porterAssignmentStatus['isPorterArrived']! ||
            porterAssignmentStatus['isPorterInprogress']!) {
          setState(() {
            canPorterConfirmIncomingFlag = false;
            canPorterConfirmToOngoingToEnd = false;
            canPorterConfirmToUploadInprogress = true;
          });
        } else if (porterAssignmentStatus["isPorterPacking"]! ||
            porterAssignmentStatus["isPorterOngoing"]! &&
                !porterAssignmentStatus["isPorterArrived"]!) {
          setState(() {
            canPorterConfirmIncomingFlag = false;
            canPorterConfirmToOngoingToEnd = true;
            canPorterConfirmToUploadInprogress = false;
          });
        } else if (porterAssignmentStatus["isPorterDelivered"]! ||
            porterAssignmentStatus["isPorterUnloaded"]!) {
          setState(() {
            canPorterConfirmIncomingFlag = false;
            canPorterConfirmToOngoingToEnd = false;
            canPorterConfirmToUploadInprogress = true;
          });
        } else {
          setState(() {
            canPorterConfirmIncomingFlag = false;
            canPorterConfirmToUploadInprogress = false;
            canPorterConfirmToOngoingToEnd = false;
          });
        }
        break;
      case "COMPLETED":
        isPorterEndDeliveryPointBuildRoute =
            (porterAssignmentStatus['isPorterCompleted']! ||
                    porterAssignmentStatus["isPorterDelivered"]! ||
                    porterAssignmentStatus["isPorterUnloaded"]!) &&
                !porterAssignmentStatus['isPorterFailed']!;

        isFailedRoute = porterAssignmentStatus["isPorterFailed"]!;

        setState(() {
          // canDriverConfirmIncomingFlag = false;
          // canDriverStartMovingFlag = false;
        });
        break;

      case "PAUSED":
        isPorterPause = true;
        break;

      default:
        break;
    }

    return {
      'isPorterStartBuildRoute': isPorterStartBuildRoute,
      'isPorterAtDeliveryPointBuildRoute': isPorterAtDeliveryPointBuildRoute,
      'isPorterEndDeliveryPointBuildRoute': isPorterEndDeliveryPointBuildRoute,
      'isFailedRoute': isFailedRoute,
      'isPorterPause': isPorterPause
    };
  }

  Future<LatLng?> _getLastLocationFromFirebase() async {
    final String bookingId = widget.job.id.toString();
    try {
      final snapshot =
          await locationRef.child('$bookingId/PORTER/${user?.id}').get();

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

  Future<void> _buildInitialRoute({bool useFirebaseLocation = false}) async {
    final bookingData = await _getBookingData();

    if (bookingData != null &&
        bookingData["Assignments"] != null &&
        bookingData["Status"] != null) {
      final assignments = bookingData["Assignments"] as List;
      final fireStoreBookingStatus = bookingData["Status"] as String;

final bookingAt = bookingData["BookingAt"] as String;
   final now = DateTime.now();
      final format = DateFormat("MM/dd/yyyy HH:mm:ss");

      final bookingDateTime = format.parse(bookingAt);
      final earliestStartTime =
          bookingDateTime.subtract(const Duration(hours: 1));
      final isValidTime = now.isAfter(earliestStartTime) &&
          now.isBefore(bookingDateTime.add(const Duration(hours: 24)));
      setState(() {
        canPorterTimingToStart = isValidTime;
      });
      print("vinh debug: $bookingDateTime");
      print("vinh debug 1: $earliestStartTime");
      print("vinh debug 2: $now");
      print("vinh debug 3: $isValidTime");

      final porterAssignmentStatus = _getPorterAssignmentStatus(assignments);
      final buildRouteFlags =
          _getBuildRouteFlags(porterAssignmentStatus, fireStoreBookingStatus);

      if (_navigationController != null && _currentPosition != null) {
        LatLng? startPosition;

        if (useFirebaseLocation) {
          startPosition = await _getLastLocationFromFirebase();
        }
        startPosition ??= _currentPosition;
        if (startPosition != null) {
          LatLng waypoint;
          if (buildRouteFlags['isPorterStartBuildRoute']!) {
            waypoint = _getPickupPointLatLng();
            _nextDestination = _getDeliveryPointLatLng();
            //TODO: hiển thị modal khi mà !isValidTime
   
            if(!isValidTime){

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Color(0xFFFFF8F0)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              // colors: [Color(0xFFFF9900), Color(0xFFFFB446)],
                              colors: [
                                AssetsConstants.green1,
                                AssetsConstants.green1
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 0, 255, 17)
                                    .withOpacity(0.7),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: -20,
                                right: -20,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              TweenAnimationBuilder(
                                duration: const Duration(milliseconds: 600),
                                tween: Tween<double>(begin: 0, end: 1),
                                builder: (context, double value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AssetsConstants.green1,
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.published_with_changes_outlined,
                                    size: 32,
                                    color: AssetsConstants.green1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Column(
                            children: [
                              const Text(
                                'Chưa tới thời gian dọn nhà ',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Bạn chỉ có thể xem thông tin của khách hàng',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),

                        // Buttons
                        Container(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Row(
                            children: [
                              // "Đánh giá ngay" button
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AssetsConstants.green1,
                                        AssetsConstants.green1
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF9900)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Xác nhận',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
         
            }
          } else if (buildRouteFlags['isPorterAtDeliveryPointBuildRoute']!) {
            waypoint = _getDeliveryPointLatLng();
          } else if (buildRouteFlags['isPorterEndDeliveryPointBuildRoute']! ) {
            waypoint = _getDeliveryPointLatLng();
            if(porterAssignmentStatus['isPorterCompleted']!){
            
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Color(0xFFFFF8F0)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              // colors: [Color(0xFFFF9900), Color(0xFFFFB446)],
                              colors: [
                                AssetsConstants.green1,
                                AssetsConstants.green1
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 0, 255, 17)
                                    .withOpacity(0.7),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: -20,
                                right: -20,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              TweenAnimationBuilder(
                                duration: const Duration(milliseconds: 600),
                                tween: Tween<double>(begin: 0, end: 1),
                                builder: (context, double value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AssetsConstants.green1,
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.done,
                                    size: 32,
                                    color: AssetsConstants.green1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Column(
                            children: [
                              const Text(
                                'Bạn đã hoàn thành công việc',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3142),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Hãy quay lại màn hình chính để kiểm tra các đơn khác',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),

                        // Buttons
                        Container(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Row(
                            children: [
                              // "Đánh giá ngay" button
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AssetsConstants.green1,
                                        AssetsConstants.green1
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF9900)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Xác nhận',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );         

            }

          } else if (buildRouteFlags["isFailedRoute"]!) {
            waypoint = _getDeliveryPointLatLng();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Color(0xFFFFF8F0)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                // colors: [Color(0xFFFF9900), Color(0xFFFFB446)],
                                colors: [
                                  AssetsConstants.red1,
                                  AssetsConstants.red1
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFF9900).withOpacity(0.7),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  top: -20,
                                  right: -20,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                                TweenAnimationBuilder(
                                  duration: const Duration(milliseconds: 600),
                                  tween: Tween<double>(begin: 0, end: 1),
                                  builder: (context, double value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AssetsConstants.red1,
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.error_outline,
                                      size: 32,
                                      color: AssetsConstants.red1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            child: Column(
                              children: [
                                const Text(
                                  'Bạn đã gặp sự cố và được thay thế',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3142),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Hãy quay lại màn hình chính để kiểm tra các đơn khác',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),

                          // Buttons
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Row(
                              children: [
                                // "Đánh giá ngay" button
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AssetsConstants.red1,
                                          AssetsConstants.red1
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF9900)
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Xác nhận',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (buildRouteFlags["isPorterPause"]!) {
            waypoint = _getDeliveryPointLatLng();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, Color(0xFFFFF8F0)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                // colors: [Color(0xFFFF9900), Color(0xFFFFB446)],
                                colors: [
                                  AssetsConstants.yellow1,
                                  AssetsConstants.yellow1
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFF9900).withOpacity(0.7),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  top: -20,
                                  right: -20,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                ),
                                TweenAnimationBuilder(
                                  duration: const Duration(milliseconds: 600),
                                  tween: Tween<double>(begin: 0, end: 1),
                                  builder: (context, double value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AssetsConstants.yellow1,
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.published_with_changes_outlined,
                                      size: 32,
                                      color: AssetsConstants.yellow1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            child: Column(
                              children: [
                                const Text(
                                  'Đang đợi khách hàng xác nhận cập nhật',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3142),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Chờ khách hàng xác nhận',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),

                          // Buttons
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Row(
                              children: [
                                // "Đánh giá ngay" button
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AssetsConstants.yellow1,
                                          AssetsConstants.yellow1
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF9900)
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Quay lại',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return;
          }

          // sử dụng code ở dưới đây phải cẩn thận

          // if (startPosition.latitude == waypoint.latitude &&
          //     startPosition.longitude == waypoint.longitude) {
          //   await showDialog(
          //     context: context,
          //     builder: (BuildContext context) {
          //       return Dialog(
          //         backgroundColor: Colors.transparent,
          //         child: Container(
          //           decoration: BoxDecoration(
          //             gradient: const LinearGradient(
          //               begin: Alignment.topLeft,
          //               end: Alignment.bottomRight,
          //               colors: [Colors.white, Color(0xFFFFF8F0)],
          //             ),
          //             borderRadius: BorderRadius.circular(24),
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.black.withOpacity(0.1),
          //                 blurRadius: 20,
          //                 spreadRadius: 1,
          //                 offset: const Offset(0, 4),
          //               ),
          //             ],
          //           ),
          //           child: Column(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               Container(
          //                 height: 100,
          //                 decoration: BoxDecoration(
          //                   gradient: const LinearGradient(
          //                     begin: Alignment.topLeft,
          //                     end: Alignment.bottomRight,
          //                     // colors: [Color(0xFFFF9900), Color(0xFFFFB446)],
          //                     colors: [
          //                       AssetsConstants.green1,
          //                       AssetsConstants.green1
          //                     ],
          //                   ),
          //                   borderRadius: const BorderRadius.only(
          //                     topLeft: Radius.circular(24),
          //                     topRight: Radius.circular(24),
          //                   ),
          //                   boxShadow: [
          //                     BoxShadow(
          //                       color: const Color.fromARGB(255, 0, 255, 17)
          //                           .withOpacity(0.7),
          //                       blurRadius: 8,
          //                       offset: const Offset(0, 2),
          //                     ),
          //                   ],
          //                 ),
          //                 child: Stack(
          //                   alignment: Alignment.center,
          //                   children: [
          //                     Positioned(
          //                       top: -20,
          //                       right: -20,
          //                       child: Container(
          //                         width: 100,
          //                         height: 100,
          //                         decoration: BoxDecoration(
          //                           shape: BoxShape.circle,
          //                           color: Colors.white.withOpacity(0.1),
          //                         ),
          //                       ),
          //                     ),
          //                     TweenAnimationBuilder(
          //                       duration: const Duration(milliseconds: 600),
          //                       tween: Tween<double>(begin: 0, end: 1),
          //                       builder: (context, double value, child) {
          //                         return Transform.scale(
          //                           scale: value,
          //                           child: child,
          //                         );
          //                       },
          //                       child: Container(
          //                         padding: const EdgeInsets.all(16),
          //                         decoration: const BoxDecoration(
          //                           color: Colors.white,
          //                           shape: BoxShape.circle,
          //                           boxShadow: [
          //                             BoxShadow(
          //                               color: AssetsConstants.green1,
          //                               blurRadius: 12,
          //                               spreadRadius: 2,
          //                             ),
          //                           ],
          //                         ),
          //                         child: const Icon(
          //                           Icons.done,
          //                           size: 32,
          //                           color: AssetsConstants.green1,
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),

          //               Padding(
          //                 padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          //                 child: Column(
          //                   children: [
          //                     const Text(
          //                       'Kiểm tra đơn',
          //                       style: TextStyle(
          //                         fontSize: 24,
          //                         fontWeight: FontWeight.bold,
          //                         color: Color(0xFF2D3142),
          //                       ),
          //                     ),
          //                     const SizedBox(height: 16),
          //                     Text(
          //                       'Hãy quay lại màn hình chính để kiểm tra các đơn khác',
          //                       textAlign: TextAlign.center,
          //                       style: TextStyle(
          //                         fontSize: 16,
          //                         height: 1.5,
          //                         color: Colors.grey[600],
          //                       ),
          //                     ),
          //                     const SizedBox(height: 32),
          //                   ],
          //                 ),
          //               ),

          //               // Buttons
          //               Container(
          //                 padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          //                 child: Row(
          //                   children: [
          //                     // "Đánh giá ngay" button
          //                     Expanded(
          //                       child: Container(
          //                         decoration: BoxDecoration(
          //                           borderRadius: BorderRadius.circular(12),
          //                           gradient: const LinearGradient(
          //                             begin: Alignment.topLeft,
          //                             end: Alignment.bottomRight,
          //                             colors: [
          //                               AssetsConstants.green1,
          //                               AssetsConstants.green1
          //                             ],
          //                           ),
          //                           boxShadow: [
          //                             BoxShadow(
          //                               color: const Color(0xFFFF9900)
          //                                   .withOpacity(0.3),
          //                               blurRadius: 8,
          //                               spreadRadius: 0,
          //                               offset: const Offset(0, 4),
          //                             ),
          //                           ],
          //                         ),
          //                         child: ElevatedButton(
          //                           onPressed: () {
          //                             Navigator.of(context).pop();
          //                             Navigator.of(context).pop();
          //                           },
          //                           style: ElevatedButton.styleFrom(
          //                             backgroundColor: Colors.transparent,
          //                             foregroundColor: Colors.white,
          //                             shadowColor: Colors.transparent,
          //                             padding: const EdgeInsets.symmetric(
          //                                 vertical: 16),
          //                             shape: RoundedRectangleBorder(
          //                               borderRadius: BorderRadius.circular(12),
          //                             ),
          //                           ),
          //                           child: const Text(
          //                             'Xác nhận',
          //                             style: TextStyle(
          //                               fontSize: 16,
          //                               fontWeight: FontWeight.bold,
          //                             ),
          //                           ),
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       );
          //     },
          //   );
          // }

          await _navigationController?.buildRoute(
            waypoints: [
              LatLng(startPosition.latitude, startPosition.longitude),
              waypoint,
              // LatLng(10.751169, 106.607249),
              // LatLng(10.775458, 106.601052)
            ],
            profile: DrivingProfile.drivingTraffic,
          );
        } else {
          print("No valid starting position available");
        }
      }
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
        await _buildInitialRoute(useFirebaseLocation: true);
        setState(() {
          _isNavigationStarted = true;
        });

        await _navigationController?.startNavigation();
        try {
          await ProviderScope.containerOf(context, listen: false)
              .read(porterControllerProvider.notifier)
              .updateStatusPorterWithoutResourse(
                id: widget.job.id,
                context: context,
              );
        } catch (driverError) {
          print(
              "Lỗi khi bắt đầu điều hướng từ assined lên incoming: ${driverError.toString()}");
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
          await ProviderScope.containerOf(context, listen: false)
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
        await _buildInitialRoute(useFirebaseLocation: true);
        await ProviderScope.containerOf(context, listen: false)
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

  Future<void> _fastFinishToComplete() async {
    if (_navigationController != null) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: AssetsConstants.whiteColor,
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Xác nhận tới ngay",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AssetsConstants.blackColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Vui lòng xác nhận để tiếp tục",
                        style: TextStyle(
                          fontSize: 14,
                          color: AssetsConstants.blackColor.withOpacity(0.7),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        LatLng destination = _getDeliveryPointLatLng();
                        // Cập nhật vị trí cuối cùng lên Firebase
                        _updateLocationRealtime(destination, "PORTER");

                        try {
                          ProviderScope.containerOf(context, listen: false)
                              .read(porterControllerProvider.notifier)
                              .updateStatusPorterWithoutResourse(
                                id: widget.job.id,
                                context: context,
                              );
                        } finally {
                                                    Navigator.of(context).pop();

                          context.router.push(PorterConfirmScreenRoute(
                            job: _currentJob,
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AssetsConstants.primaryLight,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Xác nhận đã đến",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AssetsConstants.whiteColor,
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

  Future<void> _fastFinishToArrived() async {
    if (_navigationController != null) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: AssetsConstants.whiteColor,
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Xác nhận tới ngay",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AssetsConstants.blackColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Vui lòng xác nhận để tiếp tục",
                        style: TextStyle(
                          fontSize: 14,
                          color: AssetsConstants.blackColor.withOpacity(0.7),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        LatLng destination = _getPickupPointLatLng();
                        // Cập nhật vị trí cuối cùng lên Firebase
                        _updateLocationRealtime(destination, "PORTER");

                        try {
                          await ProviderScope.containerOf(context,
                                  listen: false)
                              .read(porterControllerProvider.notifier)
                              .updateStatusPorterWithoutResourse(
                                id: widget.job.id,
                                context: context,
                              );
                        } finally {
                                                    Navigator.of(context).pop();

                          context.router.push(PorterConfirmScreenRoute(
                            job: _currentJob,
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AssetsConstants.primaryLight,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Xác nhận đã đến",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AssetsConstants.whiteColor,
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
                                                  ? "Đã đến điểm chuyển nhà"
                                                  : "Đã đến điểm mới",
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
                                                LatLng destination =
                                                    _getPickupPointLatLng();
                                                _updateLocationRealtime(
                                                    destination, "PORTER");
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
                                                LatLng destination =
                                                    _getDeliveryPointLatLng();
                                                _updateLocationRealtime(
                                                    destination, "PORTER");
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
                                                  ? "Xác nhận đã đến"
                                                  : "Xác nhận đã đến",
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
                              '',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            // IconButton(
                            //   icon: const Icon(
                            //     Icons.headset_mic_outlined,
                            //     color: Colors.black54,
                            //     size: 24,
                            //   ),
                            //   onPressed: () {
                            //     // Add support action
                            //   },
                            // ),
                            IconButton(
                              icon: const Icon(
                                Icons.help_outline,
                                color: Colors.black54,
                                size: 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  canPorterActiveModal = true;
                                });

                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return PorterUpdateOrIncidentsContentModal(
                                      order: widget.job,
                                      onClose: () {
                                        setState(() {
                                          canPorterActiveModal = false;
                                        });
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ).then((_) {
                                  // This runs when the modal is closed
                                  setState(() {
                                    canPorterActiveModal = false;
                                  });
                                });
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
                  if (canPorterConfirmIncomingFlag && canPorterTimingToStart)
                    FloatingActionButton(
                      onPressed: _isMapReady ? _startAssinedToComing : null,
                      // onPressed: _isMapReady ? _startNavigation : null,
                      child: const Icon(Icons.directions),
                    ),
                if (!_isNavigationStarted && canPorterTimingToStart)
                  if (canPorterConfirmIncomingFlag)
                    FloatingActionButton(
                      onPressed: _fastFinishToArrived,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.check),
                    ),
                if (!_isNavigationStarted)
                  if (canPorterConfirmToUploadInprogress && canPorterTimingToStart)
                    FloatingActionButton(
                      onPressed: _isMapReady ? _startArrivedtoProgress : null,
                      child: const Icon(
                        Icons.play_for_work_sharp,
                        size: 34,
                      ),
                    ),
                if (!_isNavigationStarted)
                  if (canPorterConfirmToOngoingToEnd&&canPorterTimingToStart)
                    FloatingActionButton(
                      onPressed: _isMapReady ? _startAssinedToComing : null,
                      // onPressed: _isMapReady ? _startPackingToOngoing : null,
                      // onPressed: _isMapReady ? _startNavigation : null,
                      child: const Icon(Icons.directions_car),
                    ),
                if (!_isNavigationStarted)
                  if (canPorterConfirmToOngoingToEnd)
                    FloatingActionButton(
                      onPressed: _fastFinishToComplete,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.check),
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
