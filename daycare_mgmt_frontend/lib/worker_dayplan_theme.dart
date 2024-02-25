import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// theme for the headings in the dayplan and add dayplan pages
TextStyle get subHeadingStyle {
  return (TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 136, 136, 136)));
}

TextStyle get HeadingStyle {
  return (TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
}

TextStyle get titleStyle {
  return (TextStyle(
      fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black));
}

TextStyle get subTitleStyle {
  return (TextStyle(
      fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey[600]));
}
