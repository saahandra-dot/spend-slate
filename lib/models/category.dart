import 'transaction.dart';

enum CategoryIconKey {
  groceries,
  cafe,
  clothing,
  transport,
  entertainment,
  health,
  education,
  bills,
  salary,
  freelance,
  business,
  investment,
  gift,
  money,
  other,
}

enum CategoryColorKey { purple, blue, green, orange, red, positive, secondary }

class AppCategory {
  final String id;
  final String name;
  final TransactionType type;
  final CategoryIconKey iconKey;
  final CategoryColorKey colorKey;
  final bool isBuiltIn;

  const AppCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.colorKey,
    this.isBuiltIn = true,
  });

  AppCategory copyWith({
    String? id,
    String? name,
    TransactionType? type,
    CategoryIconKey? iconKey,
    CategoryColorKey? colorKey,
    bool? isBuiltIn,
  }) {
    return AppCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconKey: iconKey ?? this.iconKey,
      colorKey: colorKey ?? this.colorKey,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }
}
