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
  final String rfc;
  final String curp;
  final BankType bankType;
  final String bankName;
  final bool isDefault;

  BankAccount({
    required this.id,
    required this.accountHolder,
    required this.accountNumber,
    required this.rfc,
    required this.curp,
    required this.bankType,
    required this.bankName,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountHolder': accountHolder,
      'accountNumber': accountNumber,
      'rfc': rfc,
      'curp': curp,
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
      rfc: map['rfc'],
      curp: map['curp'],
      bankType: BankType.values[map['bankType']],
      bankName: map['bankName'],
      isDefault: map['isDefault'] ?? false,
    );
  }
}
