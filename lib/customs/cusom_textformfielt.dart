// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final Widget? label;
  final double? border = 1;
  final bool? isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final String? initialValue;

  const CustomTextFormField({
    super.key,
    this.label,
    this.isPassword,
    this.controller,
    this.onSaved,
    this.validator,
    this.initialValue, required Text text, required String data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        initialValue: initialValue,
        validator: validator,
        onSaved: onSaved,
        controller: controller,
        obscureText: isPassword == null ? false : true,
        decoration: InputDecoration(
            label: label,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(width: 1),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(width: 1),
            )),
      ),
    );
  }
}
