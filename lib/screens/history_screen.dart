import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/wallet_provider.dart';
import '../models/transaction_item.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const HistoryScreen({super.key, this.onBack});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // 0: All, 1: Income, 2: Expense
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, provider, child) {
        // Filter logic
        List<TransactionItem> displayedTransactions = provider.transactions;
        if (_selectedFilter == 1) {
          displayedTransactions = provider.transactions
              .where((t) => t.type == TransactionType.income)
              .toList();
        } else if (_selectedFilter == 2) {
          displayedTransactions = provider.transactions
              .where((t) => t.type == TransactionType.expense)
              .toList();
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Use callback if provided (from IndexedStack)
                          if (widget.onBack != null) {
                            widget.onBack!();
                          } else if (Navigator.canPop(context)) {
                            // Otherwise try to pop if possible
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Movimientos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      _buildFilterChip('Todos', 0),
                      const SizedBox(width: 12),
                      _buildFilterChip('Ingresos', 1),
                      const SizedBox(width: 12),
                      _buildFilterChip('Gastos', 2),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // List
                Expanded(
                  child: displayedTransactions.isEmpty
                      ? Center(
                          child: Text(
                            'No hay movimientos',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: displayedTransactions.length,
                          itemBuilder: (context, index) {
                            final tx = displayedTransactions[index];
                            final isIncome = tx.type == TransactionType.income;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildTransactionCard(
                                icon: isIncome
                                    ? Icons.savings_outlined
                                    : Icons.bolt,
                                iconColor: isIncome
                                    ? const Color(0xFF10B981)
                                    : Colors.black87,
                                bgIconColor: isIncome
                                    ? const Color(0xFF10B981).withOpacity(0.1)
                                    : Colors.red.shade50,
                                title: tx.title,
                                time: DateFormat('hh:mm a').format(tx.date),
                                amount:
                                    '${isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                                amountColor: isIncome
                                    ? const Color(0xFF10B981)
                                    : Colors.red,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required IconData icon,
    required Color iconColor,
    required Color bgIconColor,
    required String title,
    required String time,
    required String amount,
    required Color amountColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgIconColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
