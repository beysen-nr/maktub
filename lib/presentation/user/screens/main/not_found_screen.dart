import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotFoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          '404 - Page Not Found',
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
