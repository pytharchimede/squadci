import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final String confirmPassword;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    required this.confirmPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (password.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildStrengthIndicator(),
          const SizedBox(height: 8),
          _buildRequirements(),
        ],
        if (confirmPassword.isNotEmpty && password != confirmPassword) ...[
          const SizedBox(height: 8),
          _buildPasswordMismatch(),
        ],
      ],
    );
  }

  Widget _buildStrengthIndicator() {
    final strength = _calculatePasswordStrength();
    final color = _getStrengthColor(strength);
    final text = _getStrengthText(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Force du mot de passe: $text',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: strength / 4,
          backgroundColor: AppColors.cardBackground,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildRequirements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequirement('Au moins 6 caractères', password.length >= 6),
        _buildRequirement(
            'Au moins une majuscule', password.contains(RegExp(r'[A-Z]'))),
        _buildRequirement(
            'Au moins une minuscule', password.contains(RegExp(r'[a-z]'))),
        _buildRequirement(
            'Au moins un chiffre', password.contains(RegExp(r'[0-9]'))),
      ],
    );
  }

  Widget _buildRequirement(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: met ? AppColors.success : AppColors.textGrey,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: met ? AppColors.success : AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordMismatch() {
    return Row(
      children: [
        const Icon(
          Icons.error_outline,
          size: 14,
          color: AppColors.error,
        ),
        const SizedBox(width: 6),
        const Text(
          'Les mots de passe ne correspondent pas',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  double _calculatePasswordStrength() {
    double strength = 0;

    if (password.length >= 6) strength += 1;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 1;
    if (password.contains(RegExp(r'[a-z]'))) strength += 1;
    if (password.contains(RegExp(r'[0-9]'))) strength += 1;

    return strength;
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 1) return AppColors.error;
    if (strength <= 2) return AppColors.warning;
    if (strength <= 3) return AppColors.primaryOrange;
    return AppColors.success;
  }

  String _getStrengthText(double strength) {
    if (strength <= 1) return 'Faible';
    if (strength <= 2) return 'Moyen';
    if (strength <= 3) return 'Bon';
    return 'Excellent';
  }
}
