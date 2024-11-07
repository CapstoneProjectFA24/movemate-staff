import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/features/drivers/presentation/widgets/draggable_sheet/location_draggable_sheet.dart';
import 'package:movemate_staff/features/drivers/presentation/widgets/map_widget/location_info_card.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';

import 'package:movemate_staff/services/map_services/location_service.dart';
import 'package:movemate_staff/services/map_services/map_service.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart';
import 'package:geolocator/geolocator.dart';

@RoutePage()
class DriverDetailScreen extends ConsumerStatefulWidget {
  final BookingResponseEntity job;
  const DriverDetailScreen({super.key, required this.job});

  static const String apiKey = APIConstants.apiVietMapKey;

  @override
  ConsumerState<DriverDetailScreen> createState() =>
      LocationSelectionScreenState();
}

class LocationSelectionScreenState extends ConsumerState<DriverDetailScreen> {
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

  Future<void> drawRouteBetweenLocations(BookingResponseEntity job) async {
    final pickupCoords = job.pickupPoint.split(',');
    final pickupLat = double.parse(pickupCoords[0].trim());
    final pickupLng = double.parse(pickupCoords[1].trim());

    final deliveryCoords = job.deliveryPoint.split(',');
    final deliveryLat = double.parse(deliveryCoords[0].trim());
    final deliveryLng = double.parse(deliveryCoords[1].trim());

    if (mapController == null ||
        job.pickupPoint == null ||
        job.deliveryPoint == null) {
      return;
    }

    await clearCurrentRoute();

    currentRoute = await MapService.drawRoute(
      controller: mapController!,
      origin: LatLng(pickupLat, pickupLng),
      destination: LatLng(deliveryLat, deliveryLng),
      routeColor: Colors.orange,
      routeWidth: 4.0,
    );
  }

  Future<void> initializeLocationGPS() async {
    if (await LocationService.checkLocationPermission()) {
      if (await LocationService.isLocationServiceEnabled()) {
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

  List<Marker> buildMarkers(BookingResponseEntity job) {
    final markers = <Marker>[];

    final pickupCoords = job.pickupPoint.split(',');
    final pickupLat = double.parse(pickupCoords[0].trim());
    final pickupLng = double.parse(pickupCoords[1].trim());

    final deliveryCoords = job.deliveryPoint.split(',');
    final deliveryLat = double.parse(deliveryCoords[0].trim());
    final deliveryLng = double.parse(deliveryCoords[1].trim());

    if (job.pickupPoint != null) {
      markers.add(
        Marker(
          alignment: Alignment.bottomCenter,
          child: const Icon(Icons.location_on, color: Colors.green, size: 50),
          latLng: LatLng(pickupLat, pickupLng),
        ),
      );
    }

    if (job.deliveryPoint != null) {
      markers.add(
        Marker(
          alignment: Alignment.bottomCenter,
          child: const Icon(Icons.location_on, color: Colors.red, size: 50),
          latLng: LatLng(deliveryLat, deliveryLng),
        ),
      );
    }

    return markers;
  }

  List<LatLng> getLocations(BookingResponseEntity job) {
    final locations = <LatLng>[];

    final pickupCoords = job.pickupPoint.split(',');
    final pickupLat = double.parse(pickupCoords[0].trim());
    final pickupLng = double.parse(pickupCoords[1].trim());

    final deliveryCoords = job.deliveryPoint.split(',');
    final deliveryLat = double.parse(deliveryCoords[0].trim());
    final deliveryLng = double.parse(deliveryCoords[1].trim());

    locations.add(LatLng(pickupLat, pickupLng));
    locations.add(LatLng(deliveryLat, deliveryLng));

    return locations;
  }

  @override
  Widget build(BuildContext context) {
    final markers = buildMarkers(widget.job);
    final locations = getLocations(widget.job);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (locations.isNotEmpty && mapController != null) {
        MapService.focusOnAllMarkers(mapController!, locations);

        if (locations.length == 2) {
          drawRouteBetweenLocations(widget.job);
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
                        "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=${DriverDetailScreen.apiKey}",
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
                          if (locations.length == 2) {
                            drawRouteBetweenLocations(widget.job);
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
                          ? () => drawRouteBetweenLocations(widget.job)
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
                      DeliveryDetailsBottomSheet(
                        job: widget.job,
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
