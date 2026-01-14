enum TransactionType { income, expense }

class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final int iconPoint; // Using int to map to an IconData list

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.iconPoint = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.index, // Store enum index
      'iconPoint': iconPoint,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: TransactionType.values[map['type']],
      iconPoint: map['iconPoint'] ?? 0,
    );
  }
}
