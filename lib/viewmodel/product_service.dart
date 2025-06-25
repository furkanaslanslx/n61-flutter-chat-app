import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:n61/m/product_model.dart';

/// Fetches products from FakeStoreAPI ( https://fakestoreapi.com/products ).
class ProductService {
  ProductService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  static const String _base = 'https://fakestoreapi.com/products';

  /// Returns a page of products.
  ///
  /// * [page]  : 1-den başlar (FakeStoreAPI'de sayfalama sınırlı).
  /// * [limit] : FakeStoreAPI max 20 ürün; varsayılan 20.
  ///
  /// Not: FakeStoreAPI limit parametresi sorun çıkardığından, tüm ürünleri alıp client-side'da limit uyguluyoruz.
  Future<List<Product>> fetch({int page = 1, int limit = 20}) async {
    assert(page >= 1 && limit > 0, 'page & limit must be positive');

    // FakeStoreAPI limit parameter causes 403 errors, so we fetch all and limit client-side
    final uri = Uri.parse(_base);

    try {
      final res = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Flutter-App',
        },
      );
      if (res.statusCode != 200) {
        throw Exception('FakeStoreAPI HTTP ${res.statusCode}: ${res.body}');
      }

      // FakeStoreAPI returns direct array, not wrapped in { products: [...] }
      final List list = jsonDecode(res.body) as List<dynamic>;

      // Apply client-side pagination since FakeStoreAPI limit parameter doesn't work reliably
      final startIndex = (page - 1) * limit;
      final paginatedList = list.skip(startIndex).take(limit).toList();

      return paginatedList.cast<Map<String, dynamic>>().map((json) {
        try {
          return Product.fromJson(json);
        } catch (e) {
          debugPrint('Error parsing product: $e');
          debugPrint('Product JSON: $json');
          rethrow;
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Fetch a single product by its numeric [id].
  Future<Product> fetchById(int id) async {
    try {
      final uri = Uri.parse('$_base/$id');
      final res = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Flutter-App',
        },
      );
      if (res.statusCode != 200) {
        throw Exception('Product $id not found (HTTP ${res.statusCode}): ${res.body}');
      }
      return Product.fromJson(jsonDecode(res.body));
    } catch (e) {
      throw Exception('Failed to fetch product $id: $e');
    }
  }

  void close() => _client.close();
}
