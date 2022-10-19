import 'package:chat/theme/dimension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final EdgeInsetsGeometry? contentPadding;
  final BorderRadius? borderRadius;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Widget? prefix;
  final Widget? suffix;
  final String? hintText;
  final bool? obscureText;
  const CustomTextFormField({Key? key,this.controller,this.prefix, this.suffix,this.validator, this.contentPadding, this.borderRadius, this.hintText, this.obscureText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText ?? false,
      decoration: InputDecoration(
          contentPadding: contentPadding ?? EdgeInsets.symmetric(horizontal: size_10_w),
          hintText: hintText,
          prefixIcon: prefix,
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(size_10_h),
          )
      ),
    );
  }
}
