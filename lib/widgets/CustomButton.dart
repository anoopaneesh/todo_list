import 'package:flutter/material.dart';
class CustomButton extends StatelessWidget {
  final Widget child;
  final Function onPressed;

  const CustomButton({Key key, this.onPressed, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color : Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }
}
