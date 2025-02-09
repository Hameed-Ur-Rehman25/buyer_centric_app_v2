import 'package:flutter/material.dart';

class PoweredBy extends StatelessWidget {
  const PoweredBy({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: size.width * 0.27, vertical: 15),
      child: Image.asset('assets/images/Component 1.png'),
    );
  }
}
