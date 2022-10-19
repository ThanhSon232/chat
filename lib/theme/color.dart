import 'package:flutter/material.dart';

Color getColorFromHex(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  return Color(int.parse(hexColor, radix: 16));
}


const black = Colors.black;

var manatee = getColorFromHex("#999EA1");

const red = Colors.red;

const blue = Colors.blue;

var purpleSolid = getColorFromHex("#4E0189");

const white = Colors.white;


