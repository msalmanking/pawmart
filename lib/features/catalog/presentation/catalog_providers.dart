import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../product/data/product_repository.dart';
import '../data/category_repository.dart';
import '../../product/domain/product.dart';
import '../domain/category.dart';

/// ---- Products --------------------------------------------------------

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(Supabase.instance.client),
);

final bestsellersProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.fetchProducts(limit: 10);
});

final productsByCategoryProvider =
    FutureProvider.family<List<Product>, String>((ref, categoryId) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.fetchByCategory(categoryId);
});

final selectedProductIdProvider = StateProvider<String?>((ref) => null);

final productByIdProvider =
    FutureProvider.family<Product?, String>((ref, productId) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.fetchById(productId);
});

/// ---- Categories --------------------------------------------------------

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(Supabase.instance.client),
);

final petCategoriesProvider = FutureProvider<List<PetCategory>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.fetchByType('pet');
});

final needCategoriesProvider = FutureProvider<List<PetCategory>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.fetchByType('need');
});

final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);
final selectedCategoryNameProvider = StateProvider<String>((ref) => 'Products');

/// ---- Search --------------------------------------------------------

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Product>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  final repo = ref.watch(productRepositoryProvider);
  return repo.search(query);
});

/// ---- Filters (single source of truth, per runbook rule) ---------------

class ProductFilter {
  final int sortIndex;
  final int priceIndex;
  final String? lifeStage;
  final String? brand;

  const ProductFilter({
    this.sortIndex = 0,
    this.priceIndex = -1,
    this.lifeStage,
    this.brand,
  });

  ProductFilter copyWith({
    int? sortIndex,
    int? priceIndex,
    String? Function()? lifeStage,
    String? Function()? brand,
  }) {
    return ProductFilter(
      sortIndex: sortIndex ?? this.sortIndex,
      priceIndex: priceIndex ?? this.priceIndex,
      lifeStage: lifeStage != null ? lifeStage() : this.lifeStage,
      brand: brand != null ? brand() : this.brand,
    );
  }
}

final productFilterProvider =
    StateProvider<ProductFilter>((ref) => const ProductFilter());

List<Product> applyProductFilter(List<Product> products, ProductFilter filter) {
  var result = List<Product>.from(products);

  if (filter.priceIndex == 0) {
    result = result.where((p) => p.price < 50).toList();
  } else if (filter.priceIndex == 1) {
    result = result.where((p) => p.price >= 50 && p.price <= 150).toList();
  } else if (filter.priceIndex == 2) {
    result = result.where((p) => p.price > 150 && p.price <= 300).toList();
  } else if (filter.priceIndex == 3) {
    result = result.where((p) => p.price > 300).toList();
  }

  if (filter.lifeStage != null) {
    result = result.where((p) => p.lifeStage == filter.lifeStage).toList();
  }

  if (filter.brand != null) {
    result = result.where((p) => p.brand == filter.brand).toList();
  }

  if (filter.sortIndex == 1) {
    result.sort((a, b) => a.price.compareTo(b.price));
  }

  return result;
}
