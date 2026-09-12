import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/data/category_catalog.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../repositories/category_repository.dart';
import 'transaction_provider.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return CategoryRepository(database);
});

final categoriesProvider =
    AsyncNotifierProvider<CategoryController, List<AppCategory>>(
      CategoryController.new,
    );

final categoriesForTypeProvider =
    Provider.family<List<AppCategory>, TransactionType>((ref, type) {
      final loaded = ref.watch(categoriesProvider);

      final source = loaded.value ?? CategoryCatalog.categories;

      return source.where((category) => category.type == type).toList();
    });

class CategoryController extends AsyncNotifier<List<AppCategory>> {
  CategoryRepository get _repository => ref.read(categoryRepositoryProvider);

  @override
  Future<List<AppCategory>> build() {
    final repository = ref.watch(categoryRepositoryProvider);

    return repository.getCategories();
  }

  Future<void> addCategory(AppCategory category) async {
    _validateUniqueName(category);

    await _repository.addCategory(category);

    await _reload();
  }

  Future<void> updateCategory(
    AppCategory category, {
    required String previousName,
  }) async {
    _validateUniqueName(category, ignoreId: category.id);

    await _repository.updateCategory(category, previousName: previousName);

    await _reload();
  }

  Future<void> removeCategory(AppCategory category) async {
    await _repository.deleteCategory(category);

    await _reload();
  }

  void _validateUniqueName(AppCategory category, {String? ignoreId}) {
    final categories = state.value ?? const <AppCategory>[];

    final String normalized = category.name.trim().toLowerCase();

    final bool alreadyExists = categories.any((existing) {
      return existing.id != ignoreId &&
          existing.type == category.type &&
          existing.name.trim().toLowerCase() == normalized;
    });

    if (alreadyExists) {
      throw CategoryOperationException(
        'A ${category.type.name} category named "${category.name}" already exists.',
      );
    }
  }

  Future<void> _reload() async {
    state = AsyncData(await _repository.getCategories());
  }
}
