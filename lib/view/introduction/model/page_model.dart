import 'package:flutter/material.dart';

class IntroPage {
  String path;
  String title;
  String body;
  Color? primaryColor;
  Color? secondaryColor;
  IconData? icon;

  IntroPage({
    required this.path,
    required this.title,
    required this.body,
    this.primaryColor,
    this.secondaryColor,
    this.icon,
  });
}
