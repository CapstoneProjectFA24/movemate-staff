// booking_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_enities.dart';
import 'package:movemate_staff/features/job/domain/entities/booking_response_entity/booking_response_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/image_data.dart';
import 'package:movemate_staff/features/job/domain/entities/location_model_entities.dart';
import 'package:movemate_staff/features/job/domain/entities/service_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/services_fee_system_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/services_package_entity.dart';
import 'package:movemate_staff/features/job/domain/entities/sub_service_entity.dart';
import 'package:movemate_staff/features/test/domain/entities/house_entities.dart';

class BookingNotifier extends StateNotifier<Booking> {
  static const int maxImages = 5; // Giới hạn hình ảnh tối đa
  BookingNotifier()
      : super(Booking(
          totalPrice: 0.0,
          additionalServiceQuantities: [],
        ));

  void updateBookingDetails(BookingResponseEntity job) {
    state = state.copyWith(
      numberOfRooms: int.tryParse(job.roomNumber),
      numberOfFloors: int.tryParse(job.floorsNumber),
      bookingDate: DateTime.parse(job.createdAt),
      houseType: HouseEntities(
        id: job.houseTypeId,
        // thêm các thông tin house type khác nếu có
        description: "",
        name: job.houseTypeId.toString(),
      ),
    );
  }

  // // Map để lưu trữ booking details tạm thời
  // final Map<int, int> pendingBookingDetails = {};
  // // Method để lưu trữ booking detail
  // void storeBookingDetail(BookingDetailsResponseEntity detail) {
  //   pendingBookingDetails[detail.serviceId] = detail.quantity;
  // }

  void updateSubServiceQuantity(
      ServicesPackageEntity subService, int newQuantity) {
    int finalQuantity = newQuantity;
    if (subService.quantityMax != null &&
        newQuantity > subService.quantityMax!) {
      finalQuantity = subService.quantityMax!;
    }

    List<ServicesPackageEntity> updatedSubServices =
        List.from(state.selectedSubServices);

    final index = updatedSubServices.indexWhere((s) => s.id == subService.id);

    if (index != -1) {
      if (finalQuantity > 0) {
        updatedSubServices[index] =
            updatedSubServices[index].copyWith(quantity: finalQuantity);
      } else {
        updatedSubServices.removeAt(index);
      }
    } else {
      if (finalQuantity > 0) {
        updatedSubServices.add(subService.copyWith(quantity: finalQuantity));
      }
    }

    state = state.copyWith(selectedSubServices: updatedSubServices);
    calculateAndUpdateTotalPrice();
  }

  void updateServicesFeeQuantity(ServicesFeeSystemEntity fee, int newQuantity) {
    List<ServicesFeeSystemEntity> updatedServicesFeeList =
        List.from(state.servicesFeeList ?? []);

    final index = updatedServicesFeeList.indexWhere((f) => f.id == fee.id);

    if (index != -1) {
      if (newQuantity > 0) {
        // Update existing fee's quantity
        updatedServicesFeeList[index] =
            updatedServicesFeeList[index].copyWith(quantity: newQuantity);
      } else {
        // Remove fee if quantity is zero
        updatedServicesFeeList.removeAt(index);
      }
    } else {
      if (newQuantity > 0) {
        // Add new fee with specified quantity
        updatedServicesFeeList.add(fee.copyWith(quantity: newQuantity));
      }
    }

    state = state.copyWith(servicesFeeList: updatedServicesFeeList);

    // Recalculate total price
    calculateAndUpdateTotalPrice();
  }

// Method to update selected vehicle
  void updateSelectedVehicle(ServiceEntity vehicle) {
    state = state.copyWith(selectedVehicle: vehicle);
    calculateAndUpdateTotalPrice();
  }

  void updateSelectedVehicleOld(ServiceEntity vehicle) {
    state = state.copyWith(selectedVehicleOld: vehicle);
  }

  void updateServicePackageQuantity(
    ServicesPackageEntity servicePackage,
    int newQuantity,
  ) {
    List<ServicesPackageEntity> updatedPackages =
        List.from(state.selectedPackages);

    final index = updatedPackages.indexWhere((p) => p.id == servicePackage.id);

    if (index != -1) {
      if (newQuantity > 0) {
        updatedPackages[index] =
            updatedPackages[index].copyWith(quantity: newQuantity);
      } else {
        updatedPackages.removeAt(index);
      }
    } else {
      if (newQuantity > 0) {
        updatedPackages.add(servicePackage.copyWith(quantity: newQuantity));
      }
    }

    state = state.copyWith(selectedPackages: updatedPackages);
    calculateAndUpdateTotalPrice();
  }

  void calculateAndUpdateTotalPrice() {
    double total = 0.0;

    // Tổng giá của các gói dịch vụ đã chọn
    for (var package in state.selectedPackages) {
      if ((package.quantity != null && package.quantity! > 0)) {
        total += package.amount * package.quantity!;
      }
    }

    // Tổng giá của các dịch vụ phụ đã chọn với số lượng
    for (var subService in state.selectedSubServices) {
      total += subService.amount * (subService.quantity ?? 1);
    }

    // Tổng giá của các dịch vụ phí hệ thống với số lượng
    for (var fee in state.servicesFeeList ?? []) {
      total += fee.amount * (fee.quantity ?? 0);
    }

    // Thêm giá của phương tiện đã chọn
    if (state.selectedVehicle != null) {
      total += state.selectedVehicle!.amount;
    }

    // Các tính toán khác (ví dụ: chuyến đi khứ hồi)
    if (state.isRoundTrip == true) {
      total *= 2;
    }

    // Tính thuế GTGT
    double vat = total * 0.08;

    // Cập nhật tổng giá bao gồm thuế GTGT
    total += vat;
    // Cập nhật tổng giá
    state = state.copyWith(totalPrice: total);
  }

  void updateBookingResponse(BookingResponseEntity response) {
    state = state.copyWith(
      totalPrice: response.total.toDouble(),
      // Bạn có thể cập nhật thêm các trường khác nếu cần
    );
  }

  // Replaced updateRoundTrip method
  void updateRoundTrip(bool value) {
    state = state.copyWith(isRoundTrip: value);
    calculateAndUpdateTotalPrice();
  }

  void updateHouseType(HouseEntities? houseType) {
    state = state.copyWith(houseType: houseType);
  }

  void updateNumberOfRooms(int rooms) {
    state = state.copyWith(numberOfRooms: rooms);
  }

  void updateNumberOfFloors(int floors) {
    state = state.copyWith(numberOfFloors: floors);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void updateEstimatedDeliveryTime(String estimatedDeliveryTime) {
    state = state.copyWith(estimatedDeliveryTime: estimatedDeliveryTime);
  }

// Phương thức lấy danh sách hình ảnh cho một loại phòng
  List<ImageData> getImages(RoomType roomType) {
    switch (roomType) {
      case RoomType.livingRoom:
        return state.livingRoomImages ?? [];
      case RoomType.bedroom:
        return state.bedroomImages;
      case RoomType.diningRoom:
        return state.diningRoomImages;
      case RoomType.officeRoom:
        return state.officeRoomImages;
      case RoomType.bathroom:
        return state.bathroomImages;
    }
  }

  // Method to set the loading state for uploading living room images
  void setUploadingLivingRoomImage(bool isUploading) {
    state = state.copyWith(isUploadingLivingRoomImage: isUploading);
  }

  bool canAddImage(RoomType roomType) {
    final images = getImages(roomType);
    return images.length < BookingNotifier.maxImages;
  }

  // Method to add image to a room
  Future<void> addImageToRoom(RoomType roomType, ImageData imageData) async {
    if (!canAddImage(roomType)) {
      // Không thêm hình ảnh nếu đã đạt giới hạn
      return;
    }

    // Set loading state if roomType is livingRoom
    if (roomType == RoomType.livingRoom) {
      setUploadingLivingRoomImage(true);
    }

    try {
      switch (roomType) {
        case RoomType.livingRoom:
          final currentImages =
              List<ImageData>.from(state.livingRoomImages?.toList() ?? []);
          if (currentImages.length < BookingNotifier.maxImages) {
            currentImages.add(imageData);
            state = state.copyWith(livingRoomImages: currentImages);
          }
          break;
        case RoomType.bedroom:
          state = state.copyWith(
            bedroomImages: [...state.bedroomImages, imageData],
          );
          break;
        case RoomType.diningRoom:
          state = state.copyWith(
            diningRoomImages: [...state.diningRoomImages, imageData],
          );
          break;
        case RoomType.officeRoom:
          state = state.copyWith(
            officeRoomImages: [...state.officeRoomImages, imageData],
          );
          break;
        case RoomType.bathroom:
          state = state.copyWith(
            bathroomImages: [...state.bathroomImages, imageData],
          );
          break;
      }
    } finally {
      
      // Reset loading state
      if (roomType == RoomType.livingRoom) {
        setUploadingLivingRoomImage(false);
      }
    }
  }

// Method to remove image to a room
  void removeImageFromRoom(RoomType roomType, ImageData imageData) {
    switch (roomType) {
      case RoomType.livingRoom:
        final currentImages =
            List<ImageData>.from(state.livingRoomImages ?? []);
        currentImages
            .removeWhere((image) => image.publicId == imageData.publicId);
        state = state.copyWith(livingRoomImages: currentImages);
        break;
      case RoomType.bedroom:
        state = state.copyWith(
          bedroomImages: state.bedroomImages
              .where((img) => img.publicId != imageData.publicId)
              .toList(),
        );
        break;
      case RoomType.diningRoom:
        state = state.copyWith(
          diningRoomImages: state.diningRoomImages
              .where((img) => img.publicId != imageData.publicId)
              .toList(),
        );
        break;
      case RoomType.officeRoom:
        state = state.copyWith(
          officeRoomImages: state.officeRoomImages
              .where((img) => img.publicId != imageData.publicId)
              .toList(),
        );
        break;
      case RoomType.bathroom:
        state = state.copyWith(
          bathroomImages: state.bathroomImages
              .where((img) => img.publicId != imageData.publicId)
              .toList(),
        );
        break;
    }
  }

  void updateChecklistValue(int index, bool value) {
    final updatedChecklistValues = List<bool>.from(state.checklistValues);
    updatedChecklistValues[index] = value;
    state = state.copyWith(checklistValues: updatedChecklistValues);
  }

  // Location methods
  void updatePickUpLocation(LocationModel location) {
    state = state.copyWith(pickUpLocation: location);
  }

  void updateDropOffLocation(LocationModel location) {
    state = state.copyWith(dropOffLocation: location);
  }

  void updateBookingDate(DateTime date) {
    state = state.copyWith(bookingDate: date);
  }

  void toggleSelectingPickUp(bool isSelecting) {
    state = state.copyWith(isSelectingPickUp: isSelecting);
  }

  void updateIsReviewOnline(bool isReviewOnline) {
    state = state.copyWith(isReviewOnline: isReviewOnline);
  }

  void reset() {
    state = Booking(
      totalPrice: 0.0,
      additionalServiceQuantities: [],
      selectedSubServices: [],
      servicesFeeList: [],
      selectedVehicle: null,
      selectedPackages: [],
      livingRoomImages: [],
      bedroomImages: [],
      diningRoomImages: [],
      officeRoomImages: [],
      bathroomImages: [],
      checklistValues: [],
      pickUpLocation: null,
      dropOffLocation: null,
      bookingDate: DateTime.now(),
      isSelectingPickUp: false,
      isReviewOnline: false,
      houseType: null,
      numberOfRooms: 0,
      numberOfFloors: 0,
      notes: "",
      isRoundTrip: false,
      // Additional fields for your booking form
    );
  }
}

// The global provider that can be accessed in all screens
final bookingProvider = StateNotifierProvider<BookingNotifier, Booking>(
  (ref) => BookingNotifier(),
);

enum RoomType { livingRoom, bedroom, diningRoom, officeRoom, bathroom }
