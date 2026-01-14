import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/wallet_provider.dart';
import '../models/transaction_item.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_action.dart';
import '../widgets/tour_overlay.dart';
import '../providers/app_state_provider.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'analysis_screen.dart';
import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Light Gray background
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Index 0: Dashboard (Home)
          Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Hola, ${userProvider.userProfile.name}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.waving_hand,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  // Streak Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFFFF7ED,
                                      ), // Light orange
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.local_fire_department_rounded,
                                          color: Colors.orange,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '0',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Bienvenido',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              // Switch to Account Tab (Index 3)
                              setState(() => _currentIndex = 3);
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFECFDF5,
                                ), // Very light green
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.person_outline_rounded,
                                color: Color(0xFF047857),
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Balance Card
                      const BalanceCard(),

                      const SizedBox(height: 24),

                      // Scan Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _simulateScan(context),
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Escanear Mi Cambio'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Quick Actions Grid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Pay -> Simulator
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _simulateScan(context),
                              child: const QuickAction(
                                icon: Icons.qr_code_scanner,
                                label: 'Pagar',
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Analysis
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AnalysisScreen(),
                                  ),
                                );
                              },
                              child: const QuickAction(
                                icon: Icons.bar_chart,
                                label: 'Análisis',
                                color: Colors.purple,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // History
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _currentIndex = 2),
                              child: const QuickAction(
                                icon: Icons.history,
                                label: 'Historial',
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Sections
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mis Metas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.add,
                              size: 16,
                              color: Color(0xFF10B981),
                            ),
                            label: const Text(
                              'Nueva',
                              style: TextStyle(color: Color(0xFF10B981)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: const Center(
                          child: Text(
                            'No tienes metas de ahorro. ¡Crea una para motivarte!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Actividad Reciente',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(
                              () => _currentIndex = 2,
                            ), // Go to History
                            child: const Text(
                              'Ver todo',
                              style: TextStyle(color: Color(0xFF10B981)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // DYNAMIC RECENT ACTIVITY LIST
                      if (walletProvider.transactions.isEmpty)
                        const Center(
                          child: Text(
                            "No hay actividad reciente",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                      ...walletProvider.transactions.take(3).map((transaction) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      transaction.type ==
                                          TransactionType.expense
                                      ? Colors.red.withOpacity(0.1)
                                      : const Color(
                                          0xFF10B981,
                                        ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  transaction.type == TransactionType.expense
                                      ? Icons.bolt
                                      : Icons.savings_outlined,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      transaction.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Simple date formatting
                                    Text(
                                      "${transaction.date.day}/${transaction.date.month} ${transaction.date.hour}:${transaction.date.minute.toString().padLeft(2, '0')}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${transaction.type == TransactionType.expense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color:
                                      transaction.type ==
                                          TransactionType.expense
                                      ? Colors.red
                                      : const Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Extra space for bottom nav
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              // TOUR OVERLAY
              Consumer<AppStateProvider>(
                builder: (context, appState, child) {
                  if (appState.showTour) {
                    return TourOverlay(
                      title: '¡Bienvenido a tu nuevo Panel!',
                      description:
                          'Desde aquí puedes ver tu saldo, escanear cambio y gestionar tus metas. Usa el menú inferior para navegar.',
                      onNext: () => appState.completeTour(),
                      onSkip: () => appState.completeTour(),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),

          // Index 1: QR Simulated
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _simulateScan(context),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        size: 64,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Toca para Escanear',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Simulación de cámara activa',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // Index 2: History
          const SafeArea(child: HistoryScreen()),

          // Index 3: Account
          const SafeArea(child: AccountScreen()),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF10B981),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.white),
              ),
              label: 'QR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Cuenta',
            ),
          ],
        ),
      ),
    );
  }

  // QR SCAN SIMULATOR LOGIC
  void _simulateScan(BuildContext context) async {
    // 1. Show "Scanning" dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const SimpleDialog(
        children: [
          Center(
            child: Column(
              children: [
                CircularProgressIndicator(color: Color(0xFF10B981)),
                SizedBox(height: 16),
                Text("Detectando ticket..."),
              ],
            ),
          ),
        ],
      ),
    );

    // 2. Wait 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context); // Close loading

    // 3. Randomize a discovered amount
    final amounts = [12.50, 45.00, 8.20, 150.00, 5.00];
    final amount = (amounts..shuffle()).first;

    // 4. Show "Found" dialog with confirm
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 48),
            const SizedBox(height: 16),
            const Text(
              "¡Ticket Procesado!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Se detectó un cambio de \$$amount",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // ADD TO PROVIDER
                  Provider.of<WalletProvider>(
                    context,
                    listen: false,
                  ).addTransaction(
                    TransactionItem(
                      id: DateTime.now().toString(),
                      title: 'Ahorro Ticket #${DateTime.now().minute}',
                      amount: amount,
                      date: DateTime.now(),
                      type: TransactionType.income,
                    ),
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Ahorro registrado exitosamente! 💰'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Guardar en mi Ahorro"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
