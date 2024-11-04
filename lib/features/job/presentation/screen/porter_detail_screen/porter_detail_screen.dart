import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/job/presentation/widgets/map_widget/button_custom.dart';
import 'package:movemate_staff/features/job/presentation/widgets/map_widget/location_bottom_sheet.dart';
import 'package:movemate_staff/features/job/presentation/widgets/map_widget/location_info_card.dart';

import 'package:movemate_staff/services/map_services/location_service.dart';
import 'package:movemate_staff/services/map_services/map_service.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:geolocator/geolocator.dart';

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
class PorterDetailScreen extends ConsumerStatefulWidget {
  const PorterDetailScreen({super.key});

  static const String apiKey = APIConstants.apiVietMapKey;

  @override
  ConsumerState<PorterDetailScreen> createState() =>
      LocationSelectionScreenState();
}

class LocationSelectionScreenState extends ConsumerState<PorterDetailScreen> {
  VietmapController? mapController;
  Position? currentPosition;
  Line? currentRoute;
  bool isTracking = false;

  @override
  void initState() {
    super.initState();
    initializeLocationGPS();
  }

  @override
  void dispose() {
    clearCurrentRoute();
    mapController?.dispose();
    super.dispose();
  }

  Future<void> clearCurrentRoute() async {
    if (mapController != null) {
      await MapService.clearRoute(mapController!);
      currentRoute = null;
    }
  }

  // todo draw -- notwork
  Future<void> drawRouteBetweenLocations(Booking bookingState) async {
    if (mapController == null ||
        bookingState.pickUpLocation == null ||
        bookingState.dropOffLocation == null) {
      return;
    }

    // Xóa route cũ nếu có
    await clearCurrentRoute();

    // Vẽ route mới
    currentRoute = await MapService.drawRoute(
      controller: mapController!,
      origin: LatLng(
        bookingState.pickUpLocation!.latitude,
        bookingState.pickUpLocation!.longitude,
      ),
      destination: LatLng(
        bookingState.dropOffLocation!.latitude,
        bookingState.dropOffLocation!.longitude,
      ),
      routeColor: Colors.orange,
      routeWidth: 4.0,
    );
  }

  Future<void> initializeLocationGPS() async {
    if (await LocationService.checkLocationPermission()) {
      if (await LocationService.isLocationServiceEnabled()) {
        print("oke gps ");
        startLocationTracking();
      } else {
        LocationService.showEnableLocationDialog(context);
      }
    } else {
      LocationService.showPermissionDeniedDialog(context);
    }
  }

  void startLocationTracking() {
    setState(() => isTracking = true);

    LocationService.getPositionStream().listen((Position position) {
      setState(() => currentPosition = position);

      if (mapController != null) {
        MapService.focusOnLocation(
          mapController!,
          LatLng(position.latitude, position.longitude),
        );
      }
    });
  }

  List<Marker> buildMarkers(Booking bookingState) {
    final markers = <Marker>[];

    if (bookingState.pickUpLocation != null) {
      markers.add(
        Marker(
          alignment: Alignment.bottomCenter,
          child: const Icon(Icons.location_on, color: Colors.green, size: 50),
          latLng: LatLng(
            bookingState.pickUpLocation!.latitude,
            bookingState.pickUpLocation!.longitude,
          ),
        ),
      );
    }

    if (bookingState.dropOffLocation != null) {
      markers.add(
        Marker(
          alignment: Alignment.bottomCenter,
          child: const Icon(Icons.location_on, color: Colors.red, size: 50),
          latLng: LatLng(
            bookingState.dropOffLocation!.latitude,
            bookingState.dropOffLocation!.longitude,
          ),
        ),
      );
    }

    return markers;
  }

  List<LatLng> getLocations(Booking bookingState) {
    final locations = <LatLng>[];

    if (bookingState.pickUpLocation != null) {
      locations.add(LatLng(
        bookingState.pickUpLocation!.latitude,
        bookingState.pickUpLocation!.longitude,
      ));
    }

    if (bookingState.dropOffLocation != null) {
      locations.add(LatLng(
        bookingState.dropOffLocation!.latitude,
        bookingState.dropOffLocation!.longitude,
      ));
    }

    return locations;
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(fakeBookingProvider);
    final markers = buildMarkers(bookingState);
    final locations = getLocations(bookingState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (locations.isNotEmpty && mapController != null) {
        MapService.focusOnAllMarkers(mapController!, locations);

        if (locations.length == 2) {
          drawRouteBetweenLocations(bookingState);
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  VietmapGL(
                    trackCameraPosition: true,
                    myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
                    myLocationEnabled: true,
                    myLocationRenderMode: MyLocationRenderMode.COMPASS,
                    styleString:
                        "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${PorterDetailScreen.apiKey}",
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(10.762317, 106.654551),
                      zoom: 15,
                    ),
                    onStyleLoadedCallback: () => debugPrint("Map style loaded"),
                    onMapCreated: (controller) {
                      setState(() {
                        mapController = controller;
                        if (locations.isNotEmpty) {
                          MapService.focusOnAllMarkers(controller, locations);
                          // Vẽ route khi khởi tạo map nếu có đủ điểm
                          if (locations.length == 2) {
                            drawRouteBetweenLocations(bookingState);
                          }
                        }
                      });
                    },
                  ),
                  if (mapController != null && markers.isNotEmpty)
                    MarkerLayer(
                      ignorePointer: true,
                      mapController: mapController!,
                      markers: markers,
                    ),
                  if (currentPosition != null)
                    Positioned(
                      bottom: 80,
                      left: 16,
                      child: LocationInfoCard(position: currentPosition!),
                    ),

                  // Positioned(
                  //   right: 16,
                  //   bottom: 16,
                  //   child: MapActionButtons(
                  //     onMyLocationPressed: () {
                  //       if (currentPosition != null && mapController != null) {
                  //         MapService.focusOnLocation(
                  //           mapController!,
                  //           LatLng(currentPosition!.latitude,
                  //               currentPosition!.longitude),
                  //         );
                  //       }
                  //     },
                  //     showFocusAllMarkers: markers.length > 1,
                  //     onFocusAllMarkersPressed: markers.length > 1
                  //         ? () => MapService.focusOnAllMarkers(
                  //             mapController!, locations)
                  //         : null,
                  //     showDrawRoute: locations.length == 2,
                  //     onDrawRoutePressed: locations.length == 2
                  //         ? () => drawRouteBetweenLocations(bookingState)
                  //         : null,
                  //   ),
                  // ),
                  Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: SafeArea(
                            child: Row(
                              children: [
                                const BackButton(),
                                const Text(
                                  'Đã giao hàng',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      DraggableScrollableSheet(
                        initialChildSize: 0.4,
                        minChildSize: 0.25,
                        maxChildSize: 0.85,
                        builder: (context, scrollController) {
                          return SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Giao vào 11 Th10',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            _buildProgressDot(true),
                                            _buildProgressLine(true),
                                            _buildProgressDot(true),
                                            _buildProgressLine(true),
                                            _buildProgressDot(true),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Đã vận chuyển'),
                                            Text('Đang giao hàng'),
                                            Text('Đã giao hàng'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                          ),
                                          child:
                                              const Icon(Icons.local_shipping),
                                        ),
                                        const SizedBox(width: 12),
                                        const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'SPX Express',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              'SPXVN0419102963A',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: () {},
                                          child: const Text('Sao chép'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Sheet content
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            width: 40,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Thông tin dịch vụ',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFFFF7643),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              const Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Loại nhà',
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          'Nhà riêng',
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Số tầng',
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          '1',
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Số phòng',
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          '1',
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Địa điểm đón',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Expanded(
                                                        child: Text(
                                                          '428/39-NHA-6 Đường Chiến Lược...',
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {},
                                                        child: const Text(
                                                          'Xem thêm',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFFFF7643),
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Địa điểm đến',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const Expanded(
                                                        child: Text(
                                                          '428/39-NHA-3 Đường Chiến Lược...',
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {},
                                                        child: const Text(
                                                          'Xem thêm',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFFFF7643),
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const Divider(height: 32),
                                              const Text(
                                                'Thông tin khách hàng',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFFFF7643),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Tên khách hàng',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        'Vinh',
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 16),
                                                  const Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Số điện thoại',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        '0382703625',
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  // Navigator.push(
                                                  //   context,
                                                  //   MaterialPageRoute(
                                                  //     builder: (context) =>
                                                  //         YourNewScreen(), // Thay thế YourNewScreen bằng màn hình bạn muốn điều hướng đến
                                                  //   ),
                                                  // );
                                                },
                                                child: const Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Xem hình ảnh xác nhận',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildProgressDot(bool isCompleted) {
  return Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isCompleted ? Colors.orange : Colors.grey[300],
      border: Border.all(
        color: isCompleted ? Colors.orange : Colors.grey[300]!,
        width: 2,
      ),
    ),
    child: isCompleted
        ? const Icon(
            Icons.check,
            size: 12,
            color: Colors.white,
          )
        : null,
  );
}

Widget _buildProgressLine(bool isCompleted) {
  return Expanded(
    child: Container(
      height: 2,
      color: isCompleted ? Colors.orange : Colors.grey[300],
    ),
  );
}
