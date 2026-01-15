import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../models/transaction_item.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<WalletProvider>(
      builder: (context, provider, child) {
        final income = provider.totalIncome;
        final expense = provider.totalExpense;
        final savings = provider.totalBalance; // Savings = Net Calculate

        // Prepare chart data
        final List<FlSpot> spots = _generateChartPoints(provider.transactions);

        // Calculate min/max for chart y-axis
        double minY = 0;
        double maxY = 100;

        if (spots.isNotEmpty) {
          double minVal = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
          double maxVal = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

          if (minVal == maxVal) {
            minVal -= (minVal.abs() * 0.2 + 10); // buffer
            maxVal += (maxVal.abs() * 0.2 + 10);
          }

          minY = minVal;
          maxY = maxVal;

          // Add generous padding
          double range = maxY - minY;
          if (range == 0) range = 10;
          minY -= range * 0.2;
          maxY += range * 0.2;
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 60,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor.withOpacity(0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 20,
                          color: theme.iconTheme.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Análisis',
                      style:
                          theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ) ??
                          const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Trend Chart Group
                Text(
                  'Tendencia de Saldo',
                  style:
                      theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ) ??
                      const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 250,
                  padding: const EdgeInsets.fromLTRB(16, 24, 24, 10),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: spots.isEmpty
                      ? Center(
                          child: Text(
                            'No hay datos suficientes',
                            style: TextStyle(color: theme.hintColor),
                          ),
                        )
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) =>
                                      _leftTitleWidgets(value, meta, theme),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            minX: spots.first.x,
                            maxX: spots.last.x,
                            minY: minY,
                            maxY: maxY,
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: const Color(0xFF10B981),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(0xFF10B981).withOpacity(0.2),
                                      const Color(0xFF10B981).withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems:
                                    (List<LineBarSpot> touchedBarSpots) {
                                      return touchedBarSpots.map((barSpot) {
                                        return LineTooltipItem(
                                          '\$${barSpot.y.toStringAsFixed(2)}',
                                          TextStyle(
                                            color: theme
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }).toList();
                                    },
                              ),
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 32),

                // Bar Chart Group / Stats
                Text(
                  'Resumen',
                  style:
                      theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ) ??
                      const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildRealBarColumn(
                        context,
                        label: 'Entradas',
                        value: income,
                        maxVal: _calculateMax(income, expense, savings),
                        color: const Color(0xFF10B981),
                      ),
                      _buildRealBarColumn(
                        context,
                        label: 'Gastos',
                        value: expense,
                        maxVal: _calculateMax(income, expense, savings),
                        color: const Color(0xFFEF4444),
                      ),
                      _buildRealBarColumn(
                        context,
                        label:
                            'Ahorros', // This currently represents Net Balance
                        value: savings,
                        maxVal: _calculateMax(income, expense, savings),
                        color: Colors.orange,
                        isSavings: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Generate running balance spots for the chart
  List<FlSpot> _generateChartPoints(List<TransactionItem> transactions) {
    if (transactions.isEmpty) return [];

    // 1. Sort transactions by date ascending (oldest to newest)
    final sorted = List<TransactionItem>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // 2. Calculate running balance
    List<FlSpot> points = [];
    double currentBalance = 0;

    for (int i = 0; i < sorted.length; i++) {
      final tx = sorted[i];
      if (tx.type == TransactionType.income) {
        currentBalance += tx.amount;
      } else {
        currentBalance -= tx.amount;
      }
      points.add(FlSpot(i.toDouble(), currentBalance));
    }

    // If only 1 point, add a start point at 0,0 to make a line
    if (points.length == 1) {
      points.insert(0, const FlSpot(-1, 0));
    }

    return points;
  }

  double _calculateMax(double a, double b, double c) {
    double maxVal = a;
    if (b > maxVal) maxVal = b;
    if (c > maxVal) maxVal = c;
    return maxVal > 0 ? maxVal : 1.0; // Avoid 0
  }

  Widget _buildRealBarColumn(
    BuildContext context, {
    required String label,
    required double value,
    required double maxVal,
    required Color color,
    bool isSavings = false,
  }) {
    final theme = Theme.of(context);
    // Max visual height for the bar
    const double maxHeight = 120.0;

    // Relative height
    double displayHeight = (value.abs() / maxVal) * maxHeight;
    if (displayHeight < 4) displayHeight = 4; // Min height so it's visible

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '\$${value.toStringAsFixed(0)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: displayHeight,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.hintColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta, ThemeData theme) {
    final style = TextStyle(color: theme.hintColor, fontSize: 10);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('\$${value.toInt()}', style: style),
    );
  }
}
