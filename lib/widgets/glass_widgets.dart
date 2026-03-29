import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:classtrack/theme/design_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(32),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? ClassTrackTheme.bentoRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.05) 
                : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(borderRadius ?? ClassTrackTheme.bentoRadius),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.1) 
                  : Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;
  final bool isSecondary;
  final double scale;
  final double? width;
  final double? height;
  final bool isLoading;

  const GlassButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.isSecondary = false,
    this.scale = 1.0,
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: (height ?? 64) * scale.clamp(0.85, 1.0),
      decoration: BoxDecoration(
        color: isSecondary
            ? Colors.transparent
            : (onPressed == null ? ClassTrackTheme.primaryBlue.withValues(alpha: 0.6) : ClassTrackTheme.primaryBlue),
        borderRadius: BorderRadius.circular(20),
        border: isSecondary
            ? Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
                width: 1,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else ...[
                  if (label != null)
                    Text(
                      label!,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isSecondary 
                            ? (isDark ? Colors.white : Colors.black87) 
                            : Colors.white,
                        fontSize: 16 * scale.clamp(0.9, 1.0),
                      ),
                    ),
                  if (label != null && icon != null) const SizedBox(width: 8),
                  if (icon != null)
                    Icon(
                      icon!,
                      color: isSecondary 
                          ? (isDark ? Colors.white : Colors.black87) 
                          : Colors.white,
                      size: 20 * scale.clamp(0.9, 1.0),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DynamicBackground extends StatelessWidget {
  const DynamicBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: _BlurredCircle(
            size: 300,
            color: ClassTrackTheme.primaryBlue.withValues(alpha: isDark ? 0.15 : 0.1),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -100,
          child: _BlurredCircle(
            size: 400,
            color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.1 : 0.05),
          ),
        ),
        // Add a third subtle circle for more depth
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          left: -150,
          child: _BlurredCircle(
            size: 250,
            color: ClassTrackTheme.primaryBlue.withValues(alpha: isDark ? 0.08 : 0.05),
          ),
        ),
      ],
    );
  }
}

class _BlurredCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurredCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final double scale;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontSize: 16 * scale.clamp(0.9, 1.0),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF94A3B8),
            fontSize: 14 * scale.clamp(0.9, 1.0),
          ),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 20 * scale),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon, color: const Color(0xFF94A3B8), size: 18 * scale),
                  onPressed: onSuffixIconPressed,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class GlassDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String hintText;
  final IconData prefixIcon;
  final double scale;

  const GlassDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hintText,
    required this.prefixIcon,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 20 * scale),
              const SizedBox(width: 12),
              Text(
                hintText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14 * scale.clamp(0.9, 1.0),
                ),
              ),
            ],
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF94A3B8),
          ),
          items: items,
          onChanged: onChanged,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
