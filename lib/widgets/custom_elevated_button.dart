import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/color.dart';

class CustomElevatedButton extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final OutlinedBorder? shape;
  final void Function()? onPressed;
  const CustomElevatedButton(
      {Key? key, required this.child, this.backgroundColor, this.shape, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            shape: shape ??
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: backgroundColor ?? purpleSolid),
        child: child,
      ),
    );
  }
}
