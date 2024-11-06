import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/porter/presentation/widgets/draggable_sheet/location_draggable_sheet.dart';
import 'package:movemate_staff/features/porter/presentation/widgets/map_widget/button_custom.dart';
import 'package:movemate_staff/features/porter/presentation/widgets/map_widget/location_bottom_sheet.dart';
import 'package:movemate_staff/features/porter/presentation/widgets/map_widget/location_info_card.dart';

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
                  Positioned(
                    right: 16,
                    bottom: 0,
                    child: MapActionButtons(
                      onMyLocationPressed: () {
                        if (currentPosition != null && mapController != null) {
                          MapService.focusOnLocation(
                            mapController!,
                            LatLng(currentPosition!.latitude,
                                currentPosition!.longitude),
                          );
                        }
                      },
                      showFocusAllMarkers: markers.length > 1,
                      onFocusAllMarkersPressed: markers.length > 1
                          ? () => MapService.focusOnAllMarkers(
                              mapController!, locations)
                          : null,
                      showDrawRoute: locations.length == 2,
                      onDrawRoutePressed: locations.length == 2
                          ? () => drawRouteBetweenLocations(bookingState)
                          : null,
                    ),
                  ),
                  Stack(
                    children: [
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
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
                                const BackButton(
                                  color: AssetsConstants.primaryMain,
                                ),
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
                                  color: AssetsConstants.primaryMain,
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  color: AssetsConstants.primaryMain,
                                  onPressed: () {},
                                ),
                              ],
                            )),
                          ),
                        ),
                      ),
                      const DeliveryDetailsBottomSheet(),
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
