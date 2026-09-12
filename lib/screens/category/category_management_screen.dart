import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/category_visuals.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import '../../providers/category_provider.dart';
import '../../repositories/category_repository.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen> {
  TransactionType _selectedType = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Categories',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openEditor();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Category'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: SegmentedButton<TransactionType>(
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Income'),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedType = selection.first;
                });
              },
            ),
          ),

          Expanded(
            child: categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: TextButton.icon(
                  onPressed: () {
                    ref.invalidate(categoriesProvider);
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
              ),
              data: (categories) {
                final visible = categories
                    .where((category) => category.type == _selectedType)
                    .toList();

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final category = visible[index];

                    return _CategoryTile(
                      category: category,
                      onEdit: category.isBuiltIn
                          ? null
                          : () {
                              _openEditor(category: category);
                            },
                      onDelete: category.isBuiltIn
                          ? null
                          : () {
                              _deleteCategory(category);
                            },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor({AppCategory? category}) async {
    final AppCategory? result = await showModalBottomSheet<AppCategory>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return _CategoryEditor(
          category: category,
          type: category?.type ?? _selectedType,
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    try {
      if (category == null) {
        await ref.read(categoriesProvider.notifier).addCategory(result);
      } else {
        await ref
            .read(categoriesProvider.notifier)
            .updateCategory(result, previousName: category.name);
      }
    } on CategoryOperationException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _deleteCategory(AppCategory category) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete category?'),
          content: Text('Delete "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(categoriesProvider.notifier).removeCategory(category);
    } on CategoryOperationException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _CategoryTile extends StatelessWidget {
  final AppCategory category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = category.colorKey.color;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(category.iconKey.iconData, color: color),
      ),
      title: Text(
        category.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(category.isBuiltIn ? 'Built-in' : 'Custom'),
      trailing: category.isBuiltIn
          ? const Icon(Icons.lock_outline_rounded, size: 19)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
    );
  }
}

class _CategoryEditor extends StatefulWidget {
  final AppCategory? category;
  final TransactionType type;

  const _CategoryEditor({required this.category, required this.type});

  @override
  State<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<_CategoryEditor> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  late CategoryIconKey _iconKey;
  late CategoryColorKey _colorKey;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.category?.name ?? '');

    _iconKey = widget.category?.iconKey ?? CategoryIconKey.other;

    _colorKey = widget.category?.colorKey ?? CategoryColorKey.purple;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorKey.color;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.category == null ? 'New Category' : 'Edit Category',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 22),

              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(_iconKey.iconData, color: color, size: 30),
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Category name'),
                validator: (value) {
                  final name = value?.trim() ?? '';

                  if (name.isEmpty) {
                    return 'Enter a category name';
                  }

                  if (name.length > 30) {
                    return 'Use 30 characters or fewer';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<CategoryIconKey>(
                initialValue: _iconKey,
                decoration: const InputDecoration(labelText: 'Icon'),
                items: CategoryIconKey.values.map((icon) {
                  return DropdownMenuItem(
                    value: icon,
                    child: Row(
                      children: [
                        Icon(icon.iconData, size: 20),
                        const SizedBox(width: 10),
                        Text(_label(icon.name)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _iconKey = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<CategoryColorKey>(
                initialValue: _colorKey,
                decoration: const InputDecoration(labelText: 'Color'),
                items: CategoryColorKey.values.map((colorKey) {
                  return DropdownMenuItem(
                    value: colorKey,
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: colorKey.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(_label(colorKey.name)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _colorKey = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(
                    widget.category == null ? 'Add Category' : 'Save Changes',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final existing = widget.category;

    Navigator.of(context).pop(
      AppCategory(
        id: existing?.id ?? 'custom-${DateTime.now().microsecondsSinceEpoch}',
        name: _nameController.text.trim(),
        type: widget.type,
        iconKey: _iconKey,
        colorKey: _colorKey,
        isBuiltIn: false,
      ),
    );
  }

  static String _label(String value) {
    return value[0].toUpperCase() + value.substring(1);
  }
}
