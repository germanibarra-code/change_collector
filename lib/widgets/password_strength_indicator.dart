import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  // Calcular la fortaleza de la contraseña
  PasswordStrength _calculateStrength() {
    if (password.isEmpty) {
      return PasswordStrength.none;
    }

    int score = 0;

    // Verificar longitud
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Verificar mayúsculas
    if (password.contains(RegExp(r'[A-Z]'))) score++;

    // Verificar minúsculas
    if (password.contains(RegExp(r'[a-z]'))) score++;

    // Verificar números
    if (password.contains(RegExp(r'[0-9]'))) score++;

    // Verificar caracteres especiales
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  // Verificar requisitos individuales
  bool _hasMinLength() => password.length >= 8;
  bool _hasUppercase() => password.contains(RegExp(r'[A-Z]'));
  bool _hasLowercase() => password.contains(RegExp(r'[a-z]'));
  bool _hasNumber() => password.contains(RegExp(r'[0-9]'));
  bool _hasSpecialChar() =>
      password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  // Verificar si la contraseña es válida
  bool isValid() {
    return _hasMinLength() &&
        _hasUppercase() &&
        _hasLowercase() &&
        _hasNumber() &&
        _hasSpecialChar();
  }

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de fortaleza
          if (password.isNotEmpty) ...[
            Row(
              children: [
                const Text(
                  'Fortaleza: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  strength.label,
                  style: TextStyle(
                    color: strength.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: strength.progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(strength.color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Título de requisitos
          const Text(
            'Requisitos:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          // Grid de requisitos en 2 columnas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna 1
              Expanded(
                child: Column(
                  children: [
                    _buildRequirement('8+ caracteres', _hasMinLength()),
                    _buildRequirement('Mayúscula (A-Z)', _hasUppercase()),
                    _buildRequirement('Minúscula (a-z)', _hasLowercase()),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Columna 2
              Expanded(
                child: Column(
                  children: [
                    _buildRequirement('Número (0-9)', _hasNumber()),
                    _buildRequirement('Especial (!@#\$)', _hasSpecialChar()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? const Color(0xFF10B981) : Colors.grey.shade400,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isMet ? const Color(0xFF0F172A) : Colors.grey.shade600,
                fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enum para los niveles de fortaleza
enum PasswordStrength {
  none,
  weak,
  medium,
  strong;

  String get label {
    switch (this) {
      case PasswordStrength.none:
        return '';
      case PasswordStrength.weak:
        return 'Débil';
      case PasswordStrength.medium:
        return 'Media';
      case PasswordStrength.strong:
        return 'Fuerte';
    }
  }

  Color get color {
    switch (this) {
      case PasswordStrength.none:
        return Colors.grey;
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return const Color(0xFF10B981);
    }
  }

  double get progress {
    switch (this) {
      case PasswordStrength.none:
        return 0.0;
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}
