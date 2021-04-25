import 'package:flutter/material.dart';

class CustomSearchInput extends StatelessWidget {
  final Function(String value) onChanged;
  final String hintText;
  final TextInputType keyboardType;
  final IconData iconData;
  final bool isPassword;
  final TextEditingController controller;

  CustomSearchInput({
    this.onChanged,
    this.controller,
    this.hintText,
    this.keyboardType = TextInputType.name,
    this.iconData,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.left,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 20, color: Colors.white),
        decoration: InputDecoration(
          icon: iconData != null
              ? Icon(
                  iconData,
                  color: Colors.black,
                )
              : null,
          fillColor: Color(0xffE8E8E9).withAlpha(20),
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 25, color: Colors.grey),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
        obscureText: isPassword,
        onChanged: (value) {
          onChanged(value);
        },
      ),
    );
  }
}
