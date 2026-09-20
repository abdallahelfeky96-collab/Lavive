import 'package:flutter/material.dart';

class SocialMediaButton extends StatelessWidget {
  const SocialMediaButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.borderColor,
    required this.textColor,
    this.icon,
    this.iconSize,
    this.iconColor,
  });

  final String text;
  final double? iconSize;
  final Color? iconColor;
  final IconData? icon;
  final Color textColor;
  final Color borderColor;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        alignment: Alignment.center,
        // height: 50.h,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              text,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class GPlus extends StatelessWidget {
  const GPlus({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          "Google",
          style: TextStyle(color: Colors.red),
        )
      ],
    );
  }
}
