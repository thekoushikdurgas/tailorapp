import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TextLabelLargeTitle extends StatelessWidget {
  const TextLabelLargeTitle({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.tr(),
      style: Theme.of(context).textTheme.labelLarge,
    );
  }
}
