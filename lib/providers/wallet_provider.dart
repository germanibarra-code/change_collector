import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_item.dart';
import '../models/savings_goal.dart';
import '../models/bank_account.dart';

class WalletProvider with ChangeNotifier {
  List<TransactionItem> _transactions = [];
  List<SavingsGoal> _goals = [];
  List<BankAccount> _bankAccounts = [];
  bool _isLoading = true;

  List<TransactionItem> get transactions => _transactions;
  List<SavingsGoal> get goals => _goals;
  List<BankAccount> get bankAccounts => _bankAccounts;
  bool get isLoading => _isLoading;

  // Calculated properties
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalBalance => totalIncome - totalExpense;

  WalletProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Transactions
    final List<String>? transactionsJson = prefs.getStringList('transactions');
    if (transactionsJson != null) {
      _transactions = transactionsJson
          .map((item) => TransactionItem.fromMap(json.decode(item)))
          .toList();
      // Sort by date descending
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    } else {
      // Seed initial demo data if empty
      _seedDemoData();
    }

    // Load Goals
    final List<String>? goalsJson = prefs.getStringList('goals');
    if (goalsJson != null) {
      _goals = goalsJson
          .map((item) => SavingsGoal.fromMap(json.decode(item)))
          .toList();
    }

    // Load Bank Accounts
    final List<String>? bankAccountsJson = prefs.getStringList('bankAccounts');
    if (bankAccountsJson != null) {
      _bankAccounts = bankAccountsJson
          .map((item) => BankAccount.fromMap(json.decode(item)))
          .toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _seedDemoData() {
    if (_transactions.isNotEmpty) return;

    _transactions = [
      TransactionItem(
        id: DateTime.now().subtract(const Duration(hours: 4)).toString(),
        title: 'Cambio en Oxxo',
        amount: 39.21,
        date: DateTime.now().subtract(const Duration(hours: 4)),
        type: TransactionType.income,
        iconPoint: 0, // Piggy bank or generic
      ),
      TransactionItem(
        id: DateTime.now().subtract(const Duration(hours: 20)).toString(),
        title: 'Pago en Comercio (Demo)',
        amount: 5.00,
        date: DateTime.now().subtract(const Duration(hours: 20)),
        type: TransactionType.expense,
        iconPoint: 1, // Bolt or electricity
      ),
    ];
    _saveTransactions();
  }

  Future<void> addTransaction(TransactionItem transaction) async {
    _transactions.insert(0, transaction); // Add to top
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> addGoal(SavingsGoal goal) async {
    _goals.add(goal);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> addBankAccount(BankAccount account) async {
    _bankAccounts.add(account);
    await _saveBankAccounts();
    notifyListeners();
  }

  Future<void> removeBankAccount(String id) async {
    _bankAccounts.removeWhere((acc) => acc.id == id);
    await _saveBankAccounts();
    notifyListeners();
  }

  Future<void> transferToBank(double amount, BankAccount account) async {
    final transfer = TransactionItem(
      id: DateTime.now().toString(),
      title: 'Transferencia a ${account.bankName}',
      amount: amount,
      date: DateTime.now(),
      type: TransactionType.expense,
      iconPoint: 2,
    );
    await addTransaction(transfer);
    notifyListeners();
  }

  // Persistence Helpers
  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = _transactions
        .map((item) => json.encode(item.toMap()))
        .toList();
    await prefs.setStringList('transactions', data);
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = _goals
        .map((item) => json.encode(item.toMap()))
        .toList();
    await prefs.setStringList('goals', data);
  }

  Future<void> _saveBankAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = _bankAccounts
        .map((item) => json.encode(item.toMap()))
        .toList();
    await prefs.setStringList('bankAccounts', data);
  }

  // Debug/Reset
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('transactions');
    await prefs.remove('goals');
    await prefs.remove('bankAccounts');
    _transactions = [];
    _goals = [];
    _bankAccounts = [];
    notifyListeners();
  }
}
