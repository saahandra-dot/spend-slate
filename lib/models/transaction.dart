enum TransactionType { income, expense }

class ExpenseTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String category;
  final String? account;
  final String? note;

  const ExpenseTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.account,
    this.note,
  });
}
