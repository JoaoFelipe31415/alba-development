import 'package:flutter/material.dart';

class RowLine extends StatelessWidget {
  const RowLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: (MediaQuery.of(context).size.width) / 2,
      color: Colors.grey,
    );
  }
}
