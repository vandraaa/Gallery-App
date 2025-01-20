import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final IconData? icon;

  const CustomElevatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.isLoading,
    this.backgroundColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: backgroundColor ?? Colors.blueAccent,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: const StadiumBorder(),
      ),
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.0,
              ),
            )
          : Icon(icon, size: 18),
      label: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 14.0,
        ),
      ),
    );
  }
}
