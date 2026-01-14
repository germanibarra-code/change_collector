import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/wallet_provider.dart';
import 'profile_screen.dart'; // Reuse the edit screen logic if needed

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Avatar configs again (could be centralized)
    final List<IconData> icons = [
      Icons.person,
      Icons.person_outline,
      Icons.face,
      Icons.face_2,
      Icons.face_3,
      Icons.face_4,
      Icons.emoji_emotions,
      Icons.tag_faces,
    ];
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header Title
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Mi Perfil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),

          // Big Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colors[userProvider.userProfile.avatarIndex].withOpacity(
                0.2,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icons[userProvider.userProfile.avatarIndex],
              color: colors[userProvider.userProfile.avatarIndex],
              size: 60,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            userProvider.userProfile.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            userProvider.userProfile.email,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF10B981)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
            child: const Text(
              'Editar Perfil',
              style: TextStyle(color: Color(0xFF10B981)),
            ),
          ),

          const SizedBox(height: 48),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'GENERAL',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          _buildSettingsItem(
            Icons.verified_user_outlined,
            'Seguridad',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildSettingsItem(
            Icons.notifications_none,
            'Notificaciones',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildSwitchItem(
            Icons.dark_mode_outlined,
            'Modo Oscuro',
            false,
          ), // Mock switch
          const SizedBox(height: 12),
          _buildSettingsItem(
            Icons.download_outlined,
            'Exportar Datos (Respaldo)',
            onTap: () {},
          ),

          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'APP',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          // Delete Account Button
          InkWell(
            onTap: () async {
              // Confirm Dialog
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('¿Estás seguro?'),
                  content: const Text(
                    'Esto borrará todos tus datos y transacciones. No se puede deshacer.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Borrar Todo',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).clearProfile(); // If implemented, or just skip
                await Provider.of<WalletProvider>(
                  context,
                  listen: false,
                ).clearAllData();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cuenta reiniciada correctamente'),
                    ),
                  );
                  // Optionally navigate to onboarding
                }
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.1)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Borrar Cuenta (Full Reset)',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Scroll padding
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.grey.shade600),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildSwitchItem(IconData icon, String title, bool value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey.shade600),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Switch(
          value: value,
          onChanged: (val) {},
          activeColor: const Color(0xFF10B981),
        ),
      ),
    );
  }
}
