import 'dart:convert';

/// Top-level ürün modeli
class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String brand;
  final String sku;
  final double weight;
  final Dimensions dimensions;
  final String warrantyInformation;
  final String shippingInformation;
  final String availabilityStatus;
  final List<Review> reviews;
  final String returnPolicy;
  final int minimumOrderQuantity;
  final Meta meta;
  final List<String> images;
  final String thumbnail;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.brand,
    required this.sku,
    required this.weight,
    required this.dimensions,
    required this.warrantyInformation,
    required this.shippingInformation,
    required this.availabilityStatus,
    required this.reviews,
    required this.returnPolicy,
    required this.minimumOrderQuantity,
    required this.meta,
    required this.images,
    required this.thumbnail,
  });

  // ---------- JSON helpers ----------
  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as int,
        title: (j['title'] as String?) ?? 'Ürün Adı',
        description: (j['description'] as String?) ?? 'Açıklama mevcut değil',
        category: (j['category'] as String?) ?? 'Diğer',
        price: (j['price'] as num?)?.toDouble() ?? 0.0,
        discountPercentage: (j['discountPercentage'] as num?)?.toDouble() ?? 0.0,
        // FakeStoreAPI: rating is an object with {rate: number, count: number}
        rating: j['rating'] != null ? (j['rating'] is Map ? (j['rating']['rate'] as num?)?.toDouble() ?? 0.0 : (j['rating'] as num?)?.toDouble() ?? 0.0) : 0.0,
        stock: (j['stock'] as int?) ?? 0,
        tags: j['tags'] != null ? List<String>.from(j['tags'] as List) : [],
        brand: (j['brand'] as String?) ?? 'Marka Belirtilmemiş',
        sku: (j['sku'] as String?) ?? '',
        weight: (j['weight'] as num?)?.toDouble() ?? 0.0,
        dimensions: j['dimensions'] != null ? Dimensions.fromJson(j['dimensions']) : Dimensions(width: 0, height: 0, depth: 0),
        warrantyInformation: (j['warrantyInformation'] as String?) ?? 'Garanti bilgisi mevcut değil',
        shippingInformation: (j['shippingInformation'] as String?) ?? 'Kargo bilgisi mevcut değil',
        availabilityStatus: (j['availabilityStatus'] as String?) ?? 'Stok durumu bilinmiyor',
        reviews: j['reviews'] != null ? (j['reviews'] as List).map((e) => Review.fromJson(e)).toList(growable: false) : [],
        returnPolicy: (j['returnPolicy'] as String?) ?? 'İade politikası mevcut değil',
        minimumOrderQuantity: (j['minimumOrderQuantity'] as int?) ?? 1,
        meta: j['meta'] != null ? Meta.fromJson(j['meta']) : Meta(createdAt: DateTime.now(), updatedAt: DateTime.now(), barcode: '', qrCode: ''),
        // FakeStoreAPI: single 'image' field instead of 'images' array
        images: j['images'] != null ? List<String>.from(j['images'] as List) : (j['image'] != null ? [j['image'] as String] : []),
        thumbnail: (j['thumbnail'] as String?) ?? (j['image'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'discountPercentage': discountPercentage,
        'rating': rating,
        'stock': stock,
        'tags': tags,
        'brand': brand,
        'sku': sku,
        'weight': weight,
        'dimensions': dimensions.toJson(),
        'warrantyInformation': warrantyInformation,
        'shippingInformation': shippingInformation,
        'availabilityStatus': availabilityStatus,
        'reviews': reviews.map((e) => e.toJson()).toList(),
        'returnPolicy': returnPolicy,
        'minimumOrderQuantity': minimumOrderQuantity,
        'meta': meta.toJson(),
        'images': images,
        'thumbnail': thumbnail,
      };

  @override
  String toString() => jsonEncode(toJson());
}

/// Alt model: ebatlar
class Dimensions {
  final double width;
  final double height;
  final double depth;

  Dimensions({
    required this.width,
    required this.height,
    required this.depth,
  });

  factory Dimensions.fromJson(Map<String, dynamic> j) => Dimensions(
        width: (j['width'] as num?)?.toDouble() ?? 0.0,
        height: (j['height'] as num?)?.toDouble() ?? 0.0,
        depth: (j['depth'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
        'depth': depth,
      };
}

/// Alt model: kullanıcı yorumu
class Review {
  final double rating;
  final String comment;
  final DateTime date;
  final String reviewerName;
  final String reviewerEmail;

  Review({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  factory Review.fromJson(Map<String, dynamic> j) => Review(
        rating: (j['rating'] as num?)?.toDouble() ?? 0.0,
        comment: (j['comment'] as String?) ?? '',
        date: j['date'] != null ? DateTime.parse(j['date'] as String) : DateTime.now(),
        reviewerName: (j['reviewerName'] as String?) ?? 'Anonim',
        reviewerEmail: (j['reviewerEmail'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'comment': comment,
        'date': date.toIso8601String(),
        'reviewerName': reviewerName,
        'reviewerEmail': reviewerEmail,
      };
}

/// Alt model: meta bilgiler
class Meta {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String barcode;
  final String qrCode;

  Meta({
    required this.createdAt,
    required this.updatedAt,
    required this.barcode,
    required this.qrCode,
  });

  factory Meta.fromJson(Map<String, dynamic> j) => Meta(
        createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt'] as String) : DateTime.now(),
        updatedAt: j['updatedAt'] != null ? DateTime.parse(j['updatedAt'] as String) : DateTime.now(),
        barcode: (j['barcode'] as String?) ?? '',
        qrCode: (j['qrCode'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'barcode': barcode,
        'qrCode': qrCode,
      };
}
