// class Product {
//   final int id;
//   final String title;
//   final String description;
//   final String category;
//   final double price;
//   final double rating;
//   final String thumbnail;
//   final List<String> images;

//   Product({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.category,
//     required this.price,
//     required this.rating,
//     required this.thumbnail,
//     required this.images,
//   });

//   factory Product.fromJson(Map<String, dynamic> j) => Product(
//         id: j['id'] as int? ?? 0,
//         title: j['title'] as String? ?? '',
//         description: j['description'] as String? ?? '',
//         category: j['category'] as String? ?? '',
//         price: (j['price'] as num?)?.toDouble() ?? 0.0,
//         rating: (j['rating'] as num?)?.toDouble() ?? 0.0,
//         thumbnail: j['thumbnail'] as String? ?? '',
//         images: (j['images'] as List?)?.cast<String>() ?? const [],
//       );

//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'title': title,
//         'description': description,
//         'category': category,
//         'price': price,
//         'rating': rating,
//         'thumbnail': thumbnail,
//         'images': images,
//       };
// }
