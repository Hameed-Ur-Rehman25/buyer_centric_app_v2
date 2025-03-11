import 'package:flutter/material.dart';

class PoweredBy extends StatelessWidget {
  const PoweredBy({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1, // Responsive horizontal padding
          vertical: size.height * 0.03, // Responsive vertical padding
        ),
        child: SizedBox(
          width: size.width * 0.5, // Image occupies 50% of screen width
          child: FittedBox(
            fit: BoxFit.contain, // Maintain aspect ratio without distortion
            child: Image.asset('assets/images/Component 1.png'),
          ),
        ),
      ),
    );
  }
}
