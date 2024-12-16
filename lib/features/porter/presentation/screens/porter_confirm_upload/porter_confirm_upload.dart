import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/drivers/presentation/controllers/stream_controller/job_stream_manager.dart';
import 'package:movemate_staff/features/drivers/presentation/widgets/draggable_sheet/driver_confirm_upload/driver_confirm_upload.dart';
import 'package:movemate_staff/features/job/data/model/request/resource.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/presentation/controllers/booking_controller/booking_controller.dart';
import 'package:movemate_staff/features/porter/data/models/request/porter_update_resourse_request.dart';
import 'package:movemate_staff/features/porter/presentation/controllers/porter_controller.dart';
import 'package:movemate_staff/hooks/use_booking_status.dart';
import 'package:movemate_staff/hooks/use_fetch_obj.dart';
import 'package:movemate_staff/services/realtime_service/booking_status_realtime/booking_status_stream_provider.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/commons/widgets/cloudinary/cloudinary_camera_upload_widget.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/providers/common_provider.dart';

@RoutePage()
// final uploadedImagesProvider = StateProvider<List<Resource>>((ref) => []);

class PorterConfirmScreen extends HookConsumerWidget {
  final BookingResponseEntity job;
  const PorterConfirmScreen({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Color constants
    const primaryOrange = Color(0xFFFF6B00);
    const secondaryOrange = Color(0xFFFFE5D6);
    const darkGrey = Color(0xFF4A4A4A);
    const disabledGrey = Color(0xFFE0E0E0);

    // Image states
    final images1 = useState<List<String>>([]);
    final imagePublicIds1 = useState<List<String>>([]);
    final images2 = useState<List<String>>([]);
    final imagePublicIds2 = useState<List<String>>([]);
    final images3 = useState<List<String>>([]);
    final imagePublicIds3 = useState<List<String>>([]);
    final images4 = useState<List<String>>([]);
    final imagePublicIds4 = useState<List<String>>([]);
    final images5 = useState<List<String>>([]);
    final imagePublicIds5 = useState<List<String>>([]);
    final fullScreenImage = useState<String?>(null);
    final rebuildKey = useState(UniqueKey());
    final request = useState(PorterUpdateResourseRequest(resourceList: []));
    // final uploadedImages = ref.watch(uploadedImagesProvider);
    final bookingAsync = ref.watch(bookingStreamProvider(job.id.toString()));
    final status = useBookingStatus(bookingAsync.value, job.isReviewOnline);
    final currentJob = useState<BookingResponseEntity>(job);
    final user = ref.read(authProvider);
    final jobEntity = useFetchObject<BookingResponseEntity>(
        function: (context) async {
          return ref
              .read(bookingControllerProvider.notifier)
              .getBookingById(job.id, context);
        },
        context: context);

    final currentListStaff = ref
        .watch(bookingStreamProvider(job.id.toString()))
        .value
        ?.assignments
        .toList();

    useEffect(() {
      // Call refresh when component mounts
      jobEntity.refresh();
      return null; // cleanup function
    }, []);

    useEffect(() {
      JobStreamManager().updateJob(job);
      return null;
    }, [bookingAsync.value]);

    useEffect(() {
      final subscription = JobStreamManager().jobStream.listen((updateJob) {
        if (updateJob.id == job.id) {
          currentJob.value = updateJob;
        }
      });
      return subscription.cancel;
    }, [job]);

    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final _bookingData = useState<Map<String, dynamic>?>(null);

    Future<void> _getBookingData() async {
      try {
        final data = await _firestore
            .collection('bookings')
            .doc(job.id.toString())
            .get()
            .then((doc) => doc.data());
        _bookingData.value = data;
      } catch (e) {
        print("Error getting Firestore data: $e");
      }
    }

    useEffect(() {
      _getBookingData();
    }, []);

    if (_bookingData.value == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final assignments = _bookingData.value!["Assignments"] as List;
    final fireStoreBookingStatus = _bookingData.value!["Status"] as String;

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
        Map<String, bool> porterAssignmentStatus,
        String fireStoreBookingStatus) {
      bool isPorterStartBuildRoute = false;
      bool isPorterAtDeliveryPointBuildRoute = false;
      bool isPorterEndDeliveryPointBuildRoute = false;

      bool isFailedRoute = false;
      bool isPorterPause = false;

      bool canPorterConfirmArrived = false;

      bool canPorterConfirmPacking = false;

      bool canPorterConfirmDelivered = false;

      bool canPorterCompleteUnloading = false;

      bool canPorterComplete = false;

      switch (fireStoreBookingStatus) {
        case "COMING":
          isPorterStartBuildRoute =
              porterAssignmentStatus['isPorterWaiting']! ||
                  porterAssignmentStatus['isPorterAssigned']! ||
                  porterAssignmentStatus['isPorterIncoming']! ||
                  (!porterAssignmentStatus['isPorterInprogress']! &&
                      !porterAssignmentStatus['isPorterCompleted']! &&
                      !porterAssignmentStatus['isPorterFailed']!);

          isFailedRoute = porterAssignmentStatus["isPorterFailed"]!;

          canPorterConfirmArrived = porterAssignmentStatus['isPorterIncoming']!;

          break;
        case "IN_PROGRESS":
          canPorterConfirmArrived = porterAssignmentStatus['isPorterIncoming']!;
          canPorterConfirmPacking =
              porterAssignmentStatus['isPorterInprogress']!;
          canPorterConfirmDelivered =
              porterAssignmentStatus['isPorterOngoing']!;
          canPorterCompleteUnloading =
              porterAssignmentStatus['isPorterDelivered']!;
          canPorterComplete = porterAssignmentStatus['isPorterUnloaded']!;
          break;
        case "COMPLETED":
          isPorterEndDeliveryPointBuildRoute =
              (porterAssignmentStatus['isPorterCompleted']! ||
                      porterAssignmentStatus["isPorterDelivered"]! ||
                      porterAssignmentStatus["isPorterUnloaded"]!) &&
                  !porterAssignmentStatus['isPorterFailed']!;

          isFailedRoute = porterAssignmentStatus["isPorterFailed"]!;

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
        'isPorterEndDeliveryPointBuildRoute':
            isPorterEndDeliveryPointBuildRoute,
        'isFailedRoute': isFailedRoute,
        'isPorterPause': isPorterPause,
////////////

        'canPorterConfirmArrived': canPorterConfirmArrived,
        'canPorterConfirmPacking': canPorterConfirmPacking,
        'canPorterConfirmDelivered': canPorterConfirmDelivered,
        'canPorterCompleteUnloading': canPorterCompleteUnloading,
        'canPorterComplete': canPorterComplete,
      };
    }

    final porterAssignmentStatus = _getPorterAssignmentStatus(assignments);
    final buildRouteFlags =
        _getBuildRouteFlags(porterAssignmentStatus, fireStoreBookingStatus);

    List<dynamic> getTrackerSources(
        Map<String, dynamic> bookingData, String trackerType) {
      try {
        final trackers = bookingData["BookingTrackers"]
            ?.firstWhere((e) => e["Type"] == trackerType);

        return trackers['TrackerSources'];
      } catch (e) {
        return [];
      }
    }

    final imagesSourceArrived =
        getTrackerSources(_bookingData.value!, "PORTER_ARRIVED");
    final imagesSourcePacking =
        getTrackerSources(_bookingData.value!, "PORTER_PACKING");
    final imagesSourceDelivered =
        getTrackerSources(_bookingData.value!, "PORTER_DELIVERED");
    final imagesSourceUnloaded =
        getTrackerSources(_bookingData.value!, "PORTER_UNLOADED");
    final imagesSourceCompleted =
        getTrackerSources(_bookingData.value!, "PORTER_COMPLETED");

    useEffect(() {
      if (imagesSourceArrived.isNotEmpty) {
        images1.value = imagesSourceArrived
            .map((source) => source['ResourceUrl'] as String)
            .toList();

        imagePublicIds1.value = imagesSourceArrived
            .map((source) => source['ResourceCode'] as String)
            .toList();
      }
      if (imagesSourcePacking.isNotEmpty) {
        images2.value = imagesSourcePacking
            .map((source) => source['ResourceUrl'] as String)
            .toList();

        imagePublicIds2.value = imagesSourcePacking
            .map((source) => source['ResourceCode'] as String)
            .toList();
      }
      if (imagesSourceDelivered.isNotEmpty) {
        images3.value = imagesSourceDelivered
            .map((source) => source['ResourceUrl'] as String)
            .toList();

        imagePublicIds3.value = imagesSourceDelivered
            .map((source) => source['ResourceCode'] as String)
            .toList();
      }
      if (imagesSourceUnloaded.isNotEmpty) {
        images4.value = imagesSourceUnloaded
            .map((source) => source['ResourceUrl'] as String)
            .toList();

        imagePublicIds4.value = imagesSourceUnloaded
            .map((source) => source['ResourceCode'] as String)
            .toList();
      }
      if (imagesSourceCompleted.isNotEmpty) {
        images5.value = imagesSourceCompleted
            .map((source) => source['ResourceUrl'] as String)
            .toList();

        imagePublicIds5.value = imagesSourceCompleted
            .map((source) => source['ResourceCode'] as String)
            .toList();
      }
      return null;
    }, [
      imagesSourceCompleted,
      imagesSourceUnloaded,
      imagesSourceDelivered,
      imagesSourcePacking,
      imagesSourceArrived
    ]);

    VoidCallback _createActionHandler(
        {required List<String> images,
        required List<String> imagePublicIds,
        required String trackerType}) {
      return () async {
        try {
          final List<Resource> resources =
              convertToResourceList(images, imagePublicIds);

          final request = PorterUpdateResourseRequest(
            resourceList: resources,
          );

          await ref
              .read(porterControllerProvider.notifier)
              .updateStatusPorterResourse(
                id: job.id,
                request: request,
                context: context,
              );

          await _getBookingData();

          rebuildKey.value = UniqueKey();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Có lỗi xảy ra: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      };
    }

    Widget buildConfirmationSection({
      required String title,
      required List<String> imagePublicIds,
      required Function(String, String) onImageUploaded,
      required Function(String) onImageRemoved,
      required Function(String) onImageTapped,
      required VoidCallback onActionPressed,
      required String actionButtonLabel,
      required IconData actionIcon,
      required bool isEnabled,
      required bool showCameraButton,
      required PorterUpdateResourseRequest request,
    }) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: primaryOrange,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkGrey,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: secondaryOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${imagePublicIds.length} ảnh',
                    style: const TextStyle(
                      color: primaryOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CloudinaryCameraUploadWidget(
                disabled: !isEnabled,
                imagePublicIds: imagePublicIds,
                onImageUploaded: isEnabled ? onImageUploaded : (_, __) {},
                onImageRemoved: isEnabled ? onImageRemoved : (_) {},
                onImageTapped: onImageTapped,
                showCameraButton: showCameraButton,
                optionalButton:
                    imagePublicIds.isNotEmpty || title == "Xác nhận vận chuyển"
                        ? ElevatedButton.icon(
                            onPressed: isEnabled ? onActionPressed : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isEnabled ? primaryOrange : disabledGrey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: Icon(actionIcon),
                            label: FittedBox(child: Text(actionButtonLabel)),
                          )
                        : null,
                onUploadComplete: (resource) {
                  switch (title) {
                    case 'Xác nhận đến':
                      request.resourceList.add(resource);
                      break;
                    case 'Xác nhận dọn hàng':
                      // Do nothing, no image upload here
                      break;
                    case 'Xác nhận trả hàng':
                      // Do nothing, no image upload here
                      break;
                    case 'Xác nhận dọn hàng':
                      // Do nothing, no image upload here
                      break;
                    case 'Xác nhận giao hàng':
                      request.resourceList.add(resource);
                      break;
                  }
                }),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        backgroundColor: primaryOrange,
        backButtonColor: AssetsConstants.whiteColor,
        onBackButtonPressed: () {
          context.router.popAndPushAll([
            PorterDetailScreenRoute(
                job: currentJob.value, bookingStatus: status, ref: ref)
          ]);
        },
        title: "Xác nhận hình ảnh",
        showBackButton: true,
      ),
      body: Stack(
        children: [
          // Orange curved background
          Container(
            height: 50,
            decoration: const BoxDecoration(
              color: primaryOrange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),

          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  //case 1
                  buildConfirmationSection(
                    title: 'Xác nhận đã đến',
                    imagePublicIds: imagePublicIds1.value,
                    onImageUploaded: (url, publicId) {
                      images1.value = [...images1.value, url];
                      imagePublicIds1.value = [
                        ...imagePublicIds1.value,
                        publicId
                      ];
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tải ảnh lên thành công'),
                          backgroundColor: primaryOrange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageRemoved: (publicId) {
                      images1.value = images1.value
                          .where((url) => !url.contains(publicId))
                          .toList();
                      imagePublicIds1.value = imagePublicIds1.value
                          .where((id) => id != publicId)
                          .toList();

                      // Cập nhật lại resourceList trong IncidentRequest
                      request.value = PorterUpdateResourseRequest(
                        resourceList: request.value.resourceList
                            .where(
                                (resource) => resource.resourceCode != publicId)
                            .toList(),
                      );
                    },
                    onImageTapped: (url) => fullScreenImage.value = url,

                    onActionPressed: _createActionHandler(
                      images: images1.value,
                      imagePublicIds: imagePublicIds1.value,
                      trackerType: "PORTER_ARRIVED",
                    ),
                    actionButtonLabel: 'Xác nhận đến',
                    actionIcon: Icons.location_on,
                    isEnabled: buildRouteFlags['canPorterConfirmArrived']!,
                    // isEnabled: status.canPorterConfirmIncoming,
                    showCameraButton: true,
                    request: request.value,
                  ),
                  const SizedBox(height: 16),
                  //-----------------------------------------------------------------
                  //case 2
                  buildConfirmationSection(
                    title: 'Xác nhận đã dọn',
                    imagePublicIds: imagePublicIds2.value,
                    onImageUploaded: (url, publicId) {
                      images2.value = [...images2.value, url];
                      imagePublicIds2.value = [
                        ...imagePublicIds2.value,
                        publicId
                      ];
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tải ảnh lên thành công'),
                          backgroundColor: primaryOrange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageRemoved: (publicId) {
                      images2.value = images2.value
                          .where((url) => !url.contains(publicId))
                          .toList();
                      imagePublicIds2.value = imagePublicIds2.value
                          .where((id) => id != publicId)
                          .toList();

                      // Cập nhật lại resourceList trong IncidentRequest
                      request.value = PorterUpdateResourseRequest(
                        resourceList: request.value.resourceList
                            .where(
                                (resource) => resource.resourceCode != publicId)
                            .toList(),
                      );
                    },
                    onImageTapped: (url) => fullScreenImage.value = url,

                    onActionPressed: _createActionHandler(
                      images: images2.value,
                      imagePublicIds: imagePublicIds2.value,
                      trackerType: "PORTER_PACKING",
                    ),
                    actionButtonLabel: 'Xác nhận đóng gói',
                    actionIcon: Icons.location_on,
                    isEnabled: buildRouteFlags['canPorterConfirmPacking']!,
                    // isEnabled: status.canPorterConfirmIncoming,
                    showCameraButton: true,
                    request: request.value,
                  ),
                  const SizedBox(height: 16),
                  //-----------------------------------------------------------------
                  //case 3
                  buildConfirmationSection(
                    title: 'Xác nhận đã giao',
                    imagePublicIds: imagePublicIds3.value,
                    onImageUploaded: (url, publicId) {
                      images3.value = [...images3.value, url];
                      imagePublicIds3.value = [
                        ...imagePublicIds3.value,
                        publicId
                      ];
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tải ảnh lên thành công'),
                          backgroundColor: primaryOrange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageRemoved: (publicId) {
                      images3.value = images3.value
                          .where((url) => !url.contains(publicId))
                          .toList();
                      imagePublicIds3.value = imagePublicIds3.value
                          .where((id) => id != publicId)
                          .toList();

                      // Cập nhật lại resourceList trong IncidentRequest
                      request.value = PorterUpdateResourseRequest(
                        resourceList: request.value.resourceList
                            .where(
                                (resource) => resource.resourceCode != publicId)
                            .toList(),
                      );
                    },
                    onImageTapped: (url) => fullScreenImage.value = url,

                    onActionPressed: _createActionHandler(
                      images: images3.value,
                      imagePublicIds: imagePublicIds3.value,
                      trackerType: "PORTER_DELIVERED",
                    ),
                    actionButtonLabel: 'Xác nhận giao hàng',
                    actionIcon: Icons.location_on,
                    isEnabled: buildRouteFlags['canPorterConfirmDelivered']!,
                    // isEnabled: status.canPorterConfirmIncoming,
                    showCameraButton: true,
                    request: request.value,
                  ),
                  const SizedBox(height: 16),
                  //-----------------------------------------------------------------
                  //case 4
                  buildConfirmationSection(
                    title: 'Xác nhận dỡ hàng',
                    imagePublicIds: imagePublicIds4.value,
                    onImageUploaded: (url, publicId) {
                      images4.value = [...images4.value, url];
                      imagePublicIds4.value = [
                        ...imagePublicIds4.value,
                        publicId
                      ];
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tải ảnh lên thành công'),
                          backgroundColor: primaryOrange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageRemoved: (publicId) {
                      images4.value = images4.value
                          .where((url) => !url.contains(publicId))
                          .toList();
                      imagePublicIds4.value = imagePublicIds4.value
                          .where((id) => id != publicId)
                          .toList();

                      // Cập nhật lại resourceList trong IncidentRequest
                      request.value = PorterUpdateResourseRequest(
                        resourceList: request.value.resourceList
                            .where(
                                (resource) => resource.resourceCode != publicId)
                            .toList(),
                      );
                    },
                    onImageTapped: (url) => fullScreenImage.value = url,
                    onActionPressed: _createActionHandler(
                      images: images4.value,
                      imagePublicIds: imagePublicIds4.value,
                      trackerType: "PORTER_UNLOADED",
                    ),
                    actionButtonLabel: 'Xác nhận dỡ hàng',
                    actionIcon: Icons.location_on,
                    isEnabled: buildRouteFlags['canPorterCompleteUnloading']!,
                    // isEnabled: status.canPorterConfirmIncoming,
                    showCameraButton: true,
                    request: request.value,
                  ),
                  const SizedBox(height: 16),
                  //-----------------------------------------------------------------
                  //case 5
                  buildConfirmationSection(
                    title: 'Xác nhận hoàn thành',
                    imagePublicIds: imagePublicIds5.value,
                    onImageUploaded: (url, publicId) {
                      images5.value = [...images5.value, url];
                      imagePublicIds5.value = [
                        ...imagePublicIds5.value,
                        publicId
                      ];
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tải ảnh lên thành công'),
                          backgroundColor: primaryOrange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageRemoved: (publicId) {
                      images5.value = images5.value
                          .where((url) => !url.contains(publicId))
                          .toList();
                      imagePublicIds5.value = imagePublicIds5.value
                          .where((id) => id != publicId)
                          .toList();

                      // Cập nhật lại resourceList trong IncidentRequest
                      request.value = PorterUpdateResourseRequest(
                        resourceList: request.value.resourceList
                            .where(
                                (resource) => resource.resourceCode != publicId)
                            .toList(),
                      );
                    },
                    onImageTapped: (url) => fullScreenImage.value = url,
                    onActionPressed: _createActionHandler(
                      images: images5.value,
                      imagePublicIds: imagePublicIds5.value,
                      trackerType: "PORTER_COMPLETED",
                    ),
                    actionButtonLabel: 'Xác nhận hoàn thành',
                    actionIcon: Icons.location_on,
                    isEnabled: buildRouteFlags['canPorterComplete']!,
                    showCameraButton: true,
                    request: request.value,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Full screen image viewer
          if (fullScreenImage.value != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => fullScreenImage.value = null,
                child: Container(
                  color: Colors.black.withOpacity(0.9),
                  child: Stack(
                    children: [
                      Center(
                        child: Image.network(
                          fullScreenImage.value!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 16,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => fullScreenImage.value = null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
