import 'package:flutter/material.dart';

class ResponsiveSize {
  static double getHeight(BuildContext context, double heightPercentage) {
    return MediaQuery.of(context).size.height * heightPercentage / 100;
  }

  static double getWidth(BuildContext context, double widthPercentage) {
    return MediaQuery.of(context).size.width * widthPercentage / 100;
  }
}
