import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MaktubConstants {
  static const Color primaryColor = Color(0xFF01BC41);
  static const Color secondaryColor = Color(0xFFF5F5F5);

  static const Color backgroundColor = Colors.white;
  static const Color transparent = Colors.transparent;

  static const Color bigTextColor = Color(0xFF1F1F1F);
  static const Color mainTextColor = Color(0xFF303030);
  static const Color detailTextColor = Color(0xFF878787);
  static const Color productTextColor = Color(0xFF4F4F4F);
}

class Gradients {
  static const Color primary = Color(0xFF01BC41);

  static const Color disabled = Color(0xFFd4f2d6);
  static const Color error = Colors.red;

  static const Color textGray = Color(0xFF333333);
  static Color? hintText = Colors.grey[400];
  static const Color textWhite = Colors.white;
  static const Color borderGray = Color(0xFFe5e5e5);

  static const Color highlightBackground = Color(0xFFE4F7E9);
  static const Color loaderTrack = Color(0xFFE0F4E6);

  static const Color backgroundColor = Colors.white;
  static const Color transparent = Colors.transparent;

  static const Color bigTextColor = Color(0xFF1F1F1F);
  static const Color mainTextColor = Color(0xFF303030);
  static const Color detailTextColor = Color(0xFF878787);
  static const Color productTextColor = Color.fromARGB(255, 51, 51, 51);
}


   final title = GoogleFonts.montserrat(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Gradients.textGray,
  );

   final subtitle = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.grey,
  );

   final mainText = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Gradients.textGray,
  );

     final productNameText = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Gradients.productTextColor,
  );


   final hint = GoogleFonts.montserrat(
    fontWeight: FontWeight.w500,
    color: Gradients.hintText,
  );

   final button = GoogleFonts.montserrat(
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

     final selectedLabel = GoogleFonts.montserrat(
    // fontWeight: FontWeight.bold,
    color: Gradients.primary,
    fontSize: 12, 
    fontWeight: FontWeight.w600
  );

       final unselectedLabel = GoogleFonts.montserrat(
    // fontWeight: FontWeight.bold,
    color: Gradients.textGray,
    fontSize: 12,
    fontWeight: FontWeight.w600
  );

