import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/user_provider.dart';
import 'providers/app_state_provider.dart';
import 'screens/login_screen.dart';

import 'providers/wallet_provider.dart';
import 'supabase/client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeSupabase();

  // Test Supabase connection
  try {
    final session = supabase.auth.currentSession;
    debugPrint('✅ Supabase initialized successfully');
    debugPrint(
      '📱 Current session: ${session?.user.id ?? "No active session (not logged in)"}',
    );
  } catch (e) {
    debugPrint('❌ Supabase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Change Collector',
            debugShowCheckedModeBanner: false,
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: Colors.white,
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF047857), // Deep Green for Primary elements
                secondary: Color(0xFF10B981), // Emerald for Accents
                surface: Colors.white,
                background: Colors.white,
                onPrimary: Colors.white,
                onSecondary: Colors.white,
              ),
              textTheme: GoogleFonts.outfitTextTheme().apply(
                bodyColor: const Color(0xFF1F2937), // Dark Gray Text
                displayColor: const Color(0xFF111827), // Almost Black Headers
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                iconTheme: IconThemeData(color: Color(0xFF1F2937)),
                titleTextStyle: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981), // Emerald Button
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  elevation: 0,
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF10B981), // Emerald for Primary
                secondary: Color(0xFF34D399), // Light Emerald for Accents
                surface: Color(0xFF1E293B),
                background: Color(0xFF0F172A),
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: Color(0xFFE2E8F0),
              ),
              textTheme: GoogleFonts.outfitTextTheme().apply(
                bodyColor: const Color(0xFFE2E8F0), // Light Gray Text
                displayColor: Colors.white, // White Headers
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                iconTheme: IconThemeData(color: Color(0xFFE2E8F0)),
                titleTextStyle: TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981), // Emerald Button
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  elevation: 0,
                ),
              ),
              cardColor: const Color(0xFF1E293B),
            ),
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
