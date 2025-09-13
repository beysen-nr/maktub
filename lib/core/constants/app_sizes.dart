import 'package:flutter/material.dart';

class AppSizes {
  static double getWidth(BuildContext context, double baseWidth) {
    return baseWidth * (MediaQuery.of(context).size.width / 390);
  }

  static double getHeight(BuildContext context, double baseHeight) {
    return baseHeight * (MediaQuery.of(context).size.height / 844);
  }

  static double getFontSize(BuildContext context, double baseSize) {
    return baseSize * (MediaQuery.of(context).size.width / 390);
  }

  static EdgeInsets getOnlyPadding(BuildContext context,
      {double left = 0, double right = 0, double top = 0, double bottom = 0}) {
    return EdgeInsets.only(
      left: getWidth(context, left),
      right: getWidth(context, right),
      top: getHeight(context, top),
      bottom: getHeight(context, bottom),
    );
  }

  static EdgeInsets getSymmetricPadding(BuildContext context,
      {double horizontal = 0, double vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: getWidth(context, horizontal),
      vertical: getHeight(context, vertical),
    );
  }
}
