import 'package:flutter/material.dart';

class OnlineIndicator extends StatelessWidget {
  const OnlineIndicator({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      width: 14,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.green.shade500,
        border:
            Border.all(width: 1, color: Theme.of(context).bottomAppBarColor),
      ),
    );
  }
}
