import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/avatar_selector.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  int _selectedAvatarIndex = 0;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).userProfile;
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _selectedAvatarIndex = user.avatarIndex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      Provider.of<UserProvider>(context, listen: false).updateUserProfile(
        _nameController.text,
        _emailController.text,
        _selectedAvatarIndex,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
      Navigator.pop(context); // Go back after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    // Avatar configs
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

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Light background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Avatar Section
              GestureDetector(
                onTap: () {
                  // Optional: Open full avatar picker modal if needed,
                  // but for now we interact with the selector below
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colors[_selectedAvatarIndex].withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icons[_selectedAvatarIndex],
                    size: 50,
                    color: colors[_selectedAvatarIndex],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Elige tu avatar",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Avatar Selector Widget
              Container(
                height: 60,
                // We'll trust AvatarSelector works, or we can inline a simple selector here if it's broken
                // Assuming AvatarSelector is compatible. If not, we'll replace it soon.
                // Let's use a horizontal list for simplicity to guarantee look & feel
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: icons.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedAvatarIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatarIndex = index),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors[index].withOpacity(0.2)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? colors[index]
                                : Colors.grey.shade200,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          icons[index],
                          color: isSelected ? colors[index] : Colors.grey,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Fields
              _buildTextField(
                label: 'Nombre Completo',
                controller: _nameController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Correo Electrónico',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (value) {
            if (value == null || value.isEmpty)
              return 'Este campo es requerido';
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: Colors.grey.shade400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}
