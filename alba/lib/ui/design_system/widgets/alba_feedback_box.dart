import 'package:flutter/material.dart';

class AlbaFeedbackBox extends StatelessWidget {
  final Color bgColor;
  final String text;

  const AlbaFeedbackBox({
    super.key,
    required this.bgColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF334155),
          height: 1.4,
          fontSize: 14,
        ),
      ),
    );
  }
}