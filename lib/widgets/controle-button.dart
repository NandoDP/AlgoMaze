import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? decoColor;
  final double? width;
  final double? iconSize;
  final VoidCallback? onPressed;

  ControlButton(
    this.icon,
    this.color, {
    this.onPressed,
    this.width,
    this.decoColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: width ?? 40,
        height: width ?? 40,
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: decoColor ?? const Color(0xFF444444),
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize ?? (width != null ? 16 * width! / 40 : 14),
        ),
      ),
    );
  }
}