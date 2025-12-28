import 'package:flutter/material.dart';
import 'package:pharmacy_app/core/themes/app_theme.dart';

class CategoryChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const CategoryChip({
    super.key,
    required this.label,
    required this.icon,
    this.isSelected = false,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: widget.isSelected
                ? AppTheme.primaryColor
                : Colors.grey.withOpacity(0.3),
            width: widget.isSelected ? 1.5 : 1,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : widget.isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 18,
              color: _getIconColor(context),
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                color: _getTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    
    if (widget.isSelected) {
      return AppTheme.primaryColor.withOpacity(0.1);
    }
    
    if (_isPressed) {
      return AppTheme.primaryColor.withOpacity(0.05);
    }
    
    return Colors.white;
  }

  Color _getTextColor(BuildContext context) {
    if (widget.textColor != null) return widget.textColor!;
    
    if (widget.isSelected) {
      return AppTheme.primaryColor;
    }
    
    return Colors.grey[700]!;
  }

  Color _getIconColor(BuildContext context) {
    if (widget.iconColor != null) return widget.iconColor!;
    
    if (widget.isSelected) {
      return AppTheme.primaryColor;
    }
    
    return Colors.grey[600]!;
  }
}