enum BankType {
  banorte,
  banamex,
  bbva,
  santander,
  inbursa,
  scotiabank,
  hsbc,
  otro,
}

class BankAccount {
  final String id;
  final String accountHolder;
  final String accountNumber;
  final String alias;
  final BankType bankType;
  final String bankName;
  final bool isDefault;

  BankAccount({
    required this.id,
    required this.accountHolder,
    required this.accountNumber,
    required this.alias,
    required this.bankType,
    required this.bankName,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountHolder': accountHolder,
      'accountNumber': accountNumber,
      'alias': alias,
      'bankType': bankType.index,
      'bankName': bankName,
      'isDefault': isDefault,
    };
  }

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      id: map['id'],
      accountHolder: map['accountHolder'],
      accountNumber: map['accountNumber'],
      alias: map['alias'] ?? '',
      bankType: BankType.values[map['bankType']],
      bankName: map['bankName'],
      isDefault: map['isDefault'] ?? false,
    );
  }
}
