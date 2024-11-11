// booking_entities.dart

import 'package:movemate_staff/features/job/domain/entities/image_data.dart';
import 'package:movemate_staff/features/job/domain/entities/location_model_entities.dart';
import 'package:movemate_staff/features/job/domain/entities/service_entity.dart';

import 'package:movemate_staff/features/job/domain/entities/services_fee_system_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/services_package_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/sub_service_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/vehicle_entity.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';

class Booking {
  // final int id;
  final HouseEntities? houseType;

  final String? reviewType;
  final int? numberOfRooms;
  final int? numberOfFloors;
  final int? selectedVehicleIndex;
  final double vehiclePrice;
  final List<Vehicle> availableVehicles;
  final double totalPrice;
  final ServiceEntity? selectedVehicle;
  final ServiceEntity? selectedVehicleOld;

  final double packagePrice;
  final bool isRoundTrip;
  final bool isReviewOnline;
  final List<bool> checklistValues;
  final String notes;
  final String typeBooking;

  // Booking select package

  final int? selectedPackageIndex;
  final List<int> additionalServiceQuantities;
  final List<ServicesFeeSystemEntity> servicesFeeList;

  // Added from booking_provider_these.dart
  final List<ServicesPackageEntity> selectedPackages;
  final List<ServicesPackageEntity> selectedSubServices;
  final List<ServicesPackageEntity> selectedPackagesWithQuantity;

  // Image lists for each room
  final List<ImageData>? livingRoomImages;
  final List<ImageData> bedroomImages;
  final List<ImageData> diningRoomImages;
  final List<ImageData> officeRoomImages;
  final List<ImageData> bathroomImages;
  final bool? isUploadingLivingRoomImage;

  // Location
  final bool isSelectingPickUp;
  final LocationModel? pickUpLocation;
  final LocationModel? dropOffLocation;
  final DateTime? bookingDate;
  final String? estimatedDistance;

  Booking({
    this.houseType,
    this.reviewType,
    this.numberOfRooms,
    this.numberOfFloors,
    this.selectedVehicleIndex,
    this.vehiclePrice = 0.0,
    this.availableVehicles = const [],
    this.totalPrice = 0.0,
    this.packagePrice = 0.0,
    this.isRoundTrip = false,
    this.isReviewOnline = false,
    List<bool>? checklistValues,
    this.notes = '',
    this.typeBooking = '',
    this.servicesFeeList = const [],
    // Booking select packages
    this.selectedVehicle,
    this.selectedVehicleOld,
    this.selectedPackageIndex,
    this.additionalServiceQuantities = const [0, 0, 0],
    // Added fields
    this.selectedPackages = const [],
    this.selectedSubServices = const [],
    this.selectedPackagesWithQuantity = const [],

    // Location
    this.isSelectingPickUp = false,
    this.pickUpLocation,
    this.dropOffLocation,
    this.bookingDate,
    this.estimatedDistance,

    // Initialize image lists (empty by default)
    List<ImageData>? livingRoomImages,
    List<ImageData>? bedroomImages,
    List<ImageData>? diningRoomImages,
    List<ImageData>? officeRoomImages,
    List<ImageData>? bathroomImages,
    this.isUploadingLivingRoomImage = false,
  })  : checklistValues = checklistValues ?? List.filled(10, false),
        livingRoomImages = livingRoomImages ?? [],
        bedroomImages = bedroomImages ?? [],
        diningRoomImages = diningRoomImages ?? [],
        officeRoomImages = officeRoomImages ?? [],
        bathroomImages = bathroomImages ?? [];

  Booking copyWith({
    HouseEntities? houseType,
    String? reviewType,
    int? numberOfRooms,
    int? numberOfFloors,
    int? selectedVehicleIndex,
    double? vehiclePrice,
    List<Vehicle>? availableVehicles,
    double? totalPrice,
    double? packagePrice,
    bool? isRoundTrip,
    bool? isReviewOnline,
    List<bool>? checklistValues,
    String? notes,
    String? typeBooking,
    List<ServicesFeeSystemEntity>? servicesFeeList,
    // Booking select package
    ServiceEntity? selectedVehicle,
    ServiceEntity? selectedVehicleOld,
    int? selectedPackageIndex,
    List<int>? additionalServiceQuantities,
    // Added fields
    List<ServicesPackageEntity>? selectedPackages,
    List<ServicesPackageEntity>? selectedSubServices,
    List<ServicesPackageEntity>? selectedPackagesWithQuantity,

    // Location
    bool? isSelectingPickUp,
    LocationModel? pickUpLocation,
    LocationModel? dropOffLocation,
    DateTime? bookingDate,
    String? estimatedDistance,

    //add image
    List<ImageData>? livingRoomImages,
    List<ImageData>? bedroomImages,
    List<ImageData>? diningRoomImages,
    List<ImageData>? officeRoomImages,
    List<ImageData>? bathroomImages,
    bool? isUploadingLivingRoomImage,
  }) {
    return Booking(
      houseType: houseType ?? this.houseType,
      reviewType: reviewType ?? this.reviewType,
      numberOfRooms: numberOfRooms ?? this.numberOfRooms,
      numberOfFloors: numberOfFloors ?? this.numberOfFloors,
      selectedVehicleIndex: selectedVehicleIndex ?? this.selectedVehicleIndex,
      vehiclePrice: vehiclePrice ?? this.vehiclePrice,
      availableVehicles: availableVehicles ?? this.availableVehicles,
      totalPrice: totalPrice ?? this.totalPrice,
      packagePrice: packagePrice ?? this.packagePrice,
      isRoundTrip: isRoundTrip ?? this.isRoundTrip,
      isReviewOnline: isReviewOnline ?? this.isReviewOnline,
      checklistValues: checklistValues ?? this.checklistValues,
      notes: notes ?? this.notes,
      typeBooking: typeBooking ?? this.typeBooking,
      servicesFeeList: servicesFeeList ?? this.servicesFeeList,
      // Booking select package
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      selectedVehicleOld: selectedVehicleOld ?? this.selectedVehicleOld,

      selectedPackageIndex: selectedPackageIndex ?? this.selectedPackageIndex,
      additionalServiceQuantities:
          additionalServiceQuantities ?? this.additionalServiceQuantities,
      selectedPackagesWithQuantity:
          selectedPackagesWithQuantity ?? this.selectedPackagesWithQuantity,

      // Added fields
      selectedPackages: selectedPackages ?? this.selectedPackages,
      selectedSubServices: selectedSubServices ?? this.selectedSubServices,
      // Location
      isSelectingPickUp: isSelectingPickUp ?? this.isSelectingPickUp,
      pickUpLocation: pickUpLocation ?? this.pickUpLocation,
      dropOffLocation: dropOffLocation ?? this.dropOffLocation,
      bookingDate: bookingDate ?? this.bookingDate,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,

      //add image
      livingRoomImages: livingRoomImages ?? this.livingRoomImages,
      bedroomImages: bedroomImages ?? this.bedroomImages,
      diningRoomImages: diningRoomImages ?? this.diningRoomImages,
      officeRoomImages: officeRoomImages ?? this.officeRoomImages,
      bathroomImages: bathroomImages ?? this.bathroomImages,
      isUploadingLivingRoomImage:
          isUploadingLivingRoomImage ?? this.isUploadingLivingRoomImage,
    );
  }
}
