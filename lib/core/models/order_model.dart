import 'package:equatable/equatable.dart';
import 'garment_model.dart';

class OrderModel extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final List<OrderItem> items;
  final double totalAmount;
  final double taxAmount;
  final double shippingAmount;
  final double discountAmount;
  final double finalAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String? paymentId;
  final DateTime orderDate;
  final DateTime? estimatedCompletionDate;
  final DateTime? actualCompletionDate;
  final ShippingAddress? shippingAddress;
  final String? specialInstructions;
  final List<String> progressImages;
  final List<OrderStatusUpdate> statusHistory;
  final String? tailorId;
  final String? tailorName;
  final Map<String, dynamic>? metadata;

  const OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.items,
    required this.totalAmount,
    required this.taxAmount,
    required this.shippingAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.status,
    required this.paymentStatus,
    this.paymentId,
    required this.orderDate,
    this.estimatedCompletionDate,
    this.actualCompletionDate,
    this.shippingAddress,
    this.specialInstructions,
    required this.progressImages,
    required this.statusHistory,
    this.tailorId,
    this.tailorName,
    this.metadata,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerEmail: json['customerEmail'] as String,
      customerPhone: json['customerPhone'] as String?,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      shippingAmount: (json['shippingAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      finalAmount: (json['finalAmount'] as num).toDouble(),
      status: OrderStatus.fromString(json['status'] as String),
      paymentStatus: PaymentStatus.fromString(json['paymentStatus'] as String),
      paymentId: json['paymentId'] as String?,
      orderDate: DateTime.parse(json['orderDate'] as String),
      estimatedCompletionDate: json['estimatedCompletionDate'] != null
          ? DateTime.parse(json['estimatedCompletionDate'] as String)
          : null,
      actualCompletionDate: json['actualCompletionDate'] != null
          ? DateTime.parse(json['actualCompletionDate'] as String)
          : null,
      shippingAddress: json['shippingAddress'] != null
          ? ShippingAddress.fromJson(
              json['shippingAddress'] as Map<String, dynamic>)
          : null,
      specialInstructions: json['specialInstructions'] as String?,
      progressImages: List<String>.from(json['progressImages'] as List),
      statusHistory: (json['statusHistory'] as List)
          .map((update) =>
              OrderStatusUpdate.fromJson(update as Map<String, dynamic>))
          .toList(),
      tailorId: json['tailorId'] as String?,
      tailorName: json['tailorName'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'taxAmount': taxAmount,
      'shippingAmount': shippingAmount,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'status': status.value,
      'paymentStatus': paymentStatus.value,
      'paymentId': paymentId,
      'orderDate': orderDate.toIso8601String(),
      'estimatedCompletionDate': estimatedCompletionDate?.toIso8601String(),
      'actualCompletionDate': actualCompletionDate?.toIso8601String(),
      'shippingAddress': shippingAddress?.toJson(),
      'specialInstructions': specialInstructions,
      'progressImages': progressImages,
      'statusHistory': statusHistory.map((update) => update.toJson()).toList(),
      'tailorId': tailorId,
      'tailorName': tailorName,
      'metadata': metadata,
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    List<OrderItem>? items,
    double? totalAmount,
    double? taxAmount,
    double? shippingAmount,
    double? discountAmount,
    double? finalAmount,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentId,
    DateTime? orderDate,
    DateTime? estimatedCompletionDate,
    DateTime? actualCompletionDate,
    ShippingAddress? shippingAddress,
    String? specialInstructions,
    List<String>? progressImages,
    List<OrderStatusUpdate>? statusHistory,
    String? tailorId,
    String? tailorName,
    Map<String, dynamic>? metadata,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      shippingAmount: shippingAmount ?? this.shippingAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      orderDate: orderDate ?? this.orderDate,
      estimatedCompletionDate:
          estimatedCompletionDate ?? this.estimatedCompletionDate,
      actualCompletionDate: actualCompletionDate ?? this.actualCompletionDate,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      progressImages: progressImages ?? this.progressImages,
      statusHistory: statusHistory ?? this.statusHistory,
      tailorId: tailorId ?? this.tailorId,
      tailorName: tailorName ?? this.tailorName,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        customerEmail,
        customerPhone,
        items,
        totalAmount,
        taxAmount,
        shippingAmount,
        discountAmount,
        finalAmount,
        status,
        paymentStatus,
        paymentId,
        orderDate,
        estimatedCompletionDate,
        actualCompletionDate,
        shippingAddress,
        specialInstructions,
        progressImages,
        statusHistory,
        tailorId,
        tailorName,
        metadata,
      ];
}

class OrderItem extends Equatable {
  final String id;
  final String garmentId;
  final String garmentName;
  final GarmentType garmentType;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final Map<String, double> measurements;
  final Map<String, dynamic> customizations;
  final String? imageUrl;

  const OrderItem({
    required this.id,
    required this.garmentId,
    required this.garmentName,
    required this.garmentType,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.measurements,
    required this.customizations,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      garmentId: json['garmentId'] as String,
      garmentName: json['garmentName'] as String,
      garmentType: GarmentType.fromString(json['garmentType'] as String),
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      measurements: Map<String, double>.from(json['measurements'] as Map),
      customizations: Map<String, dynamic>.from(json['customizations'] as Map),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'garmentId': garmentId,
      'garmentName': garmentName,
      'garmentType': garmentType.value,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'measurements': measurements,
      'customizations': customizations,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object?> get props => [
        id,
        garmentId,
        garmentName,
        garmentType,
        quantity,
        unitPrice,
        totalPrice,
        measurements,
        customizations,
        imageUrl,
      ];
}

class ShippingAddress extends Equatable {
  final String fullName;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? phone;

  const ShippingAddress({
    required this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.phone,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['fullName'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [
        fullName,
        addressLine1,
        addressLine2,
        city,
        state,
        postalCode,
        country,
        phone,
      ];
}

class OrderStatusUpdate extends Equatable {
  final String id;
  final OrderStatus status;
  final String? message;
  final DateTime timestamp;
  final String? updatedBy;

  const OrderStatusUpdate({
    required this.id,
    required this.status,
    this.message,
    required this.timestamp,
    this.updatedBy,
  });

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdate(
      id: json['id'] as String,
      status: OrderStatus.fromString(json['status'] as String),
      message: json['message'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.value,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  @override
  List<Object?> get props => [id, status, message, timestamp, updatedBy];
}

enum OrderStatus {
  pending('pending'),
  confirmed('confirmed'),
  measuring('measuring'),
  designing('designing'),
  cutting('cutting'),
  sewing('sewing'),
  finishing('finishing'),
  qualityCheck('quality_check'),
  ready('ready'),
  shipped('shipped'),
  delivered('delivered'),
  cancelled('cancelled'),
  refunded('refunded');

  const OrderStatus(this.value);
  final String value;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.measuring:
        return 'Taking Measurements';
      case OrderStatus.designing:
        return 'Designing';
      case OrderStatus.cutting:
        return 'Cutting Fabric';
      case OrderStatus.sewing:
        return 'Sewing';
      case OrderStatus.finishing:
        return 'Finishing Touches';
      case OrderStatus.qualityCheck:
        return 'Quality Check';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }
}

enum PaymentStatus {
  pending('pending'),
  processing('processing'),
  paid('paid'),
  failed('failed'),
  refunded('refunded'),
  partiallyRefunded('partially_refunded');

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.processing:
        return 'Processing Payment';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Partially Refunded';
    }
  }
}
