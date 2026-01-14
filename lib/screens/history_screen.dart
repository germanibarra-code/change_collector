import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
              const SizedBox(width: 16),
              const Text(
                'Movimientos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          Row(
            children: [
              _buildFilterChip('Todos', isSelected: true),
              const SizedBox(width: 12),
              _buildFilterChip('Ingresos', isSelected: false),
              const SizedBox(width: 12),
              _buildFilterChip('Gastos', isSelected: false),
            ],
          ),
          const SizedBox(height: 32),

          // Date Header
          Text(
            'AYER',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          // Transactions
          _buildTransactionCard(
            icon: Icons.bolt,
            iconColor: Colors.black87,
            bgIconColor: Colors.red.shade50,
            title: 'Pago en Comercio (Demo)',
            time: '10:25 a.m.',
            amount: '-\$5.00',
            amountColor: Colors.red,
          ),
          const SizedBox(height: 16),
          _buildTransactionCard(
            icon: Icons.savings_outlined,
            iconColor: Colors.black87,
            bgIconColor: const Color(0xFF10B981).withOpacity(0.1),
            title: 'Cambio en Oxxo',
            time: '10:25 a.m.',
            amount: '+\$39.21',
            amountColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {required bool isSelected}) {
    return Container(
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
