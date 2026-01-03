import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialLoginButton extends StatelessWidget {
  final String? iconPath;
  final IconData? icon;
  final void Function()? onPressed;
  final double size;

  const SocialLoginButton({
    super.key,
    this.iconPath,
    this.icon,
    this.onPressed,
    this.size = 50,
  }) : assert(iconPath != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: iconPath != null
              ? SvgPicture.asset(
                  iconPath!,
                  width: size * 0.5,
                  height: size * 0.5,
                )
              : Icon(
                  icon,
                  size: size * 0.5,
                  color: Theme.of(context).primaryColor,
                ),
        ),
      ),
    );
  }
}