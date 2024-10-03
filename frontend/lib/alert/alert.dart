import 'package:flutter/material.dart';

void showAlert(BuildContext context, String message, bool isSuccess) {
  final icon = isSuccess ? Icons.check_circle : Icons.error;
  final bgColor = isSuccess ? Colors.green : Colors.red;

  final snackBar = SnackBar(
    content: Row(
      mainAxisSize: MainAxisSize.min, 
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon, 
          color: Colors.white,  
          size: 20,  
        ),
        const SizedBox(width: 10), 
        Text(
          message,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    backgroundColor: bgColor,
    behavior: SnackBarBehavior.floating, 
    margin: const EdgeInsets.only(
      bottom: 40.0,
      left: 20.0,
      right: 20.0,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
    duration: const Duration(seconds: 3), 
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
