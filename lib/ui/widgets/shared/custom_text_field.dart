import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final Function(String val) onChanged;
  final double hieght;
  final TextInputAction textInputAction;
  const CustomTextField(
      {Key key,
      this.hint,
      this.onChanged,
      this.hieght = 54,
      this.textInputAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: hieght,
      decoration: BoxDecoration(
          border: Border.all(width: 1.5),
          borderRadius: BorderRadius.circular(45)),
      child: TextField(
        keyboardType: TextInputType.text,
        textInputAction: textInputAction,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
