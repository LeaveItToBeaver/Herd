import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        width: size,
        height: size,
        child: Center(
            child: Image.asset(
          'assets/icon/icon.png',
          fit: BoxFit.fill,
        )),
      ),
    );
  }
}
