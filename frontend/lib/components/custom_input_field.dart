import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? Function(String?)? validator;

  const CustomInputField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14.5,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color.fromARGB(255, 232, 234, 234),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
