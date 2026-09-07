import 'package:flutter/material.dart';

/// Koyu temaya uygun ortak metin alanı
class SinflixField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  // Opsiyoneller
  final TextInputType? type;
  final TextInputAction? action;
  final bool obscure;
  final VoidCallback? onToggle;

  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final TextCapitalization capitalization;

  /// Toggle dışı özel prefix/suffix
  /// [onToggle] tanımlıysa `suffix` görmezden gelinir.
  final Widget? prefix;
  final Widget? suffix;

  const SinflixField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.type,
    this.action,
    this.obscure = false,
    this.onToggle,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.capitalization = TextCapitalization.none,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      keyboardType: type,
      textInputAction: action,
      obscureText: obscure,
      maxLines: obscure ? 1 : maxLines,
      textCapitalization: capitalization,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefix ?? Icon(icon, color: Colors.white70),
        suffixIcon: onToggle != null
            ? IconButton(
                onPressed: onToggle,
                icon: Icon(
                  // obscure durumunda üstü çizili göz göster
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
              )
            : suffix,
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.w600,
        ),
        // Koyu zeminde hata daha belirgin görünsün
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }
}

/// Sosyal giriş butonu (UI)
class SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  final double size; // kare boyut
  final Color background;
  final Color iconColor;
  final String? tooltip;

  const SocialButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 64,
    this.background = const Color(0xFF1F1F1F),
    this.iconColor = Colors.white,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final child = InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );

    return Semantics(
      button: true,
      label: tooltip,
      child: tooltip == null ? child : Tooltip(message: tooltip!, child: child),
    );
  }
}
