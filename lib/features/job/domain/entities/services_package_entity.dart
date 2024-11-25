// services_package_entity.dart

import 'dart:convert';
import 'package:movemate_staff/features/job/domain/entities/truck_category_entity.dart';

class ServicesPackageEntity {
  final int id;
  final String name;
  final String description;
  final bool isActived;
  final int tier;
  final String imageUrl;
  final int? quantity; // Added quantity field
  final String? type;
  final double discountRate;
  final double amount;
  final int? parentServiceId;
    final int? quantityMax; // Thêm trường này
    final bool isQuantity; // Thêm trường này
  final TruckCategoryEntity? truckCategory;
  final List<ServicesPackageEntity> inverseParentService;

  ServicesPackageEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.isActived,
    required this.isQuantity,
    required this.tier,
    required this.imageUrl,
    this.quantity, // Include in constructor
    this.type,
    required this.discountRate,
    required this.amount,
    required this.quantityMax,
    this.parentServiceId,
    this.truckCategory,
    required this.inverseParentService,
  });

  // Added copyWith method
  ServicesPackageEntity copyWith({
    int? id,
    String? name,
    String? description,
    bool? isActived,
    bool? isQuantity,
    int? tier,
    String? imageUrl,
    int? quantity,
    String? type,
    double? discountRate,
    double? amount,
    int? parentServiceId,
    int? quantityMax,
    TruckCategoryEntity? truckCategory,
    List<ServicesPackageEntity>? inverseParentService,
  }) {
    return ServicesPackageEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActived: isActived ?? this.isActived,
      isQuantity: isQuantity ?? this.isQuantity,
      tier: tier ?? this.tier,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity, // Handle quantity
      type: type ?? this.type,
      discountRate: discountRate ?? this.discountRate,
      amount: amount ?? this.amount,
      parentServiceId: parentServiceId ?? this.parentServiceId,
      quantityMax: quantityMax ?? this.quantityMax,
      truckCategory: truckCategory ?? this.truckCategory,
      inverseParentService: inverseParentService ?? this.inverseParentService,
    );
  }

  factory ServicesPackageEntity.fromMap(Map<String, dynamic> map) {
    return ServicesPackageEntity(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      isActived: map['isActived'] ?? false,
      isQuantity: map['isQuantity'] ?? false,
      tier: map['tier'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      quantity: map['quantity'], // Parse quantity
      type: map['type'],
      discountRate: (map['discountRate'] ?? 0).toDouble(),
      amount: (map['amount'] ?? 0).toDouble(),
      parentServiceId: map['parentServiceId'],
      quantityMax: map['quantityMax'] ?? 0,
      truckCategory: map['truckCategory'] != null
          ? TruckCategoryEntity.fromMap(map['truckCategory'])
          : null,
      inverseParentService: map['inverseParentService'] != null
          ? List<ServicesPackageEntity>.from(map['inverseParentService']
              .map((x) => ServicesPackageEntity.fromMap(x)))
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActived': isActived,
      'isQuantity': isQuantity,
      'tier': tier,
      'imageUrl': imageUrl,
      'quantity': quantity, // Include in map
      'type': type,
      'discountRate': discountRate,
      'amount': amount,
      'parentServiceId': parentServiceId,
      'quantityMax': quantityMax,
      'truckCategory': truckCategory?.toMap(),
      'inverseParentService':
          inverseParentService.map((x) => x.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());

  factory ServicesPackageEntity.fromJson(String source) =>
      ServicesPackageEntity.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ServicesPackageEntity(id: $id, name: $name, description: $description, isActived: $isActived, tier: $tier, imageUrl: $imageUrl, quantity: $quantity, type: $type, discountRate: $discountRate, amount: $amount, parentServiceId: $parentServiceId, truckCategory: $truckCategory, inverseParentService: $inverseParentService)';
  }
}
